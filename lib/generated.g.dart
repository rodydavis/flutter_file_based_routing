import 'dart:ui';
import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/about.dart' as route0;
import 'pages/about/:id.dart' as route1;
import 'pages/about/guest.dart' as route2;
import 'pages/about/index.dart' as route3;
import 'pages/index.dart' as route4;
import 'pages/root.dart' as route5;
import 'pages/settings.dart' as route6;

class GeneratedApp extends StatefulWidget {
  const GeneratedApp({
     Key? key,
     this.theme,
     this.darkTheme,
     this.themeMode,
  }) : super(key: key);
  final ThemeData? theme, darkTheme;
  final ThemeMode? themeMode;
  @override
  _GeneratedAppState createState() => _GeneratedAppState();
}

class _GeneratedAppState extends State<GeneratedApp> {
  String route = PlatformDispatcher.instance.defaultRouteName;
  final Map<String, UiRoute> pages = {};
  Widget _page = Container();
  final historyRoutes = <String>[];
  final futureRoutes = <String>[];

  @override
  void initState() {
    super.initState();
    pages['/about'] = route0.AboutPage();
    pages['/about/:id'] = route1.AccountPage();
    pages['/about/guest'] = route2.GuestPage();
    pages['/about/'] = route3.AboutDetails();
    pages['/'] = route4.HomePage();
    pages[''] = route5.RootPage();
    pages['/settings'] = route6.SettingsPage();
    SystemNavigator.selectSingleEntryHistory();
    loadRoute();
  }

  void loadRoute() async {
     Widget? _child = await _getRoute(context, route, pages, null);
     if (_child == null) {
       final _unknown = await _getRoute(context, '404', pages, null);
       _child = _unknown ?? Container();
     }
     if (mounted) setState(() => _page = _child!);
     SystemNavigator.routeInformationUpdated(location: route);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<_RoutingRequest>(
      onNotification: (notification) {
        if (notification is RoutingRequest) {
          historyRoutes.add(notification.route);
          futureRoutes.clear();
          if (mounted) setState(() => route = notification.route);
          loadRoute();
        }
        if (notification is BackRequest) {
          if (historyRoutes.isNotEmpty) {
            futureRoutes.add(historyRoutes.removeLast());
            if (mounted) {
              setState(() {
                route = historyRoutes.isNotEmpty ? historyRoutes.last : '';
              });
            }
            loadRoute();
          }
        }
        if (notification is ForwardRequest) {
          if (futureRoutes.isNotEmpty) {
            historyRoutes.add(futureRoutes.removeLast());
            if (mounted) {
              setState(() {
                route = historyRoutes.isNotEmpty ? historyRoutes.last : '';
              });
            }
            loadRoute();
          }
        }
        return true;
      },
      child: MaterialApp.router(
          routerDelegate: _RouterDelegate(_page),
          routeInformationParser: _RouteInformationParser(),
          key: ValueKey(route),
          debugShowCheckedModeBanner: false,
          restorationScopeId: route,
          theme: widget.theme,
          darkTheme: widget.darkTheme,
          themeMode: widget.themeMode,
      ),
    );
  }

}

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

    abstract class _RoutingRequest extends Notification {}

    class RoutingRequest extends _RoutingRequest {
      final String route;
      RoutingRequest(this.route);
    }

    class BackRequest extends _RoutingRequest {}

    class ForwardRequest extends _RoutingRequest {}

    final _cache = <String, Widget>{};

    MapEntry<UiRoute, Map<String, String>>? _getUiRoute(
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

    Future<Widget?> _getRoute(
      BuildContext context,
      String route,
      Map<String, UiRoute> pages,
      Widget? child, {
      bool subRoutes = true,
      String? currentRoute,
    }) async {
      if (_cache.containsKey(route)) return _cache[route];
      final page = _getUiRoute(route, pages);
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
        final childWidget = await _getRoute(
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
      final childWidget = await _getRoute(
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

    class _RouterDelegate extends RouterDelegate<Object>
        with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
      _RouterDelegate(this.child);
      final Widget child;

      @override
      Widget build(BuildContext context) => child;

      @override
      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

      @override
      Future<void> setNewRoutePath(configuration) async {}
    }

    class _RouteInformationParser extends RouteInformationParser<Object> {
      @override
      Future<Object> parseRouteInformation(RouteInformation routeInformation) {
        return Future<Object>.value(routeInformation.location);
      }
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
      final parts = name.split('/');
      parts.removeWhere((value) => value == "");
      parts.map((value) {
        if (value.startsWith(':')) {
          return value;
        } else {
          return value.toLowerCase();
        }
      });
      name = parts.join('/');
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
    

