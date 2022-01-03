import 'package:flutter/material.dart';

import '../router.dart';

enum NavIndex { side, bottom }

class RootPage extends UiRoute<Map<NavIndex, int>> {
  @override
  loader(route, args) {
    shouldCache = false;
    int sideIndex = 0;
    int bottomIndex = 0;
    if (route == '/' || route == '') {
      sideIndex = 0;
      bottomIndex = 0;
    } else if (route.startsWith('/about')) {
      sideIndex = 1;
      bottomIndex = 1;
    } else if (route == '/settings') {
      sideIndex = 2;
      bottomIndex = 2;
    }
    return {
      NavIndex.side: sideIndex,
      NavIndex.bottom: bottomIndex,
    };
  }

  @override
  Widget builder(BuildContext context, Map<NavIndex, int> data, Widget? child) {
    return LayoutBuilder(
      builder: (context, dimens) {
        final sideIndex = data[NavIndex.side] ?? 0;
        final drawer = ListView(
          children: [
            ListTile(
              selected: sideIndex == 0,
              title: const Text('Home'),
              onTap: () => RoutingRequest('/').dispatch(context),
              trailing: const Icon(Icons.home),
            ),
            ListTile(
              selected: sideIndex == 1,
              title: const Text('About'),
              onTap: () => RoutingRequest('/about/').dispatch(context),
              trailing: InkWell(
                child: const Icon(Icons.person_outline),
                onTap: () => RoutingRequest('/about/guest').dispatch(context),
              ),
            ),
            ListTile(
              selected: sideIndex == 2,
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
          body: child ?? Container(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: data[NavIndex.bottom] ?? 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'About',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                RoutingRequest('/').dispatch(context);
              } else if (index == 1) {
                RoutingRequest('/about/').dispatch(context);
              } else if (index == 2) {
                RoutingRequest('/settings').dispatch(context);
              }
            },
          ),
        );
      },
    );
  }
}
