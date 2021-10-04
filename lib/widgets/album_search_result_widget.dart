import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiosaavn_wrapper/modals/search_result.dart';

class AlbumResultWidget extends GetView<SongController> {
  const AlbumResultWidget({
    Key? key,
    required this.song,
  }) : super(key: key);
  final AlbumSearchResult song;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await controller.fetchAlbumDetails(song);
      },
      child: SizedBox(
        width: 200,
        child: Column(
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
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }
}
