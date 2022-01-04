import 'package:flutter/material.dart';

import 'generated.g.dart';

void main() {
  runApp(GeneratedApp(
    themeMode: ThemeMode.system,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
  ));
}
