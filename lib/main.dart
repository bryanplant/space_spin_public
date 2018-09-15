import 'package:flutter/material.dart';

import 'package:space_spin/loadscreen.dart';

void main() {
  runApp(new MaterialApp(
    title: "Space Spin",
    onGenerateRoute: (RouteSettings settings) {
      if (settings.name == '/') {
        return new MaterialPageRoute<Null>(
          settings: settings,
          builder: (_) => new LoadScreen(),
          maintainState: false,
        );
      }
      return null;
    },
  ));
}
