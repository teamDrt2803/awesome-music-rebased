import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/routes/routes.dart';
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => controller.topSongs.value == null
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(colorBrandPrimary),
                  )
                : AlbumWidget(
                    controller.topSongs.value!,
                  ),
          ),
        ],
      ),
    );
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(playlist.mediumResImage),
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
              'Playlist',
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
