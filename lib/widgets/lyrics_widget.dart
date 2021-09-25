import 'package:flutter/material.dart';

import 'cust_app_bar.dart';

class LyricsWidget extends StatelessWidget {
  const LyricsWidget({
    Key? key,
    required this.textColor,
    required this.bgColor,
    required this.lyrics,
    this.fullScreen = false,
  }) : super(key: key);

  final Color? textColor;
  final Color? bgColor;
  final String lyrics;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    return fullScreen
        ? Scaffold(
            backgroundColor: textColor,
            appBar: CustAppBar(title: 'Lyrics', elementColor: bgColor),
            body: SafeArea(
              bottom: false,
              child: _buildWidget(context),
            ),
          )
        : _buildWidget(context);
  }

  Hero _buildWidget(BuildContext context) {
    return Hero(
      tag: lyrics,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: textColor,
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Text(
              lyrics,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: bgColor),
            ),
          ),
        ),
      ),
    );
  }
}
