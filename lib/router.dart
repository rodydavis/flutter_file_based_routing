import 'dart:async';

import 'package:flutter/material.dart';

abstract class ApiRoute<T> {
  FutureOr<T?> loader(Map<String, String> args) {
    return null;
  }
}

abstract class UiRoute<T> extends ApiRoute<T> {
  Widget builder(BuildContext context, T data, Widget? child) {
    return child ?? Container();
  }

  navigate(BuildContext context, String route) {
    RoutingRequest(route).dispatch(context);
  }
}

class RoutingRequest extends Notification {
  final String route;
  RoutingRequest(this.route);
}
