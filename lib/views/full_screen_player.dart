import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/widgets/cust_app_bar.dart';
import 'package:awesome_music_rebased/widgets/lyrics_widget.dart';
import 'package:awesome_music_rebased/widgets/seek_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

class FullScreenPlayer extends GetWidget<SongController> {
  const FullScreenPlayer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final song = controller.currentSong.value!;
        final topColor = controller.topColor;
        final bottomColor = controller.bottomColor;
        final textColor = controller.textColor;
        return Scaffold(
          appBar: CustAppBar(
            bgColor: topColor,
            title: song.title,
            elementColor: textColor,
            onBackPressed: () {
              controller.showLyrics.value = {};
            },
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: (topColor != null)
                  ? LinearGradient(
                      colors: [topColor, bottomColor!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : null,
            ),
            child: Center(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  SizedBox(
                    width: Get.width,
                    height: Get.width - 28,
                    child: PageView.builder(
                      clipBehavior: Clip.none,
                      controller: controller.fullScreenThumbController,
                      itemCount: controller.queueStream.length,
                      onPageChanged: (index) {
                        controller.audioHandler.skipToQueueItem(index);
                      },
                      itemBuilder: (context, index) {
                        final song = controller.queueStream[index];
                        return FlipCard(
                          key: ValueKey(song.id),
                          flipOnTouch: song.extras!['hasLyrics'] as bool,
                          front: Hero(
                            tag: song.id,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    song.artUri.toString(),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          back: !(song.extras!['hasLyrics'] as bool)
                              ? const SizedBox.shrink()
                              : Stack(
                                  children: [
                                    LyricsWidget(
                                      textColor: textColor,
                                      lyrics: song.extras!['lyrics'] as String,
                                      bgColor: bottomColor,
                                    ),
                                    Positioned(
                                      right: 24,
                                      bottom: 0,
                                      child: IconButton(
                                        onPressed: () {
                                          Get.to(
                                            () => LyricsWidget(
                                              textColor: textColor,
                                              lyrics: song.extras!['lyrics']
                                                  as String,
                                              bgColor: bottomColor,
                                              fullScreen: true,
                                            ),
                                          );
                                        },
                                        icon: Icon(
                                          Icons.fullscreen,
                                          color: topColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    title: SizedBox(
                      height: 30,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, -0.5),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        child: Marquee(
                          velocity: 30,
                          blankSpace: 8,
                          fadingEdgeEndFraction: 0.1,
                          fadingEdgeStartFraction: 0.1,
                          text: song.title,
                          style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: textColor,
                                  ),
                        ),
                      ),
                    ),
                    subtitle: SizedBox(
                      height: 24,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, -0.5),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        child: Marquee(
                          velocity: 30,
                          blankSpace: 8,
                          fadingEdgeEndFraction: 0.1,
                          fadingEdgeStartFraction: 0.1,
                          text: (song.displaySubtitle == null ||
                                  song.displaySubtitle!.isEmpty)
                              ? song.album ?? song.artist ?? song.title
                              : song.displaySubtitle!,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1
                              ?.copyWith(letterSpacing: 1, color: textColor),
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_border),
                      color: textColor,
                    ),
                  ),
                  SeekBar(
                    duration: controller.currentSong.value!.duration!,
                    position: controller.currentSongPosition,
                    onChangeEnd: controller.handleSeek,
                    color: textColor,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            // controller.audioHandler
                            //     .setShuffleMode(AudioServiceShuffleMode.all);
                          },
                          icon: const Icon(Icons.shuffle_outlined),
                          color: textColor,
                          disabledColor: textColor?.withOpacity(0.35),
                        ),
                        IconButton(
                          onPressed: controller.audioPlayer.hasPrevious
                              ? () {
                                  controller.audioHandler.skipToPrevious();
                                }
                              : null,
                          icon: const Icon(Icons.skip_previous_outlined),
                          iconSize: 48,
                          color: textColor,
                          disabledColor: textColor?.withOpacity(0.35),
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
                                  valueColor: AlwaysStoppedAnimation(textColor),
                                )
                              : Icon(
                                  controller.isPlaying
                                      ? Icons.pause_circle_filled_outlined
                                      : Icons.play_circle_fill_outlined,
                                ),
                          iconSize: 72,
                          color: textColor,
                          disabledColor: textColor?.withOpacity(0.35),
                        ),
                        IconButton(
                          onPressed: controller.audioPlayer.hasNext
                              ? () {
                                  controller.audioHandler.skipToNext();
                                }
                              : null,
                          icon: const Icon(Icons.skip_next_outlined),
                          iconSize: 48,
                          color: textColor,
                          disabledColor: textColor?.withOpacity(0.35),
                        ),
                        IconButton(
                          onPressed: () {
                            controller.audioHandler
                                .setRepeatMode(AudioServiceRepeatMode.all);
                          },
                          icon: const Icon(Icons.repeat),
                          color: textColor,
                          disabledColor: textColor?.withOpacity(0.35),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 5),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
