import 'package:flutter/material.dart';

class RGBWColor {
  final int red;
  final int green;
  final int blue;
  final int white;

  RGBWColor(
      {required this.red,
      required this.green,
      required this.blue,
      required this.white});

  Map<String, dynamic> toJson() {
    return {
      'red': red,
      'green': green,
      'blue': blue,
      'white': white,
    };
  }
}

class SolidLightConfiguration {
  final HSLColor color;

  SolidLightConfiguration({required this.color});
}
