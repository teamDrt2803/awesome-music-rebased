import 'dart:math' as math;

import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:flutter/widgets.dart';

class CircleProgressBar extends StatefulWidget {
  final Duration? animationDuration;
  final Color backgroundColor;
  final Color foregroundColor;
  final double value;
  final double aspectRatio;
  final double strokeWidth;

  const CircleProgressBar({
    Key? key,
    this.animationDuration,
    this.backgroundColor = colorBrandPrimaryLight,
    required this.foregroundColor,
    required this.value,
    this.aspectRatio = 1,
    this.strokeWidth = 6,
  }) : super(key: key);

  @override
  CircleProgressBarState createState() {
    return CircleProgressBarState();
  }
}

class CircleProgressBarState extends State<CircleProgressBar>
    with SingleTickerProviderStateMixin {
  static const transperant = Color(0x00000000);
  late AnimationController _controller;

  late Animation<double> curve;
  Tween<double>? valueTween;
  Tween<Color>? backgroundColorTween;
  Tween<Color>? foregroundColorTween;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration ?? const Duration(seconds: 1),
      vsync: this,
    );

    curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    valueTween = Tween<double>(
      begin: 0,
      end: widget.value,
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(CircleProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      final double beginValue = valueTween?.evaluate(curve) ?? oldWidget.value;

      valueTween = Tween<double>(
        begin: beginValue,
        end: widget.value,
      );

      if (oldWidget.backgroundColor != widget.backgroundColor) {
        backgroundColorTween = ColorTween(
          begin: oldWidget.backgroundColor,
          end: widget.backgroundColor,
        ) as Tween<Color>?;
      } else {
        backgroundColorTween = null;
      }

      if (oldWidget.foregroundColor != widget.foregroundColor) {
        foregroundColorTween = ColorTween(
          begin: oldWidget.foregroundColor,
          end: widget.foregroundColor,
        ) as Tween<Color>?;
      } else {
        foregroundColorTween = null;
      }

      _controller
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: AnimatedBuilder(
        animation: curve,
        child: Container(),
        builder: (context, child) {
          final backgroundColor =
              backgroundColorTween?.evaluate(curve) ?? widget.backgroundColor;
          final foregroundColor =
              foregroundColorTween?.evaluate(curve) ?? widget.foregroundColor;

          return CustomPaint(
            foregroundPainter: CircleProgressBarPainter(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              percentage: valueTween?.evaluate(curve) ?? 0,
              strokeWidth: widget.strokeWidth,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class CircleProgressBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  CircleProgressBarPainter({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.percentage,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Size constrainedSize =
        Size(size.width - strokeWidth, size.height - strokeWidth);

    final shortestSide =
        math.min(constrainedSize.width, constrainedSize.height);
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final radius = shortestSide / 2;

    final double startAngle = -(2 * math.pi * 0.25);
    final double sweepAngle = 2 * math.pi * percentage;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = oldDelegate as CircleProgressBarPainter;
    return oldPainter.percentage != percentage ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.foregroundColor != foregroundColor ||
        oldPainter.strokeWidth != strokeWidth;
  }
}
