import 'dart:async';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

abstract class ApiRoute<T> {
  FutureOr<T?> loader(String route, Map<String, String> args) {
    return null;
  }
}

abstract class UiRoute<T> extends ApiRoute<T> {
  bool shouldCache = true;
  String currentRoute = '';

  Widget builder(BuildContext context, T data, Widget? child) {
    return child ?? Container();
  }

  navigate(BuildContext context, String route) {
    RoutingRequest(route).dispatch(context);
  }
}

class RoutingRequest extends Notification {
  final String route;
  RoutingRequest(this.route);
}

MapEntry<UiRoute, Map<String, String>>? getUiRoute(
  String route,
  Map<String, UiRoute> pages,
) {
  if (route == '/' || route.isEmpty) {
    final page = pages[route];
    if (page != null) return MapEntry(page, {});
    return null;
  }
  final match =
      pages.entries.toList().firstWhereOrNull((elem) => elem.key == route);
  if (match != null) return MapEntry(match.value, {});

  for (final page in pages.entries.toList().reversed) {
    if (page.key == '/' || page.key.isEmpty) continue;
    if (page.key == route) return MapEntry(page.value, {});
    final pageRoute = _fixRegExp(page.key);
    final pageMatch = pageRoute.hasMatch(_cleanRouteName(route));
    if (pageMatch) {
      final args = _getArgs(route, page.key, page.value);
      return MapEntry(page.value, args);
    }
  }
  return null;
}

final _cache = <String, Widget>{};

Future<Widget?> getRoute(
  BuildContext context,
  String route,
  Map<String, UiRoute> pages,
  Widget? child, {
  bool subRoutes = true,
  String? currentRoute,
}) async {
  if (_cache.containsKey(route)) return _cache[route];
  final page = getUiRoute(route, pages);
  if (page == null) return null;
  final pageValue = page.key;
  final pageArgs = page.value;
  pageValue.currentRoute = currentRoute ?? route;
  final data = await pageValue.loader(pageValue.currentRoute, pageArgs);
  Widget _child = pageValue.builder(context, data, child);
  if (!subRoutes) return _child;
  String _route = route;
  while (_route.isNotEmpty) {
    final List<String> routeParts = _route.split('/');
    routeParts.removeLast();
    _route = routeParts.join('/');
    if (_route == '/' || _route.isEmpty) break;
    final childWidget = await getRoute(
      context,
      _route,
      pages,
      _child,
      subRoutes: false,
      currentRoute: route,
    );
    if (childWidget == null) continue;
    _child = childWidget;
  }
  _route = '';
  final childWidget = await getRoute(
    context,
    _route,
    pages,
    _child,
    subRoutes: false,
    currentRoute: route,
  );
  if (childWidget != null) _child = childWidget;
  if (pageValue.shouldCache) return _cache[route] = _child;
  return _child;
}

RegExp _fixRegExp(String name) {
  final cleanRouteName = _cleanRouteName(name);
  const variableRegex = '[a-zA-Z0-9_-]+';
  final nameWithParameters = cleanRouteName.replaceAllMapped(
    RegExp(":($variableRegex)"),
    (match) {
      final groupName = match.group(1);
      return "(?<$groupName>[a-zA-Z0-9_\\\-\.,:;\+*^%\$@!]+)";
    },
  );
  final fixed = "^$nameWithParameters\$";
  return RegExp(fixed, caseSensitive: false);
}

String _cleanRouteName(String name) {
  name = name.trim();
  final parts = name.split("/");
  parts.removeWhere((value) => value == "");
  parts.map((value) {
    if (value.startsWith(":")) {
      return value;
    } else {
      return value.toLowerCase();
    }
  });
  name = parts.join("/");
  return name;
}

Map<String, String> _getArgs(
  String route,
  String pageKey,
  UiRoute pageValue,
) {
  final pageRoute = _fixRegExp(pageKey);
  final args = <String, String>{};
  for (final match in pageRoute.allMatches(_cleanRouteName(route))) {
    for (final group in match.groupNames) {
      args[group] = match.namedGroup(group) ?? '';
    }
  }
  return args;
}
