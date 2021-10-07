import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:awesome_music_rebased/views/home/tabs/discover.dart';
import 'package:awesome_music_rebased/widgets/get_view_2.dart';
import 'package:awesome_music_rebased/widgets/mini_player.dart';
import 'package:awesome_music_rebased/widgets/navigation_bar.dart';
import 'package:awesome_music_rebased/widgets/single_song_title.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:jiosaavn_wrapper/modals/artist.dart';

class ArtistDetailsScreen
    extends GetView3<SongController, DownloadController, AppController> {
  ArtistDetailsScreen({Key? key}) : super(key: key);

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
          final album = controller.artistDetails.value[token];
          return Scaffold(
            bottomSheet: controller.showMiniPlayer ? const MiniPlayer() : null,
            bottomNavigationBar: const NavigationBar(),
            body: Padding(
              padding:
                  EdgeInsets.only(bottom: controller.showMiniPlayer ? 90 : 0),
              child: controller.fetchingArtistDetails.value
                  ? const Center(child: CircularProgressIndicator())
                  : album == null
                      ? const SizedBox.shrink()
                      : ValueListenableBuilder<Box<dynamic>>(
                          valueListenable: controller2.downloadBox.listenable(),
                          builder: (_, box, __) {
                            return Stack(
                              children: [
                                CustomScrollView(
                                  slivers: [
                                    _buildAppBar(album),
                                    const SliverPadding(
                                      padding: EdgeInsets.only(top: 48),
                                    ),
                                    if (album.topAlbums.isNotEmpty) ...[
                                      SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: 280,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildHeader(
                                                context,
                                                title: 'Top Albums',
                                                horizontalPadding: 8,
                                              ),
                                              const SizedBox(height: 16),
                                              Expanded(
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount:
                                                      album.topAlbums.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return AlbumWidget(
                                                      album.topAlbums[index],
                                                      prefetched: false,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SliverPadding(
                                        padding: EdgeInsets.only(top: 48),
                                      ),
                                    ],
                                    if (album.topSongs.isNotEmpty)
                                      SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          (context, index) {
                                            if (index == 0) {
                                              return _buildHeader(
                                                context,
                                                title: 'Top Songs',
                                                onPressed: () {
                                                  Get.toNamed(
                                                    Routes.artistTopSong,
                                                    arguments: token,
                                                  );
                                                },
                                              );
                                            }
                                            if (index ==
                                                (album.topSongs.length > 10
                                                    ? 11
                                                    : album.topSongs.length +
                                                        1)) {
                                              return const SizedBox(
                                                height: 120,
                                              );
                                            }
                                            return SingleSongTile(
                                              songController: controller,
                                              song: album.topSongs[index - 1]
                                                  .mediaItem,
                                            );
                                          },
                                          childCount: album.topSongs.length > 10
                                              ? 12
                                              : album.topSongs.length + 2,
                                        ),
                                      )
                                  ],
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

  Widget _buildHeader(
    BuildContext context, {
    required String title,
    GestureTapCallback? onPressed,
    double horizontalPadding = 24,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headline5),
          if (onPressed != null)
            TextButton.icon(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(colorBrandPrimary),
                splashFactory: InkSplash.splashFactory,
              ),
              icon: const Icon(Icons.arrow_forward),
              onPressed: onPressed,
              label: const Text('View All'),
            ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(ArtistDetails album) {
    return SliverAppBar(
      expandedHeight: 300,
      stretch: true,
      pinned: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topCenter,
            colors: [controller.albumBottomColor!, controller.albumTopColor!],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 36, bottom: 16),
          title: Text(
            album.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: controller.albumTextColor),
            textAlign: TextAlign.center,
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
    );
  }
}
