import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();
  final RxInt _currentIndex = RxInt(0);
  Rxn<double> fab = Rxn(320);

  int get currentIndex => _currentIndex.value;

  set currentIndex(int index) {
    if (Get.currentRoute != Routes.home) {
      Get.until((route) => Get.currentRoute == Routes.home);
    }
    _currentIndex.value = index;
    pageController.jumpToPage(index);
    fab.value = buildFab(reset: true);
  }

  double buildFab({bool reset = false}) {
    const double defaultTopMargin = 320.0;
    double top = defaultTopMargin;
    if (scrollController.hasClients && !reset) {
      final double offset = scrollController.offset;
      if (top - offset > 72.5) {
        top -= offset;
      } else {
        top = 72.5;
      }
    }
    return top;
  }

  String get appTitle {
    switch (currentIndex) {
      case 0:
        return 'Explore';
      case 1:
        return 'Search';
      case 2:
        return 'Playlist';
      default:
        return 'Downloads';
    }
  }

  @override
  void onReady() {
    super.onReady();
    fab.value = buildFab();
    scrollController.addListener(() {
      fab.value = buildFab();
    });
  }
}
