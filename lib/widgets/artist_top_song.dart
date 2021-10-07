import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/widgets/cust_app_bar.dart';
import 'package:awesome_music_rebased/widgets/get_view_2.dart';
import 'package:awesome_music_rebased/widgets/mini_player.dart';
import 'package:awesome_music_rebased/widgets/navigation_bar.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ArtistTopSongs extends GetView2<SongController, DownloadController> {
  ArtistTopSongs({Key? key}) : super(key: key);
  final String token = Get.arguments as String;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        bottomSheet: !controller.showMiniPlayer
            ? const SizedBox.shrink()
            : const MiniPlayer(),
        bottomNavigationBar: const NavigationBar(),
        appBar: CustAppBar(
          title: '${controller.artistDetails.value[token]!.name} - Top Songs',
          action: PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    controller2.downloadArtistTopSongs(token);
                  },
                  child: const Text('Download All Song'),
                ),
                PopupMenuItem(
                  onTap: () {
                    controller2.deleteArtistTopSongs(token);
                  },
                  child: const Text('Delete All Song'),
                ),
                PopupMenuItem(
                  onTap: () {
                    controller.addItemsToQueue(
                      controller.artistDetails.value[token],
                    );
                  },
                  child: const Text('Add to queue'),
                ),
                const PopupMenuItem(
                  child: Text('Add to Favourites'),
                ),
              ];
            },
          ),
        ),
        body: ValueListenableBuilder<Box<dynamic>>(
          valueListenable: controller2.downloadBox.listenable(),
          builder: (_, box, __) {
            return ListView.builder(
              itemCount: controller.artistDetails.value[token]!.topSongs.length,
              itemBuilder: (context, index) {
                final song =
                    controller.artistDetails.value[token]!.topSongs[index];
                final downloadedIndex = box.values.toList().indexWhere(
                      (e) => e['mediaUrl'] == song.mediaURL,
                    );
                final downloadedSong = downloadedIndex != -1
                    ? DownloadedSong.fromMap(
                        box.getAt(downloadedIndex),
                      )
                    : null;
                final progress = downloadedSong?.downloadProgress ?? 0;
                final downloaded = downloadedIndex != -1 ||
                    downloadedSong?.status == DownloadTaskStatus.enqueued;
                return SingleSongTile(
                  songController: controller,
                  song: controller
                      .artistDetails.value[token]!.topSongs[index].mediaItem,
                  tileColor: Colors.transparent,
                  horizontalPadding: 0,
                  downloaded: downloaded,
                  progress: progress,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
