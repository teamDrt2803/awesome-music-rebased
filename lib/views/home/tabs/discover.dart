import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:awesome_music_rebased/widgets/album_search_result_widget.dart';
import 'package:awesome_music_rebased/widgets/artist_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:jiosaavn_wrapper/modals/playlist.dart';

class DiscoverScreen extends GetView<SongController> {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () {
          final result = controller.topSearchResult.value;
          return result == null || controller.topSongList.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (result.artists.isNotEmpty)
                      ..._buildItemsList(
                        context,
                        result.artists.length,
                        'Trending Artists',
                        (index) => ArtistWidget(
                          artist: result.artists[index],
                        ),
                      ),
                    if (result.albums.isNotEmpty)
                      ..._buildItemsList(
                        context,
                        result.albums.length + 1,
                        'Trending Albums',
                        (index) => index == 0
                            ? AlbumWidget(controller.topSongs.value!)
                            : AlbumResultWidget(
                                song: result.albums[index - 1],
                              ),
                      ),
                  ],
                );
        },
      ),
    );
  }

  List<Widget> _buildItemsList(
    BuildContext context,
    int itemCount,
    String title,
    Widget Function(int index) builder,
  ) {
    return [
      Padding(
        padding: const EdgeInsets.only(left: 24, bottom: 16),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline6?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: colorBrandPrimary,
              ),
        ),
      ),
      SizedBox(
        height: Get.width * 0.6,
        child: ListView.separated(
          separatorBuilder: (_, index) => const SizedBox(width: 32),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: itemCount,
          itemBuilder: (_, index) {
            return Padding(
              padding: index == 0
                  ? const EdgeInsets.only(left: 24)
                  : index == itemCount - 1
                      ? const EdgeInsets.only(right: 24)
                      : EdgeInsets.zero,
              child: builder(index),
            );
          },
        ),
      ),
    ];
  }
}

class AlbumWidget extends GetView<SongController> {
  const AlbumWidget(this.playlist, {Key? key, this.prefetched = true})
      : super(key: key);
  final Playlist playlist;
  final bool prefetched;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (prefetched) {
          controller.playlists.value[playlist.token] = playlist;
          await controller.assignCachedNetworkImageFromAlbum(
            playlist.token,
            isAlbum: true,
          );
          Get.toNamed(Routes.albumScreen, arguments: playlist.token);
        } else {
          controller.fetchAlbumDetails(playlist);
        }
      },
      child: SizedBox.fromSize(
        size: const Size.square(200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                width: 180,
                decoration: playlist.image.isEmpty
                    ? null
                    : BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            playlist.mediumResImage,
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Album',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(letterSpacing: 1, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
