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

  generate() {
    final sb = StringBuffer();
    sb.writeln('import \'dart:ui\';');
    sb.writeln('import \'package:flutter/material.dart\';');
    sb.writeln('');
    final allRoutes = routes.entries.toList();
    for (int i = 0; i < allRoutes.length; i++) {
      final entry = allRoutes[i];
      final route = entry.key;
      sb.writeln('import \'pages/${route}.dart\' as route${i};');
    }
    sb.writeln("import 'router.dart';");
    sb.writeln('');
    sb.writeln('class GeneratedRouter extends StatefulWidget {');
    sb.writeln('  const GeneratedRouter({Key? key}) : super(key: key);');
    sb.writeln('  @override');
    sb.writeln(
        '  _GeneratedRouterState createState() => _GeneratedRouterState();');
    sb.writeln('}');
    sb.writeln('');
    sb.writeln('class _GeneratedRouterState extends State<GeneratedRouter> {');
    sb.writeln(
        "  String route = PlatformDispatcher.instance.defaultRouteName;");
    sb.writeln("  final Map<String, UiRoute> pages = {};");
    sb.writeln("  Widget _page = Container();");
    sb.writeln('');
    sb.writeln('  @override');
    sb.writeln('  void initState() {');
    sb.writeln('    super.initState();');
    for (int i = 0; i < allRoutes.length; i++) {
      final entry = allRoutes[i];
      final route = "/" + entry.key;
      final name = entry.value;
      final fixedRoute = route.replaceAll('/index', '/');
      sb.writeln("    pages['$fixedRoute'] = route${i}.${name}();");
    }
    sb.writeln("    loadRoute();");
    sb.writeln('  }');
    sb.writeln('');
    sb.writeln("  void loadRoute() async {");
    sb.writeln("    for (final page in pages.entries) {");
    sb.writeln("      final pageRoute = RegExp(page.key);");
    sb.writeln("      if (pageRoute.hasMatch(route)) {");
    sb.writeln("        final pageValue = page.value;");
    sb.writeln("        final args = <String, String>{};");
    sb.writeln("        for (final match in pageRoute.allMatches(route)) {");
    sb.writeln("          for (final group in match.groupNames) {");
    sb.writeln("            args[group] = match.namedGroup(group) ?? '';");
    sb.writeln("          }");
    sb.writeln("        }");
    sb.writeln("        final data = await pageValue.loader(args);");
    sb.writeln(
        "        final _child = pageValue.builder(context, data, Container());");    
    sb.writeln("        if (mounted) setState(() => _page = _child);");
    sb.writeln("        return;");
    sb.writeln("      }");
    sb.writeln("    }");
    sb.writeln("  }");
    sb.writeln('');
    sb.writeln('  @override');
    sb.writeln('  Widget build(BuildContext context) {');
    sb.writeln('    return NotificationListener<RoutingRequest>(');
    sb.writeln('      onNotification: (notification) {');
    sb.writeln(
        '        if (mounted) setState(() => route = notification.route);');
    sb.writeln('        loadRoute();');
    sb.writeln('        return true;');
    sb.writeln('      },');
    sb.writeln('      child: _page,');
    sb.writeln('    );');
    sb.writeln('  }');
    sb.writeln('');
    sb.writeln('}');
    sb.writeln('');
    // for (int i = 0; i < allRoutes.length; i++) {
    //   final entry = allRoutes[i];
    //   final name = entry.value;
    //   if (name.contains('/')) continue;
    //   final related = allRoutes.where((e) => e.value.startsWith(name) && e.key != entry.key);
    //   sb.writeln('class ${name}Route extends StatelessWidget {');
    //   sb.writeln('  @override');
    //   sb.writeln('  Widget build(BuildContext context) {');
    //   sb.writeln('    // Related: ${related.length}');
    //   sb.writeln('    final page = route${i}.${name}();');
    //   sb.writeln('    return Container();');
    //   sb.writeln('  }');
    //   sb.writeln('}');
    //   sb.writeln('');
    // }
    if (!outFile.existsSync()) outFile.createSync(recursive: true);
    outFile.writeAsStringSync(sb.toString());
  }
}

// Root route -- about.dart
// Index route -- about/index.dart
// Named route -- about/data.dart
// Dynamic route -- about/$id.dart
