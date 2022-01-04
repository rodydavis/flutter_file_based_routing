import 'package:flutter/material.dart';

import '../generated.g.dart';

class AboutPage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: child,
    );
  }
}
