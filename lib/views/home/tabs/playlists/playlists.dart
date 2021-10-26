import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/controllers/user_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/views/home/tabs/downloads.dart';
import 'package:awesome_music_rebased/views/home/tabs/playlists/favourite_song_section.dart';
import 'package:awesome_music_rebased/views/home/tabs/playlists/saved_playlist_section.dart';
import 'package:awesome_music_rebased/widgets/get_view_2.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class PlaylistScreen extends GetView2<DownloadController, UserController> {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: controller2.tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 4,
              tabs: const [
                Tab(icon: Icon(Icons.download), text: 'Downloads'),
                Tab(icon: Icon(Icons.my_library_books), text: 'Playlists'),
                Tab(icon: Icon(Icons.favorite), text: 'Favourite'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: controller2.tabController,
                physics: const BouncingScrollPhysics(),
                children: const [
                  DownloadsScreen(),
                  PlaylistSection(),
                  FavouriteSongSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
