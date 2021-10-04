import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiosaavn_wrapper/modals/search_result.dart';

class ArtistWidget extends GetView<SongController> {
  const ArtistWidget({
    Key? key,
    required this.artist,
  }) : super(key: key);

  final ArtistSearchResult artist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.fetchArtistDetails(artist);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: Get.width * 0.4,
            width: Get.width * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(artist.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.title,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          Text(
            describeEnum(artist.type)[0].toUpperCase() +
                describeEnum(artist.type).substring(1),
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(letterSpacing: 1, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
