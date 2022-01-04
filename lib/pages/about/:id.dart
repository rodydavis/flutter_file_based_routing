import 'package:flutter/material.dart';

import '../../generated.g.dart';

class AccountPage extends UiRoute<Map<String, String>> {
  @override
  loader(route, args) => args;

  @override
  Widget builder(
      BuildContext context, Map<String, String> data, Widget? child) {
    return Center(
      child: Text('ID: ${data['id']}'),
    );
  }
}
