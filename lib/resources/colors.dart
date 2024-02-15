import 'package:flutter/material.dart';

const MOODLIGHT_COLOR_1 = Color.fromARGB(255, 255, 181, 172);
const MOODLIGHT_COLOR_2 = Color.fromARGB(255, 255, 123, 172);
const MOODLIGHT_COLOR_3 = Color.fromARGB(255, 32, 87, 172);

extension getMaterialColor on Color {
  MaterialColor get materialColor {
    return MaterialColor(value, {
      50: withAlpha(50),
      100: withAlpha(100),
      200: withAlpha(200),
      300: withAlpha(300),
      400: withAlpha(400),
      500: withAlpha(500),
      600: withAlpha(600),
      700: withAlpha(700),
      800: withAlpha(800),
      900: withAlpha(900),
    });
  }
}
