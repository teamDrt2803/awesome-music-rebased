import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class AppController extends GetxController {
  PageController pageController = PageController();
  final RxInt _currentIndex = RxInt(0);

  int get currentIndex => _currentIndex.value;

  void setCurrentIndex(int index) {
    _currentIndex.value = index;
    pageController.jumpToPage(index);
    if (index == 1) {
      Get.find<SongController>().fetchTrendingSearches();
    }
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
  Future<void> onReady() async {
    super.onReady();
  }
}
