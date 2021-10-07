import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/widgets/get_view_2.dart';
import 'package:awesome_music_rebased/widgets/mini_player.dart';
import 'package:awesome_music_rebased/widgets/navigation_bar.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';

class AlbumScreen
    extends GetView3<SongController, DownloadController, AppController> {
  AlbumScreen({Key? key}) : super(key: key);

  final token = Get.arguments as String;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        controller3.fab.value = controller3.buildFab(reset: true);
        return Future.value(true);
      },
      child: Obx(
        () {
          final album = controller.playlists.value[token];
          return Scaffold(
            bottomSheet: controller.showMiniPlayer ? const MiniPlayer() : null,
            bottomNavigationBar: const NavigationBar(),
            body: Padding(
              padding:
                  EdgeInsets.only(bottom: controller.showMiniPlayer ? 90 : 0),
              child: controller.fetchingAlbumDetails.value
                  ? const Center(child: CircularProgressIndicator())
                  : album == null
                      ? const SizedBox.shrink()
                      : ValueListenableBuilder<Box<dynamic>>(
                          valueListenable: controller2.downloadBox.listenable(),
                          builder: (_, box, __) {
                            return Stack(
                              children: [
                                CustomScrollView(
                                  controller: controller3.scrollController,
                                  slivers: [
                                    SliverAppBar(
                                      expandedHeight: 300,
                                      stretch: true,
                                      pinned: true,
                                      flexibleSpace: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.topCenter,
                                            colors: [
                                              controller.albumBottomColor!,
                                              controller.albumTopColor!
                                            ],
                                          ),
                                        ),
                                        child: FlexibleSpaceBar(
                                          titlePadding: const EdgeInsets.only(
                                            left: 36,
                                            bottom: 16,
                                          ),
                                          title: Text(
                                            album.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: controller.albumTextColor,
                                            ),
                                          ),
                                          stretchModes: const <StretchMode>[
                                            StretchMode.zoomBackground,
                                            StretchMode.fadeTitle,
                                          ],
                                          centerTitle: true,
                                          background: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: CachedNetworkImage(
                                                  imageUrl: album.highResImage,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.center,
                                                    colors: <Color>[
                                                      Color(0x60000000),
                                                      Color(0x00000000),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SliverPadding(
                                      padding: EdgeInsets.only(top: 16),
                                    ),
                                    SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (contex, index) {
                                          if (index == 0) {
                                            return SizedBox(
                                              height: 48,
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.favorite_outline,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        controller2
                                                            .downloadPlaylist(
                                                          token,
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.download_outlined,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        controller2
                                                            .deletePlaylist(
                                                          token,
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .delete_outline_outlined,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                          final song = album.songs[index - 1];
                                          final downloadedIndex =
                                              box.values.toList().indexWhere(
                                                    (e) =>
                                                        e['mediaUrl'] ==
                                                        song.mediaURL,
                                                  );
                                          final downloadedSong =
                                              downloadedIndex != -1
                                                  ? DownloadedSong.fromMap(
                                                      box.getAt(
                                                          downloadedIndex),
                                                    )
                                                  : null;
                                          final progress = downloadedSong
                                                  ?.downloadProgress ??
                                              0;
                                          final downloaded = downloadedIndex !=
                                                  -1 ||
                                              downloadedSong?.status ==
                                                  DownloadTaskStatus.enqueued;
                                          return SingleSongTile(
                                            tileColor: Colors.transparent,
                                            key: ValueKey(song.id),
                                            horizontalPadding: 0,
                                            songController: controller,
                                            song: (downloaded &&
                                                    downloadedSong?.status ==
                                                        DownloadTaskStatus
                                                            .complete)
                                                ? downloadedSong!.mediaItem
                                                : song.mediaItem,
                                            downloaded: downloaded,
                                            progress: progress,
                                            taskId: downloadedSong?.taskId,
                                          );
                                        },
                                        childCount: album.songs.length + 1,
                                      ),
                                    ),
                                  ],
                                ),
                                Obx(
                                  () => Positioned(
                                    top: controller3.fab.value,
                                    right: 16.0,
                                    child: FloatingActionButton(
                                      heroTag: "btn1",
                                      onPressed: () async {
                                        final localPath =
                                            controller2.getLocalPath +
                                                album.songs.first.mediaURL
                                                    .split('/')
                                                    .last;
                                        if (!controller
                                            .isThisPlaylistPlaying(token)) {
                                          if (!controller.queueStream.any(
                                            (m) =>
                                                m.id ==
                                                album.songs.first.mediaItem.id,
                                          )) {
                                            await controller.audioHandler
                                                .addQueueItems(
                                              album.songs
                                                  .map((e) => e.mediaItem)
                                                  .toList(),
                                            );
                                          }
                                          if (controller2.isDownloaded(
                                              album.songs.first)) {
                                            controller.playSong(localPath);
                                          } else {
                                            controller.playSong(
                                              album.songs.first.mediaItem.id,
                                            );
                                          }
                                        } else {
                                          if (controller.isPlaying) {
                                            await controller.audioHandler
                                                .pause();
                                          } else {
                                            await controller.audioHandler
                                                .play();
                                          }
                                        }
                                      },
                                      backgroundColor: controller
                                              .albumPaletteGenerator
                                              .value
                                              ?.darkVibrantColor
                                              ?.color ??
                                          controller.albumTopColor,
                                      child: controller.isThisPlaylistPlaying(
                                                  token) &&
                                              controller.isPlaying
                                          ? Icon(
                                              Icons.pause_outlined,
                                              color: controller
                                                      .albumPaletteGenerator
                                                      .value
                                                      ?.darkVibrantColor
                                                      ?.titleTextColor ??
                                                  controller.albumTextColor,
                                            )
                                          : Icon(
                                              Icons.play_arrow_outlined,
                                              color: controller
                                                      .albumPaletteGenerator
                                                      .value
                                                      ?.darkVibrantColor
                                                      ?.titleTextColor ??
                                                  controller.albumTextColor,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }
}
