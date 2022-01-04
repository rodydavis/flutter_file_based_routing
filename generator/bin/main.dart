import 'dart:io';

import 'package:flutter_ast/flutter_ast.dart';

final dir = Directory.current;
final Directory pagesDir = Directory(dir.path + '/lib/pages/');
final File outFile = File(dir.path + '/lib/generated.g.dart');

void main(List<String> args) {
  final router = GeneratedRouter();
  final files = pagesDir
      .listSync(recursive: true)
      .where((f) => f is File && f.path.endsWith('.dart'));
  for (final file in files) {
    router.analyzeFile(file);
  }
  router.debug();
  router.generate();
}

class GeneratedRouter {
  final Map<String, String> routes = {};
  final sb = StringBuffer();

  void analyzeFile(File file) {
    if (!file.existsSync()) return;
    final content = file.readAsStringSync();
    final source = parseSource(content);
    for (final kClass in source.file.classes) {
      final valid = kClass.extendsClause.contains('UiRoute');
      if (valid) {
        final name = kClass.name;
        final route =
            file.path.replaceFirst(pagesDir.path, '').split('.').first;
        routes[route] = name;
      }
    }
  }

  debug() {
    print('Router:');
    print('  routes:');
    for (final route in routes.entries) {
      print('    ${route.key}: ${route.value}');
    }
  }

  add(String value) => sb.writeln(value);
  empty() => sb.writeln();

  generate() {
    sb.clear();
    add('import \'dart:ui\';');
    add('import \'dart:async\';');
    add('import \'package:collection/collection.dart\';');
    add('import \'package:flutter/material.dart\';');
    add('import \'package:flutter/services.dart\';');
    empty();
    final allRoutes = routes.entries.toList();
    allRoutes.sort((a, b) => a.key.compareTo(b.key));
    for (int i = 0; i < allRoutes.length; i++) {
      final entry = allRoutes[i];
      final route = entry.key;
      add('import \'pages/${route}.dart\' as route${i};');
    }
    empty();
    add('class GeneratedApp extends StatefulWidget {');
    add('  const GeneratedApp({');
    add('     Key? key,');
    add('     this.theme,');
    add('     this.darkTheme,');
    add('     this.themeMode,');
    add('  }) : super(key: key);');
    add('  final ThemeData? theme, darkTheme;');
    add('  final ThemeMode? themeMode;');
    add('  @override');
    add('  _GeneratedAppState createState() => _GeneratedAppState();');
    add('}');
    empty();
    add('class _GeneratedAppState extends State<GeneratedApp> {');
    add("  String route = PlatformDispatcher.instance.defaultRouteName;");
    add("  final Map<String, UiRoute> pages = {};");
    add("  Widget _page = Container();");
    add("  final historyRoutes = <String>[];");
    add("  final futureRoutes = <String>[];");
    empty();
    add('  @override');
    add('  void initState() {');
    add('    super.initState();');
    for (int i = 0; i < allRoutes.length; i++) {
      final entry = allRoutes[i];
      final route = "/" + entry.key;
      final name = entry.value;
      final fixedRoute = route.replaceAll('/index', '/');
      if (fixedRoute == '/root') {
        add("    pages[''] = route${i}.${name}();");
        continue;
      }
      add("    pages['$fixedRoute'] = route${i}.${name}();");
    }
    add("    SystemNavigator.selectSingleEntryHistory();");
    add("    loadRoute();");
    add('  }');
    empty();
    add("  void loadRoute() async {");
    add("     Widget? _child = await _getRoute(context, route, pages, null);");
    add("     if (_child == null) {");
    add("       final _unknown = await _getRoute(context, '404', pages, null);");
    add("       _child = _unknown ?? Container();");
    add("     }");
    add("     if (mounted) setState(() => _page = _child!);");
    add("     SystemNavigator.routeInformationUpdated(location: route);");
    add("  }");
    empty();
    add('  @override');
    add('  Widget build(BuildContext context) {');
    add('    return NotificationListener<_RoutingRequest>(');
    add('      onNotification: (notification) {');
    add("        if (notification is RoutingRequest) {");
    add("          historyRoutes.add(notification.route);");
    add("          futureRoutes.clear();");
    add("          if (mounted) setState(() => route = notification.route);");
    add("          loadRoute();");
    add("        }");
    add("        if (notification is BackRequest) {");
    add("          if (historyRoutes.isNotEmpty) {");
    add("            futureRoutes.add(historyRoutes.removeLast());");
    add("            if (mounted) {");
    add("              setState(() {");
    add("                route = historyRoutes.isNotEmpty ? historyRoutes.last : '';");
    add("              });");
    add("            }");
    add("            loadRoute();");
    add("          }");
    add("        }");
    add("        if (notification is ForwardRequest) {");
    add("          if (futureRoutes.isNotEmpty) {");
    add("            historyRoutes.add(futureRoutes.removeLast());");
    add("            if (mounted) {");
    add("              setState(() {");
    add("                route = historyRoutes.isNotEmpty ? historyRoutes.last : '';");
    add("              });");
    add("            }");
    add("            loadRoute();");
    add("          }");
    add("        }");
    add('        return true;');
    add('      },');
    add("      child: MaterialApp.router(");
    add("          routerDelegate: _RouterDelegate(_page),");
    add("          routeInformationParser: _RouteInformationParser(),");
    add("          builder: (context, child) {");
    add("             return Overlay(");
    add("               initialEntries: [");
    add("                 OverlayEntry(builder: (context) => child ?? Container()),");
    add("               ],");
    add("             );");
    add("          },");
    add("          key: ValueKey(route),");
    add("          debugShowCheckedModeBanner: false,");
    add("          restorationScopeId: route,");
    add("          theme: widget.theme,");
    add("          darkTheme: widget.darkTheme,");
    add("          themeMode: widget.themeMode,");
    add("      ),");
    add('    );');
    add('  }');
    empty();
    add('}');
    empty();
    add(r"""
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
    """);
    empty();
    if (!outFile.existsSync()) outFile.createSync(recursive: true);
    outFile.writeAsStringSync(sb.toString());
  }
}

// add(" Root route -- about.dart");
// add(" Index route -- about/index.dart");
// add(" Named route -- about/data.dart");
// add(" Dynamic route -- about/$id.dart");
