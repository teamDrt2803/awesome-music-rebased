import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class DiscoverScreen extends GetView<SongController> {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: controller.topSongList.length,
        itemBuilder: (context, index) =>
            SingleSongTile(songController: controller, index: index),
      ),
    );
  }
}
