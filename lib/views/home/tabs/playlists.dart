import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/controllers/user_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/views/home/tabs/downloads.dart';
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

class PlaylistSection extends GetView2<UserController, SongController> {
  const PlaylistSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: controller.favouritePlaylist.length,
        itemBuilder: (context, index) {
          final playlist = controller.favouritePlaylist[index];
          return GestureDetector(
            onTap: () {
              controller2.fetchAlbumDetails(playlist);
            },
            child: Container(
              height: 70,
              width: Get.width,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(imageUrl: playlist.image),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.title,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.subtitle1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          playlist.subtitle,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.bodyText1?.copyWith(
                                    color: Colors.grey,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: IconButton(
                      onPressed: () async {
                        await controller2.fetchAlbumDetails(
                          playlist,
                          navigate: false,
                        );
                        controller2.handleAlbumPlay(playlist.token);
                      },
                      icon: Obx(
                        () =>
                            controller2.isThisPlaylistPlaying(playlist.token) &&
                                    controller2.isPlaying
                                ? const Icon(Icons.pause_outlined)
                                : const Icon(Icons.play_arrow_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavouriteSongSection extends GetView2<UserController, SongController> {
  const FavouriteSongSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: controller.favouriteSongs.length,
        itemBuilder: (context, index) {
          return SingleSongTile(
            songController: controller2,
            song: controller.favouriteSongs[index].mediaItem,
          );
        },
      ),
    );
  }
}
