import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/views/home/tabs/discover.dart';
import 'package:awesome_music_rebased/views/home/tabs/downloads.dart';
import 'package:awesome_music_rebased/views/home/tabs/search.dart';
import 'package:awesome_music_rebased/widgets/get_view_2.dart';
import 'package:awesome_music_rebased/widgets/mini_player.dart';
import 'package:awesome_music_rebased/widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView2<AppController, SongController> {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Scaffold(
          backgroundColor: Colors.white,
          bottomSheet: controller2.showMiniPlayer ? const MiniPlayer() : null,
          bottomNavigationBar: const NavigationBar(),
          body: Padding(
            padding: EdgeInsets.only(
              bottom: Get.find<SongController>().isPlaying ? 71 : 0,
            ),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: controller.pageController,
              onPageChanged: (index) => controller.currentIndex = index,
              children: const [
                DiscoverScreen(),
                SearchScreen(),
                SizedBox.shrink(),
                DownloadsScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}
