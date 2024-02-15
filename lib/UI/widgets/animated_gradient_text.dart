import 'package:flutter/material.dart';
import 'package:Moodlight/resources/colors.dart';

class GradientText extends StatefulWidget {
  final Widget text;
  const GradientText(this.text);

  @override
  _GradientTextState createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _controller.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              _colorTween(
                  MOODLIGHT_COLOR_1, MOODLIGHT_COLOR_3, _controller.value),
              _colorTween(
                  MOODLIGHT_COLOR_3, MOODLIGHT_COLOR_2, _controller.value),
            ],
            tileMode: TileMode.mirror,
          ).createShader(bounds),
          child: widget.text,
        );
      },
    );
  }

  Color _colorTween(Color c1, Color c2, double value) {
    return Color.lerp(c1, c2, value)!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
