import 'package:flutter/material.dart';

import '../router.dart';

class SettingsPage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: child,
    );
  }
}
