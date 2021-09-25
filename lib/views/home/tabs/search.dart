import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:jiosaavn_wrapper/modals/search_result.dart';

class SearchScreen extends GetView<SongController> {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => SingleChildScrollView(
          child: controller.topSearchResult.value == null
              ? const SizedBox.shrink()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 16),
                      child: Text(
                        'Trending Artists',
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
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 32),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            controller.topSearchResult.value!.artists.length,
                        itemBuilder: (_, index) {
                          return Padding(
                            padding: index == 0
                                ? const EdgeInsets.only(left: 24)
                                : index ==
                                        controller.topSearchResult.value!
                                                .artists.length -
                                            1
                                    ? const EdgeInsets.only(right: 24)
                                    : EdgeInsets.zero,
                            child: ArtistWidget(
                              artist: controller
                                  .topSearchResult.value!.artists[index],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, bottom: 16),
                      child: Text(
                        'Trending Songs',
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: colorBrandPrimary,
                            ),
                      ),
                    ),
                    SizedBox(
                      height: 210,
                      child: ListView.separated(
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 32),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            controller.topSearchResult.value!.songs.length,
                        itemBuilder: (_, index) {
                          return Padding(
                            padding: index == 0
                                ? const EdgeInsets.only(left: 24)
                                : index ==
                                        controller.topSearchResult.value!.songs
                                                .length -
                                            1
                                    ? const EdgeInsets.only(right: 24)
                                    : EdgeInsets.zero,
                            child: SongResultWidget(
                              song: controller
                                  .topSearchResult.value!.songs[index],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class SongResultWidget extends GetView<SongController> {
  const SongResultWidget({
    Key? key,
    required this.song,
  }) : super(key: key);
  final SongSearchResult song;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.playSongFromModal(song);
      },
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
      ),
    );
  }
}

class ArtistWidget extends GetView<SongController> {
  const ArtistWidget({
    Key? key,
    required this.artist,
  }) : super(key: key);

  final ArtistSearchResult artist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
