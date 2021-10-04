import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiosaavn_wrapper/modals/search_result.dart';

class SongResultWidget extends GetView<SongController> {
  const SongResultWidget({
    Key? key,
    required this.song,
  }) : super(key: key);
  final SongSearchResult song;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: CachedNetworkImageProvider(song.image),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    backgroundColor: colorBrandPrimary,
                    foregroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        controller.playSongFromModal(song);
                      },
                      icon: const Icon(Icons.play_arrow),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: colorBrandPrimary,
                    foregroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        Get.find<DownloadController>().download(song);
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          song.title,
          style: Theme.of(context)
              .textTheme
              .subtitle1
              ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        Text(
          describeEnum(song.type)[0].toUpperCase() +
              describeEnum(song.type).substring(1),
          style: Theme.of(context)
              .textTheme
              .subtitle1
              ?.copyWith(letterSpacing: 1, color: Colors.black54),
        ),
      ],
    );
  }
}
