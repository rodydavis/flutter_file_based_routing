import 'package:flutter/material.dart';

import '../router.dart';

class RootPage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return Scaffold(
      drawer: Drawer(
        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('$index'),
              onTap: () => RoutingRequest('/about/$index').dispatch(context),
            );
          },
        ),
      ),
      body: child,
    );
  }
}
