import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDecorationDivider;
  final String? title;
  final bool showBackButton;
  final Widget? action;
  final Widget? middle;
  final dynamic result;
  final Function? onBackPressed;
  final bool overrideBackPressed;
  final Color? elementColor;
  final Color? bgColor;

  const CustAppBar({
    Key? key,
    this.showDecorationDivider = false,
    this.title,
    this.showBackButton = true,
    this.action,
    this.middle,
    this.result,
    this.onBackPressed,
    this.overrideBackPressed = false,
    this.elementColor,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            if (showDecorationDivider)
              const Divider(thickness: 10, color: colorBrandPrimary),
            Expanded(
              child: NavigationToolbar(
                trailing: action,
                leading: showBackButton
                    ? Hero(
                        tag: 'UniversalBackButtonTag',
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (!overrideBackPressed) Get.back(result: result);
                            if (onBackPressed != null) {
                              // ignore: prefer_null_aware_method_calls
                              onBackPressed!();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: elementColor,
                            ),
                          ),
                        ),
                      )
                    : null,
                middle: middle ??
                    ((title != null)
                        ? Text(
                            title!,
                            style:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                      color: elementColor,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (showDecorationDivider ? 10 : 0));
}
