import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/widgets/album_search_result_widget.dart';
import 'package:awesome_music_rebased/widgets/artist_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:lottie/lottie.dart';

class SearchScreen extends GetView<SongController> {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: CupertinoSearchTextField(
              controller: controller.searchController,
            ),
          ),
          Expanded(
            child: Obx(
              () => controller.currentSearchResult == null
                  ? Center(
                      child: Lottie.asset(
                        'assets/lottie/search.json',
                        frameRate: FrameRate(60),
                        height: Get.width,
                        width: Get.width,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (controller
                                .currentSearchResult!.artists.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              ..._buildItemsList(
                                context,
                                controller.currentSearchResult!.artists.length,
                                'Artists',
                                (index) => ArtistWidget(
                                  artist: controller
                                      .currentSearchResult!.artists[index],
                                ),
                              ),
                            ],

                            // if (controller.currentSearchResult.songs.isNotEmpty)
                            //   ..._buildItemsList(
                            //     context,
                            //     controller.currentSearchResult.songs.length,
                            //     'Trending Songs',
                            //     (index) => SongResultWidget(
                            //       song:
                            //           controller.currentSearchResult.songs[index],
                            //     ),
                            //   ),
                            const SizedBox(height: 36),
                            if (controller
                                .currentSearchResult!.albums.isNotEmpty)
                              ..._buildItemsList(
                                context,
                                controller.currentSearchResult!.albums.length,
                                'Albums',
                                (index) => AlbumResultWidget(
                                  song: controller
                                      .currentSearchResult!.albums[index],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
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
