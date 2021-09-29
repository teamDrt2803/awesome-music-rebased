import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DiscoverScreen extends GetView<SongController> {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder<Box<dynamic>>(
        valueListenable:
            Get.find<DownloadController>().downloadBox.listenable(),
        builder: (_, box, __) {
          return Obx(
            () => ListView.builder(
              itemCount: controller.topSongList.length,
              itemBuilder: (context, index) {
                final song = controller.topSongList[index];
                final downloadedIndex = box.values
                    .toList()
                    .indexWhere((e) => e['mediaUrl'] == song.mediaItem.id);
                final downloadedSong = downloadedIndex != -1
                    ? DownloadedSong.fromMap(box.getAt(downloadedIndex))
                    : null;
                final progress = downloadedSong?.downloadProgress ?? 0;
                final downloaded = downloadedIndex != -1 ||
                    downloadedSong?.status == DownloadTaskStatus.enqueued;
                return SingleSongTile(
                  songController: controller,
                  song: (downloaded && progress == 100)
                      ? downloadedSong!.mediaItem
                      : controller.topSongList[index].mediaItem,
                  downloaded: downloaded,
                  progress: progress,
                  taskId: downloadedSong?.taskId,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
