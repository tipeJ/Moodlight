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
