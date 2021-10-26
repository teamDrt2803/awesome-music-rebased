import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/controllers/user_controller.dart';
import 'package:awesome_music_rebased/widgets/get_view_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaylistSection extends GetView2<UserController, SongController> {
  const PlaylistSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.separated(
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: controller.favouritePlaylist.length,
        itemBuilder: (context, index) {
          final playlist = controller.favouritePlaylist[index];
          return GestureDetector(
            onTap: () {
              controller2.fetchAlbumDetails(playlist);
            },
            child: Container(
              height: 70,
              width: Get.width,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(imageUrl: playlist.image),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.title,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.subtitle1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          playlist.subtitle,
                          maxLines: 1,
                          style:
                              Theme.of(context).textTheme.bodyText1?.copyWith(
                                    color: Colors.grey,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Center(
                    child: IconButton(
                      onPressed: () async {
                        await controller2.fetchAlbumDetails(
                          playlist,
                          navigate: false,
                        );
                        controller2.handleAlbumPlay(playlist.token);
                      },
                      icon: Obx(
                        () =>
                            controller2.isThisPlaylistPlaying(playlist.token) &&
                                    controller2.isPlaying
                                ? const Icon(Icons.pause_outlined)
                                : const Icon(Icons.play_arrow_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
