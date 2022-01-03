import 'package:flutter/material.dart';

import '../router.dart';

class RootPage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return LayoutBuilder(
      builder: (context, dimens) {
        final drawer = ListView(
          children: [
            ListTile(
              title: const Text('Home'),
              onTap: () => RoutingRequest('/').dispatch(context),
              trailing: const Icon(Icons.home),
            ),
            ListTile(
              title: const Text('About'),
              onTap: () => RoutingRequest('/about/').dispatch(context),
              trailing: InkWell(
                child: const Icon(Icons.person_outline),
                onTap: () => RoutingRequest('/about/guest').dispatch(context),
              ),
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () => RoutingRequest('/settings').dispatch(context),
              trailing: const Icon(Icons.settings),
            ),
          ],
        );
        if (dimens.maxWidth > 720) {
          return Row(
            children: [
              SizedBox(
                width: 300,
                child: Scaffold(
                  appBar: AppBar(title: const Text('Root')),
                  body: drawer,
                ),
              ),
              Expanded(child: child ?? Container()),
            ],
          );
        }
        return Scaffold(
          drawer: Drawer(child: drawer),
          body: child,
        );
      },
    );
  }
}
