import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  ///JioSaavn Wrapper
  JioSaavnWrapper jioSaavnWrapper = JioSaavnWrapper.instance;

  ///Rx variables
  Rxn<Playlist> topSongs = Rxn<Playlist>();
  Rxn<MediaItem> currentSong = Rxn();
  RxList<MediaItem> queueStream = RxList();
  Rx<ProcessingState> processingStateStream = Rx(ProcessingState.idle);
  Rx<PlaybackEvent> playBackStream = Rx(PlaybackEvent());
  Rx<Duration> positionStream = Rx(Duration.zero);
  RxnInt currentIndex = RxnInt();
  RxBool playingStream = RxBool(false);
  Rxn<PaletteGenerator> paletteGenerator = Rxn();
  Rxn<PaletteGenerator> albumPaletteGenerator = Rxn();
  Rxn<CachedNetworkImageProvider> cachedNetworkImageProvider = Rxn();
  Rxn<CachedNetworkImageProvider> albumCachedNetworkImageProvider = Rxn();
  Rx<Map<String, bool>> showLyrics = Rx({});
  Rxn<SearchResult> searcResult = Rxn();
  Rxn<TopSearchResult> topSearchResult = Rxn();
  Rx<Map<String, Playlist>> playlists = Rx({});

  ///AudioHandler Variables
  late AudioHandler audioHandler;
  AudioPlayer audioPlayer = AudioPlayer();

  ///PageController for thumbnail image on full screen audio player
  late PageController fullScreenThumbController;

  ///Getter for accessign list of topSongs
  List<Song> get topSongList => topSongs.value?.songs ?? [];

  ///Current Processing State of AudioService
  ProcessingState get currentProcessingState => processingStateStream.value;

  ///Returns whether the player is playing any song
  bool get isPlaying => playingStream.value;

  bool isThisPlaylistPlaying(String playlistToken) {
    final playlist = playlists.value[playlistToken];
    if (playlist == null) return false;
    final songIdList = playlist.songs.map((e) => e.mediaURL).toList();
    final loacalPath = Get.find<DownloadController>().getLocalPath;
    final downloadedSongList = playlist.songs
        .map((e) => loacalPath + e.mediaURL.split('/').last)
        .toList();
    return downloadedSongList
            .any((e) => ((currentSong.value?.id) ?? '') == e) ||
        songIdList.any((e) => ((currentSong.value?.id) ?? '') == e);
  }

  int get currentPlayingIndex => currentIndex.value ?? 0;

  ///List of Graient colors for FullScreen player
  Color? get topColor => paletteGenerator.value?.mutedColor?.color;
  Color? get bottomColor =>
      paletteGenerator.value?.darkMutedColor?.color ?? topColor;
  Color? get textColor =>
      paletteGenerator.value?.darkMutedColor?.bodyTextColor.withOpacity(1) ??
      paletteGenerator.value?.mutedColor?.bodyTextColor.withOpacity(1);

  ///List of Graient colors for Album Details Screen
  Color? get albumTopColor => albumPaletteGenerator.value?.mutedColor?.color;
  Color? get albumBottomColor =>
      albumPaletteGenerator.value?.darkMutedColor?.color ?? topColor;
  Color? get albumTextColor =>
      albumPaletteGenerator.value?.darkMutedColor?.bodyTextColor
          .withOpacity(1) ??
      albumPaletteGenerator.value?.mutedColor?.bodyTextColor.withOpacity(1);

  ///Toggle Show Lyrics
  void toggleShowLyrics(String id) {
    showLyrics.value[id] = !(showLyrics.value[id] ?? false);
  }

  ///Fetch Top Songs and add them to AudioHandler
  Future<void> getTopSongs() async {
    topSongs.value = await jioSaavnWrapper.fetchTopSongs();
    final mediaItems = topSongs.value!.songs.map((e) => e.mediaItem).toList();
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
        final songResult =
            await jioSaavnWrapper.fetchSongDetails(songId: song.id);
        await audioHandler.addQueueItem(songResult.mediaItem);
        await audioHandler.skipToQueueItem(
          queueStream
              .indexWhere((element) => element.id == songResult.mediaItem.id),
        );
      } catch (e) {
        Stack();
      }
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
    if (index != null && fullScreenThumbController.hasClients) {
      await fullScreenThumbController.animateToPage(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn,
      );
    }
  }

  void _handleQueueStream(List<MediaItem> mediaItem) {}

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

  Future<void> fetchAlbumDetails(AlbumSearchResult album) async {
    Get.toNamed(
      Routes.albumScreen,
      arguments: album.token,
    );
    if (playlistFromList(album.token) == null) {
      try {
        playlists.value[album.token] =
            await jioSaavnWrapper.fetchAlbumDetails(album.token);
        albumCachedNetworkImageProvider.value =
            CachedNetworkImageProvider(playlists.value[album.token]!.image);
        albumPaletteGenerator.value = await PaletteGenerator.fromImageProvider(
          albumCachedNetworkImageProvider.value!,
        );
      } catch (_) {
        Stack();
      }
    } else {
      albumCachedNetworkImageProvider.value =
          CachedNetworkImageProvider(playlistFromList(album.token)!.image);
      albumPaletteGenerator.value = await PaletteGenerator.fromImageProvider(
        albumCachedNetworkImageProvider.value!,
      );
    }
  }

  Playlist? playlistFromList(String token) =>
      playlists.value.containsKey(token) ? playlists.value[token] : null;

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
