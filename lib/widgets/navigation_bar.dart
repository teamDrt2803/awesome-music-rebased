import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationBar extends GetView<AppController> {
  const NavigationBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'AppBottomNavigationBar',
      child: Obx(
        () => BottomNavigationBar(
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
      ),
    );
  }
}
