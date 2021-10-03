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
import 'package:jiosaavn_wrapper/modals/playlist.dart';

class AlbumScreen
    extends GetView3<SongController, DownloadController, AppController> {
  AlbumScreen({Key? key}) : super(key: key);

  final album = Get.arguments as Playlist;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        controller3.fab.value = controller3.buildFab(reset: true);
        return Future.value(true);
      },
      child: Scaffold(
        bottomSheet: controller.showMiniPlayer ? const MiniPlayer() : null,
        bottomNavigationBar: const NavigationBar(),
        body: ValueListenableBuilder<Box<dynamic>>(
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
                          titlePadding:
                              const EdgeInsets.only(left: 36, bottom: 16),
                          title: Text(
                            album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: controller.albumTextColor),
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
                                  imageUrl: album.image
                                      .replaceAll('150x150', '500x500'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
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
                    const SliverPadding(padding: EdgeInsets.only(top: 16)),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (contex, index) {
                          final song = album.songs[index];

                          final downloadedIndex =
                              box.values.toList().indexWhere(
                                    (e) => e['mediaUrl'] == song.mediaURL,
                                  );
                          final downloadedSong = downloadedIndex != -1
                              ? DownloadedSong.fromMap(
                                  box.getAt(downloadedIndex),
                                )
                              : null;
                          final progress =
                              downloadedSong?.downloadProgress ?? 0;
                          final downloaded = downloadedIndex != -1 ||
                              downloadedSong?.status ==
                                  DownloadTaskStatus.enqueued;
                          return SingleSongTile(
                            key: ValueKey(song.id),
                            horizontalPadding: 0,
                            songController: controller,
                            song: album.songs[index].mediaItem,
                            downloaded: downloaded,
                            progress: progress,
                            taskId: downloadedSong?.taskId,
                          );
                        },
                        childCount: album.songs.length,
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
                        if (!controller.isThisPlaylistPlaying(
                          album.permaURL.split('/').last,
                        )) {
                          if (!controller.queueStream.any(
                            (m) => m.id == album.songs.first.mediaItem.id,
                          )) {
                            await controller.audioHandler.addQueueItems(
                              album.songs.map((e) => e.mediaItem).toList(),
                            );
                          }
                          controller.playSong(album.songs.first.mediaItem.id);
                        } else {
                          await controller.audioHandler.pause();
                        }
                      },
                      backgroundColor: controller.albumPaletteGenerator.value
                              ?.darkVibrantColor?.color ??
                          controller.albumTopColor,
                      child: controller.isThisPlaylistPlaying(
                        album.permaURL.split('/').last,
                      )
                          ? Icon(
                              Icons.pause_outlined,
                              color: controller.albumPaletteGenerator.value
                                      ?.darkVibrantColor?.bodyTextColor ??
                                  controller.albumTopColor,
                            )
                          : Icon(
                              Icons.play_arrow_outlined,
                              color: controller.albumPaletteGenerator.value
                                      ?.darkVibrantColor?.bodyTextColor ??
                                  controller.albumTopColor,
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
  }
}
