import 'dart:math';

import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:flutter/material.dart';

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Color? color;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    required this.duration,
    required this.position,
    required this.color,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final value = min(
      _dragValue ?? widget.position.inMilliseconds.toDouble(),
      widget.duration.inMilliseconds.toDouble(),
    );
    if (_dragValue != null && !_dragging) {
      _dragValue = null;
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Slider(
          activeColor: widget.color ?? colorBrandPrimary,
          inactiveColor: widget.color?.withOpacity(0.25) ??
              colorBrandPrimaryLight.withOpacity(0.25),
          max: widget.duration.inMilliseconds.toDouble(),
          value: value,
          onChanged: (value) {
            if (!_dragging) {
              _dragging = true;
            }
            setState(() {
              _dragValue = value;
            });
            switch (widget.onChanged) {
              case null:
                break;
              default:
                widget.onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            switch (widget.onChangeEnd) {
              case null:
                break;
              default:
                widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
            _dragging = false;
          },
        ),
        Positioned(
          right: 24.0,
          bottom: -8.0,
          left: 24.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                        .firstMatch("${widget.position}")
                        ?.group(1) ??
                    '$_remaining',
                style: Theme.of(context)
                    .textTheme
                    .button
                    ?.copyWith(color: widget.color),
              ),
              Text(
                '-${RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$').firstMatch("$_remaining")?.group(1) ?? '$_remaining'}',
                style: Theme.of(context)
                    .textTheme
                    .button
                    ?.copyWith(color: widget.color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}
