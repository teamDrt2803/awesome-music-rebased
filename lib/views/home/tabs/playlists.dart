import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/views/home/tabs/discover.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class PlaylistScreen extends GetView<DownloadController> {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [AlbumWidget(controller.downloads.value!)],
      ),
    );
  }
}
