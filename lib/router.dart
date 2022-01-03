import 'dart:async';

import 'package:flutter/material.dart';

abstract class ApiRoute<T> {
  FutureOr<T?> loader(Map<String, String> args) {
    return null;
  }
}

abstract class UiRoute<T> extends ApiRoute<T> {
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
    String route, Map<String, UiRoute> pages) {
  for (final page in pages.entries) {
    final pageRoute = RegExp(page.key);
    if (pageRoute.hasMatch(route)) {
      final pageValue = page.value;
      final args = <String, String>{};
      for (final match in pageRoute.allMatches(route)) {
        for (final group in match.groupNames) {
          args[group] = match.namedGroup(group) ?? '';
        }
      }
      return MapEntry(pageValue, args);
    }
  }
  return null;
}

Future<Widget?> getRoute(
  BuildContext context,
  String route,
  Map<String, UiRoute> pages,
  Widget? child, [
  bool subRoutes = true,
]) async {
  final page = getUiRoute(route, pages);
  if (page == null) return null;
  final pageValue = page.key;
  final pageArgs = page.value;
  final data = await pageValue.loader(pageArgs);
  Widget _child = pageValue.builder(context, data, child);
  if (!subRoutes) return _child;
  String _route = route;
  while (_route.isNotEmpty) {
    final lastIndex = _route.lastIndexOf('/');
    if (lastIndex == -1) break;
    _route = _route.substring(0, lastIndex);
    final childWidget = await getRoute(context, _route, pages, _child, false);
    if (childWidget == null) continue;
    _child = childWidget;
  }
  _route = '';
  final childWidget = await getRoute(context, _route, pages, _child, false);
  if (childWidget != null) _child = childWidget;
  return _child;
}
