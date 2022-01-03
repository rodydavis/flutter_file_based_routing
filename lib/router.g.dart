import 'dart:ui';
import 'package:flutter/material.dart';

import 'pages/about.dart' as route0;
import 'pages/about/:id.dart' as route1;
import 'pages/about/guest.dart' as route2;
import 'pages/about/index.dart' as route3;
import 'pages/index.dart' as route4;
import 'pages/root.dart' as route5;
import 'pages/settings.dart' as route6;
import 'router.dart';

class GeneratedRouter extends StatefulWidget {
  const GeneratedRouter({Key? key}) : super(key: key);
  @override
  _GeneratedRouterState createState() => _GeneratedRouterState();
}

class _GeneratedRouterState extends State<GeneratedRouter> {
  String route = PlatformDispatcher.instance.defaultRouteName;
  final Map<String, UiRoute> pages = {};
  Widget _page = Container();

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
    loadRoute();
  }

  void loadRoute() async {
     Widget? _child = await getRoute(context, route, pages, null);
     if (_child == null) {
       final _unknown = await getRoute(context, '404', pages, null);
       _child = _unknown ?? Container();
     }
     if (mounted) setState(() => _page = _child!);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<RoutingRequest>(
      onNotification: (notification) {
        if (mounted) setState(() => route = notification.route);
        loadRoute();
        return true;
      },
      child: MaterialApp(
          home: _page,
          key: ValueKey(route),
          debugShowCheckedModeBanner: false,
          restorationScopeId: route,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
      ),
    );
  }

}

