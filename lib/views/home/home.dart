import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/views/home/tabs/discover.dart';
import 'package:awesome_music_rebased/views/home/tabs/search.dart';
import 'package:awesome_music_rebased/widgets/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends GetView<AppController> {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        bottomSheet: Get.find<SongController>().showMiniPlayer
            ? const MiniPlayer()
            : null,
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          backgroundColor: Colors.white,
          currentIndex: controller.currentIndex,
          selectedItemColor: colorBrandPrimaryLight,
          unselectedItemColor: kSecondaryColor,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          onTap: controller.setCurrentIndex,
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
        // appBar: CustAppBar(
        //   title: controller.appTitle,
        //   showBackButton: false,
        // ),
        body: Padding(
          padding: EdgeInsets.only(
            bottom: Get.find<SongController>().isPlaying ? 71 : 0,
          ),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: controller.pageController,
            onPageChanged: controller.setCurrentIndex,
            children: const [
              DiscoverScreen(),
              SearchScreen(),
              DiscoverScreen(),
              DiscoverScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
