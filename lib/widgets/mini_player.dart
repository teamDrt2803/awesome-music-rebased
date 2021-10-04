import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:just_audio/just_audio.dart';

class MiniPlayer extends GetView<SongController> {
  const MiniPlayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final song = controller.currentSong.value;
        return song == null
            ? const SizedBox.shrink()
            : InkWell(
                onTap: () {
                  controller
                      .preparePageController(controller.currentPlayingIndex);
                  Get.toNamed(Routes.fullScreenPlayer);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: Divider.createBorderSide(context, width: 1.0),
                    ),
                  ),
                  child: ListTile(
                    isThreeLine: true,
                    leading: Hero(
                      tag: song.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          imageUrl: song.artUri.toString(),
                          placeholder: (_, __) => const Icon(
                            Icons.music_note_outlined,
                            color: colorBrandPrimary,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    subtitle: Text(
                      (song.displaySubtitle == null ||
                              song.displaySubtitle!.isEmpty)
                          ? song.album ?? song.title
                          : song.displaySubtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .button
                          ?.copyWith(color: Colors.grey),
                    ),
                    trailing: SizedBox(
                      width: Get.width * 0.3,
                      child: Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: controller.audioPlayer.hasPrevious
                                  ? () {
                                      controller.audioHandler.skipToPrevious();
                                    }
                                  : null,
                              icon: const Icon(Icons.skip_previous_outlined),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (controller.isPlaying) {
                                controller.audioHandler.pause();
                              } else {
                                controller.audioHandler.play();
                              }
                            },
                            icon: (controller
                                        .playBackStream.value.processingState ==
                                    ProcessingState.buffering)
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).iconTheme.color,
                                    ),
                                  )
                                : Icon(
                                    controller.isPlaying
                                        ? Icons.pause_outlined
                                        : Icons.play_arrow_outlined,
                                  ),
                            iconSize: 36,
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: controller.audioPlayer.hasNext
                                  ? () {
                                      controller.audioHandler.skipToNext();
                                    }
                                  : null,
                              icon: const Icon(Icons.skip_next_outlined),
                            ),
                          ),
                          // Expanded(
                          //   child: IconButton(
                          //     onPressed: () {
                          //       controller.audioHandler.stop();
                          //     },
                          //     icon: const Icon(Icons.stop_outlined),
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
