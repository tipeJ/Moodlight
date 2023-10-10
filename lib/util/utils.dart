import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:moodlight/models/models.dart';

// Original code from https://blog.saikoled.com/post/44677718712/how-to-convert-from-hsi-to-rgb-white
// Converted to dart by me :)
RGBWColor hsi2rgbw(double H, double S, double I) {
  int r, g, b, w;
  double cos_h, cos_1047_h;
  H = H % 360; // Cycle H around to 0-360 degrees
  H = 3.14159 * H / 180; // Convert to radians.
  S = S > 0 ? (S < 1 ? S : 1) : 0; // Clamp S and I to the interval [0,1]
  I = I > 0 ? (I < 1 ? I : 1) : 0;

  if (H < 2.09439) {
    cos_h = cos(H);
    cos_1047_h = cos(1.047196667 - H);
    r = (S * 255 * I / 3 * (1 + cos_h / cos_1047_h)).round();
    g = (S * 255 * I / 3 * (1 + (1 - cos_h / cos_1047_h))).round();
    b = 0;
    w = (255 * (1 - S) * I).round();
  } else if (H < 4.188787) {
    H = H - 2.09439;
    cos_h = cos(H);
    cos_1047_h = cos(1.047196667 - H);
    g = (S * 255 * I / 3 * (1 + cos_h / cos_1047_h)).round();
    b = (S * 255 * I / 3 * (1 + (1 - cos_h / cos_1047_h))).round();
    r = 0;
    w = (255 * (1 - S) * I).round();
  } else {
    H = H - 4.188787;
    cos_h = cos(H);
    cos_1047_h = cos(1.047196667 - H);
    b = (S * 255 * I / 3 * (1 + cos_h / cos_1047_h)).round();
    r = (S * 255 * I / 3 * (1 + (1 - cos_h / cos_1047_h))).round();
    g = 0;
    w = (255 * (1 - S) * I).round();
  }
  return RGBWColor(red: r, green: g, blue: b, white: w);
}

// Extension on HSLColor to convert to RGBWColor
extension HSLColorExtension on HSLColor {
  RGBWColor toRGBWColor() {
    return hsi2rgbw(hue, saturation, lightness);
  }
}
