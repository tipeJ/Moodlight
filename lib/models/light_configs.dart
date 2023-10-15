import 'package:flutter/material.dart';

abstract class LightConfiguration {
  String toJson();
  String get name;
  String get description;
}

class SolidLightConfiguration extends LightConfiguration {
  String get name => 'Solid';
  String get description => 'Solid color';
  Color color;

  static SolidLightConfiguration get defaultConfig =>
      SolidLightConfiguration(color: Colors.black);

  SolidLightConfiguration({required this.color});

  @override
  String toJson() {
    return '{"mode": "solid", "color": [${color.red}, ${color.green}, ${color.blue}]}';
  }
}

class RainbowLightConfiguration extends LightConfiguration {
  String get name => 'Rainbow';
  String get description =>
      'Rotating rainbow. Speed can be adjusted with the "Wait time" slider';
  int waitMS;
  static RainbowLightConfiguration get defaultConfig =>
      RainbowLightConfiguration(waitMS: 10);

  RainbowLightConfiguration({required this.waitMS});

  @override
  String toJson() {
    return '{"mode": "rainbow", "wait_ms": $waitMS}';
  }
}

class GradientPulseConfiguration extends LightConfiguration {
  String get name => 'Gradient Pulse';
  String get description =>
      'Pulse between two colors. Speed can be adjusted with the "Wait time" slider and the number of steps with the "Steps" slider';

  static GradientPulseConfiguration get defaultConfig =>
      GradientPulseConfiguration(
          color1: Colors.red, color2: Colors.blue, steps: 10, waitMS: 10);
  Color color1;
  Color color2;
  int steps;
  int waitMS;

  GradientPulseConfiguration(
      {required this.color1,
      required this.color2,
      required this.steps,
      required this.waitMS});

  @override
  String toJson() {
    return '{"mode": "gradientpulse", "c1": [${color1.red}, ${color1.green}, ${color1.blue}], "c2": [${color2.red}, ${color2.green}, ${color2.blue}], "wait_ms": $waitMS, "steps": $steps}';
  }
}
