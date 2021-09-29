import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DownloadsScreen extends GetView<DownloadController> {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<dynamic>>(
      valueListenable: controller.downloadBox.listenable(),
      builder: (context, box, _) {
        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final variable = DownloadedSong.fromMap(
              box.getAt(index),
            );
            return SingleSongTile(
              songController: Get.find<SongController>(),
              song: variable.mediaItem,
              downloaded: true,
              progress: variable.downloadProgress,
            );
          },
        );
      },
    );
  }
}
