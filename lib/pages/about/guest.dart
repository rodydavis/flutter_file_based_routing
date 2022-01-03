import 'package:flutter/material.dart';

import '../../router.dart';

class GuestPage extends UiRoute<void> {
  @override
  Widget builder(BuildContext context, void data, Widget? child) {
    return const Center(
      child: Text('Guest'),
    );
  }
}
