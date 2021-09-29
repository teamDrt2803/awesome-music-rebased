import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:jiosaavn_wrapper/jiosaavn_wrapper.dart';
import 'package:jiosaavn_wrapper/modals/playlist.dart';
import 'package:jiosaavn_wrapper/modals/search_result.dart';
import 'package:jiosaavn_wrapper/modals/song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:palette_generator/palette_generator.dart';

import '../audio_handler.dart';

class SongController extends GetxController {
  JioSaavnWrapper jioSaavnWrapper = JioSaavnWrapper.instance;
  Rxn<Playlist> topSongs = Rxn<Playlist>();
  Rxn<MediaItem> currentSong = Rxn();
  RxList<MediaItem> queueStream = RxList();
  RxnInt currentIndex = RxnInt();
  RxBool playingStream = RxBool(false);
  Rx<ProcessingState> processingStateStream = Rx(ProcessingState.idle);
  Rx<PlaybackEvent> playBackStream = Rx(PlaybackEvent());
  Rx<Duration> positionStream = Rx(Duration.zero);
  late AudioHandler audioHandler;
  AudioPlayer audioPlayer = AudioPlayer();
  late PageController fullScreenThumbController;
  Rxn<PaletteGenerator> paletteGenerator = Rxn();
  Rxn<CachedNetworkImageProvider> cachedNetworkImageProvider = Rxn();
  Rx<Map<String, bool>> showLyrics = Rx({});
  Rxn<SearchResult> searcResult = Rxn();
  Rxn<TopSearchResult> topSearchResult = Rxn();

  List<Song> get topSongList => topSongs.value?.songs ?? [];
  ProcessingState get currentProcessingState => processingStateStream.value;
  bool get isPlaying => playingStream.value;
  int get currentPlayingIndex => currentIndex.value ?? 0;
  Color? get topColor => paletteGenerator.value?.mutedColor?.color;
  Color? get bottomColor =>
      paletteGenerator.value?.darkMutedColor?.color ?? topColor;
  Color? get textColor =>
      paletteGenerator.value?.darkMutedColor?.bodyTextColor.withOpacity(1) ??
      paletteGenerator.value?.mutedColor?.bodyTextColor.withOpacity(1);

  void toggleShowLyrics(String id) {
    showLyrics.value[id] = !(showLyrics.value[id] ?? false);
  }

  ///Fetch Top Songs and add them to AudioHandler
  Future<void> getTopSongs() async {
    topSongs.value = await jioSaavnWrapper.fetchTopSongs();
    final mediaItems = <MediaItem>[];
    for (final item in topSongs.value!.songs) {
      mediaItems.add(item.mediaItem);
    }
    if (mediaItems.isNotEmpty) {
      await audioHandler.addQueueItems(mediaItems);
    }
  }

  bool get showMiniPlayer {
    return queueStream.isNotEmpty &&
        currentSong.value != null &&
        (currentProcessingState == ProcessingState.ready ||
            currentProcessingState == ProcessingState.buffering);
  }

  Song getSongFromTopSong(int index) {
    return topSongList[index];
  }

  void playSong(String songId) {
    switch (songId == currentSong.value?.id) {
      case true:
        isPlaying ? audioHandler.pause() : audioHandler.play();
        break;
      default:
        audioHandler.playFromMediaId(songId);
    }
  }

  Future<void> playSongFromModal(dynamic song) async {
    if (song is SongSearchResult) {
      try {
        debugPrint('Fetching song details for song ${song.title}');
        final songResult =
            await jioSaavnWrapper.fetchSongDetails(songId: song.id);
        debugPrint('Fetched song details for song ${songResult.title}');
        await audioHandler.addQueueItem(songResult.mediaItem);
        await audioHandler.skipToQueueItem(queueStream
            .indexWhere((element) => element.id == songResult.mediaItem.id));
      } catch (e) {
        debugPrintStack();
      }
      debugPrint(song.id);
    }
  }

  bool isThisSongPlaying(Song topSong) =>
      currentSong.value?.id == topSong.mediaURL && isPlaying;

  Song? get topSongPlaying {
    return showMiniPlayer
        ? topSongList
            .firstWhere((element) => element.mediaURL == currentSong.value!.id)
        : null;
  }

  int get currentSongDurationInSeconds => positionStream.value.inSeconds;
  Duration get currentSongPosition => positionStream.value;
  Future<void> handleSeek(Duration position) async =>
      audioHandler.seek(position);

  Future<void> _handleCurrentMediaItemUpdate(MediaItem? mediaItem) async {
    if (mediaItem != null) {
      cachedNetworkImageProvider.value =
          CachedNetworkImageProvider(mediaItem.artUri.toString());
      if (cachedNetworkImageProvider.value != null) {
        paletteGenerator.value = await PaletteGenerator.fromImageProvider(
          cachedNetworkImageProvider.value!,
        );
      }
    }
  }

  Future<void> handleCurrentSongIndexUpdate(int? index) async {
    audioHandler.customAction(updateMediaItemCustomEvent, {'index': index});
    debugPrint('Current Index is $index');
    if (index != null && fullScreenThumbController.hasClients) {
      await fullScreenThumbController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
      debugPrint(
        'Changing Thumbnail Image to $index',
      );
    } else {
      debugPrint('No Clients attached');
    }
  }

  void _handleQueueStream(List<MediaItem> mediaItem) {
    debugPrint('MediaList Updated');
  }

  Future<void> preparePageController(int index) async {
    fullScreenThumbController = PageController(initialPage: index);
    if (cachedNetworkImageProvider.value != null) {
      paletteGenerator.value = await PaletteGenerator.fromImageProvider(
        cachedNetworkImageProvider.value!,
      );
    }
  }

  Future<void> fetchTrendingSearches() async {
    topSearchResult.value = await jioSaavnWrapper.fetchTrendingSearchResult();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: notificationChanelId,
        androidNotificationChannelName: 'Audio playback',
        androidNotificationOngoing: true,
      ),
    );
    await audioHandler.prepare();
    fullScreenThumbController = PageController(keepPage: false);
    ever(currentIndex, handleCurrentSongIndexUpdate);
    ever(currentSong, _handleCurrentMediaItemUpdate);
    ever(queueStream, _handleQueueStream);
    currentSong.bindStream(audioHandler.mediaItem);
    currentIndex.bindStream(audioPlayer.currentIndexStream);
    playingStream.bindStream(audioPlayer.playingStream);
    processingStateStream.bindStream(audioPlayer.processingStateStream);
    queueStream.bindStream(audioHandler.queue);
    playBackStream.bindStream(audioPlayer.playbackEventStream);
    positionStream.bindStream(audioPlayer.positionStream);
    getTopSongs();
  }
}
