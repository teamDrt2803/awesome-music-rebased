import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/views/home/tabs/discover.dart';
import 'package:awesome_music_rebased/views/home/tabs/downloads.dart';
import 'package:awesome_music_rebased/views/home/tabs/search.dart';
import 'package:awesome_music_rebased/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<AppController> {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final songController = Get.find<SongController>();
        debugPrint(
          'Value of ShowMiniPlayer is ${songController.showMiniPlayer}',
        );
        return Scaffold(
          backgroundColor: Colors.white,
          bottomSheet:
              songController.showMiniPlayer ? const MiniPlayer() : null,
          bottomNavigationBar: BottomNavigationBar(
            elevation: 10,
            backgroundColor: Colors.white,
            currentIndex: controller.currentIndex,
            selectedItemColor: colorBrandPrimaryLight,
            unselectedItemColor: kSecondaryColor,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            onTap: (index) => controller.currentIndex = index,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.music_note_outlined),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.playlist_play_rounded),
                label: 'Playlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.download_outlined),
                label: 'Downloads',
              ),
            ],
          ),
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
