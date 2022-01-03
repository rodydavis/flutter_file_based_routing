import 'dart:io';

import 'package:flutter_ast/flutter_ast.dart';

final dir = Directory.current;
final Directory pagesDir = Directory(dir.path + '/lib/pages/');
final File outFile = File(dir.path + '/lib/router.g.dart');

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
    add('import \'package:flutter/material.dart\';');
    empty();
    final allRoutes = routes.entries.toList();
    allRoutes.sort((a, b) => a.key.compareTo(b.key));
    for (int i = 0; i < allRoutes.length; i++) {
      final entry = allRoutes[i];
      final route = entry.key;
      add('import \'pages/${route}.dart\' as route${i};');
    }
    add("import 'router.dart';");
    empty();
    add('class GeneratedRouter extends StatefulWidget {');
    add('  const GeneratedRouter({Key? key}) : super(key: key);');
    add('  @override');
    add('  _GeneratedRouterState createState() => _GeneratedRouterState();');
    add('}');
    empty();
    add('class _GeneratedRouterState extends State<GeneratedRouter> {');
    add("  String route = PlatformDispatcher.instance.defaultRouteName;");
    add("  final Map<String, UiRoute> pages = {};");
    add("  Widget _page = Container();");
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
    add("     Widget? _child = await getRoute(context, route, pages, null);");
    add("     if (_child == null) {");
    add("       final _unknown = await getRoute(context, '404', pages, null);");
    add("       _child = _unknown ?? Container();");
    add("     }");
    add("     if (mounted) setState(() => _page = _child!);");
    add("  }");
    empty();
    add('  @override');
    add('  Widget build(BuildContext context) {');
    add('    return NotificationListener<RoutingRequest>(');
    add('      onNotification: (notification) {');
    add('        if (mounted) setState(() => route = notification.route);');
    add('        loadRoute();');
    add('        return true;');
    add('      },');
    add("      child: MaterialApp(");
    add("          home: _page,");
    add("          key: ValueKey(route),");
    add("          debugShowCheckedModeBanner: false,");
    add("          restorationScopeId: route,");
    add("          theme: ThemeData.light(),");
    add("          darkTheme: ThemeData.dark(),");
    add("          themeMode: ThemeMode.system,");
    add("      ),");
    add('    );');
    add('  }');
    empty();
    add('}');
    empty();
    if (!outFile.existsSync()) outFile.createSync(recursive: true);
    outFile.writeAsStringSync(sb.toString());
  }
}

// Root route -- about.dart
// Index route -- about/index.dart
// Named route -- about/data.dart
// Dynamic route -- about/$id.dart
