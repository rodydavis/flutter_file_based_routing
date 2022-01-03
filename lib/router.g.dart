import 'dart:ui';
import 'package:flutter/material.dart';

import 'pages/index.dart' as route0;
import 'pages/about.dart' as route1;
import 'pages/about/index.dart' as route2;
import 'pages/about/:id.dart' as route3;
import 'pages/about/guest.dart' as route4;
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
    pages['/'] = route0.HomePage();
    pages['/about'] = route1.AboutPage();
    pages['/about/'] = route2.AboutDetails();
    pages['/about/:id'] = route3.AccountPage();
    pages['/about/guest'] = route4.GuestPage();
    loadRoute();
  }

  void loadRoute() async {
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
        final data = await pageValue.loader(args);
        final _child = pageValue.builder(context, data, Container());
        if (route.split('/').length > 1) {
          
        }
        if (mounted) setState(() => _page = _child);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<RoutingRequest>(
      onNotification: (notification) {
        if (mounted) setState(() => route = notification.route);
        loadRoute();
        return true;
      },
      child: _page,
    );
  }

}

