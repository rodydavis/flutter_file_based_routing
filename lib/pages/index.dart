import 'package:flutter/material.dart';

import '../router.dart';

class HomePage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return const FlutterLogo();
  }
}
