import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class CustomMarquee extends StatelessWidget {
  const CustomMarquee({
    Key? key,
    required this.text,
    this.color = Colors.black,
    required this.style,
  }) : super(key: key);
  final String text;
  final Color color;
  final TextStyle? Function(TextTheme) style;
  @override
  Widget build(BuildContext context) {
    return Marquee(
      velocity: 30,
      blankSpace: 8,
      fadingEdgeEndFraction: 0.1,
      fadingEdgeStartFraction: 0.1,
      text: text,
      style: style(Theme.of(context).textTheme)
          ?.copyWith(letterSpacing: 1, color: color),
    );
  }
}
