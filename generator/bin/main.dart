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
    add("      child: MaterialApp(");
    add("          home: _page,");
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
    add(" abstract class ApiRoute<T> {");
    add("   FutureOr<T?> loader(String route, Map<String, String> args) {");
    add("     return null;");
    add("   }");
    add(" }");
    empty();
    add(" abstract class UiRoute<T> extends ApiRoute<T> {");
    add("   bool shouldCache = true;");
    add("   String currentRoute = '';");
    empty();
    add("   Widget builder(BuildContext context, T data, Widget? child) {");
    add("     return child ?? Container();");
    add("   }");
    empty();
    add("   navigate(BuildContext context, String route) {");
    add("     RoutingRequest(route).dispatch(context);");
    add("   }");
    add(" }");
    empty();
    add("abstract class _RoutingRequest extends Notification {}");
    add("class RoutingRequest extends _RoutingRequest {");
    add("  final String route;");
    add("  RoutingRequest(this.route);");
    add("}");
    add("class BackRequest extends _RoutingRequest {}");
    add("class ForwardRequest extends _RoutingRequest {}");
    empty();
    add(" MapEntry<UiRoute, Map<String, String>>? _getUiRoute(");
    add("   String route,");
    add("   Map<String, UiRoute> pages,");
    add(" ) {");
    add("   if (route == '/' || route.isEmpty) {");
    add("     final page = pages[route];");
    add("     if (page != null) return MapEntry(page, {});");
    add("     return null;");
    add("   }");
    add("   final match =");
    add("       pages.entries.toList().firstWhereOrNull((elem) => elem.key == route);");
    add("   if (match != null) return MapEntry(match.value, {});");
    empty();
    add("   for (final page in pages.entries.toList().reversed) {");
    add("     if (page.key == '/' || page.key.isEmpty) continue;");
    add("     if (page.key == route) return MapEntry(page.value, {});");
    add("     final pageRoute = _fixRegExp(page.key);");
    add("     final pageMatch = pageRoute.hasMatch(_cleanRouteName(route));");
    add("     if (pageMatch) {");
    add("       final args = _getArgs(route, page.key, page.value);");
    add("       return MapEntry(page.value, args);");
    add("     }");
    add("   }");
    add("   return null;");
    add(" }");
    empty();
    add(" final _cache = <String, Widget>{};");
    empty();
    add(" Future<Widget?> _getRoute(");
    add("   BuildContext context,");
    add("   String route,");
    add("   Map<String, UiRoute> pages,");
    add("   Widget? child, {");
    add("   bool subRoutes = true,");
    add("   String? currentRoute,");
    add(" }) async {");
    add("   if (_cache.containsKey(route)) return _cache[route];");
    add("   final page = _getUiRoute(route, pages);");
    add("   if (page == null) return null;");
    add("   final pageValue = page.key;");
    add("   final pageArgs = page.value;");
    add("   pageValue.currentRoute = currentRoute ?? route;");
    add("   final data = await pageValue.loader(pageValue.currentRoute, pageArgs);");
    add("   Widget _child = pageValue.builder(context, data, child);");
    add("   if (!subRoutes) return _child;");
    add("   String _route = route;");
    add("   while (_route.isNotEmpty) {");
    add("     final List<String> routeParts = _route.split('/');");
    add("     routeParts.removeLast();");
    add("     _route = routeParts.join('/');");
    add("     if (_route == '/' || _route.isEmpty) break;");
    add("     final childWidget = await _getRoute(");
    add("       context,");
    add("       _route,");
    add("       pages,");
    add("       _child,");
    add("       subRoutes: false,");
    add("       currentRoute: route,");
    add("     );");
    add("     if (childWidget == null) continue;");
    add("     _child = childWidget;");
    add("   }");
    add("   _route = '';");
    add("   final childWidget = await _getRoute(");
    add("     context,");
    add("     _route,");
    add("     pages,");
    add("     _child,");
    add("     subRoutes: false,");
    add("     currentRoute: route,");
    add("   );");
    add("   if (childWidget != null) _child = childWidget;");
    add("   if (pageValue.shouldCache) return _cache[route] = _child;");
    add("   return _child;");
    add(" }");
    empty();
    add(r"""
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
