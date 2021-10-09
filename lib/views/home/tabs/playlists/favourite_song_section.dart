import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/controllers/user_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/widgets/get_view_2.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
