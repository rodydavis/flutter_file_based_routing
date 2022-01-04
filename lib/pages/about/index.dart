import 'package:flutter/material.dart';

import '../../generated.g.dart';

class AboutDetails extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return const Center(
      child: Text('About'),
    );
  }
}
