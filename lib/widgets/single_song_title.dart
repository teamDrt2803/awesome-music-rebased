import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lottie/lottie.dart';

import 'progress_indicator.dart';

class SingleSongTile extends GetView<DownloadController> {
  const SingleSongTile({
    Key? key,
    required this.songController,
    required this.song,
    this.downloaded = false,
    this.progress = 100,
    this.taskId,
    this.horizontalPadding = 12,
    this.tileColor = Colors.white,
  }) : super(key: key);

  final SongController songController;
  final MediaItem song;
  final bool downloaded;
  final int progress;
  final String? taskId;
  final double horizontalPadding;
  final Color tileColor;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isPlaying = songController.currentSong.value?.id == song.id;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 2),
          decoration: BoxDecoration(
            color: tileColor,
          ),
          child: ListTile(
            isThreeLine: true,
            onTap: () async {
              if (!songController.queueStream
                  .any((element) => element.id == song.id)) {
                await songController.audioHandler.addQueueItem(song);
                songController.playSong(song.id);
              } else {
                songController.playSong(song.id);
              }
            },
            minLeadingWidth: 48,
            leading: SizedBox(
              height: 56,
              width: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: CachedNetworkImage(
                  imageUrl: song.artUri.toString(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPlaying ? colorBrandPrimary : null,
              ),
            ),
            subtitle: Text(
              (song.displaySubtitle == null ||
                      (song.displaySubtitle ?? '').isEmpty)
                  ? song.title
                  : song.displaySubtitle ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: (downloaded && progress == 0)
                ? IconButton(
                    onPressed: () {},
                    icon: LottieBuilder.asset(
                      'assets/lottie/downloading.json',
                      frameRate: FrameRate(60),
                      height: 30,
                      width: 30,
                    ),
                  )
                : (downloaded && progress > 0 && progress < 100)
                    ? CircleProgressBar(
                        value: progress / 100,
                        backgroundColor:
                            colorBrandPrimaryLight.withOpacity(0.2),
                        foregroundColor: colorBrandPrimary,
                        aspectRatio: 0.7,
                        strokeWidth: 5.5,
                      )
                    : (downloaded && progress == 100)
                        ? IconButton(
                            onPressed: () => controller.delete(
                              taskId ?? song.extras!['taskId']! as String,
                            ),
                            icon: const Icon(Icons.delete_outline),
                          )
                        : IconButton(
                            onPressed: () => controller.download(song),
                            icon: const Icon(Icons.download_outlined),
                          ),
          ),
        );
      },
    );
  }
}
