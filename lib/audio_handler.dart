import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  AudioPlayer audioPlayer = Get.find<SongController>().audioPlayer;

  @override
  Future<void> play() async {
    super.play();
    await audioPlayer.play();
  }

  @override
  Future<void> skipToNext() async {
    await audioPlayer.seekToNext();
    play();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    super.skipToQueueItem(index);
    audioPlayer.seek(Duration.zero, index: index);
    play();
  }

  @override
  Future<void> skipToPrevious() async {
    await audioPlayer.seekToPrevious();
    play();
  }

  @override
  Future<void> seek(Duration position) async {
    super.seek(position);
    audioPlayer.seek(position);
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    super.playFromMediaId(mediaId);
    mediaItem.add(await getMediaItem(mediaId));
    await audioPlayer.seek(
      Duration.zero,
      index: queue.value.indexWhere((q) => q.id == mediaId),
    );
    play();
  }

  @override
  Future<MediaItem?> getMediaItem(String mediaId) {
    return Future.value(
      queue.value.firstWhere((element) => element.id == mediaId),
    );
  }

  @override
  Future<void> stop() async {
    super.stop();
    mediaItem.add(null);
    await audioPlayer.stop();
  }

  @override
  Future<void> pause() async {
    super.pause();
    await audioPlayer.pause();
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    super.addQueueItems(mediaItems);
    audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: [...mediaItems.map((m) => AudioSource.uri(Uri.parse(m.id)))],
      ),
      preload: false,
    );
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    super.updateQueue(newQueue);
    audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: [...newQueue.map((m) => AudioSource.uri(Uri.parse(m.id)))],
      ),
    );
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final oldIndex = queue.value.indexWhere((q) => q.id == mediaItem.id);
    final newQueue = queue.value;
    if (oldIndex != -1) {
      newQueue.removeAt(oldIndex);
    }
    newQueue.add(mediaItem);
    updateQueue(newQueue);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final index =
        queue.value.indexWhere((element) => element.id == mediaItem.id);
    if (index != -1) {
      await skipToQueueItem(index);
    } else {
      await addQueueItem(mediaItem);
      final index =
          queue.value.indexWhere((element) => element.id == mediaItem.id);
      await skipToQueueItem(index);
    }
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    super.customAction(name, extras);
    switch (name) {
      case updateMediaItemCustomEvent:
        final index = extras!['index'] as int?;
        mediaItem.add(index == null ? null : queue.value[index]);
        break;
      default:
    }
  }
}
