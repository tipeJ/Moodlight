import 'package:flutter/material.dart';

abstract class LightConfiguration {
  String toJson();
}

class SolidLightConfiguration extends LightConfiguration {
  final Color color;

  SolidLightConfiguration({required this.color});

  @override
  String toJson() {
    return '{"mode": "solid", "color": [${color.red}, ${color.green}, ${color.blue}]}';
  }
}

class RainbowLightConfiguration extends LightConfiguration {
  final int waitMS;

  RainbowLightConfiguration({required this.waitMS});

  @override
  String toJson() {
    return '{"mode": "rainbow", "wait_ms": $waitMS}';
  }
}

class GradientPulseConfiguration extends LightConfiguration {
  final Color color1;
  final Color color2;
  final int steps;
  final int waitMS;

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
