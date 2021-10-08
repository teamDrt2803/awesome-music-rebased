import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  AudioPlayer audioPlayer = Get.find<SongController>().audioPlayer;

  @override
  Future<void> prepare() {
    audioPlayer.sequenceStateStream
        .map((state) => state?.effectiveSequence)
        .distinct()
        .map(
          (sequence) =>
              sequence?.map((source) => source.tag as MediaItem).toList(),
        )
        .listen((event) {
      if (event != null) {
        queue.add(event);
      }
    });
    audioPlayer.playbackEventStream.map(_transformEvent).pipe(playbackState);
    return super.prepare();
  }

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
    audioPlayer.seek(position);
  }

  @override
  Future<void> playFromMediaId(
    String mediaId, [
    Map<String, dynamic>? extras,
  ]) async {
    final index = queue.value.indexWhere((q) => q.id == mediaId);
    if (index == 0) {
      mediaItem.add(queue.value[index]);
    }
    await audioPlayer.seek(Duration.zero, index: index);
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
    await audioPlayer.pause();
    await audioPlayer.seek(Duration.zero);
  }

  @override
  Future<void> pause() async {
    super.pause();
    await audioPlayer.pause();
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    if (audioPlayer.audioSource != null) {
      await (audioPlayer.audioSource! as ConcatenatingAudioSource).addAll(
        mediaItems.map((m) {
          return AudioSource.uri(
            ((m.extras?['download'] as bool?) ?? false)
                ? Uri.file(m.id)
                : Uri.parse(m.id),
            tag: m,
          );
        }).toList(),
      );
    } else {
      try {
        await audioPlayer.setAudioSource(
          ConcatenatingAudioSource(
            children: [
              ...mediaItems.map((m) {
                return AudioSource.uri(
                  ((m.extras?['download'] as bool?) ?? false)
                      ? Uri.file(m.id)
                      : Uri.parse(m.id),
                  tag: m,
                );
              })
            ],
          ),
        );
      } on PlatformException catch (_) {}
    }
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    await audioPlayer.setAudioSource(
      ConcatenatingAudioSource(
        children: [
          ...newQueue.map((m) {
            return AudioSource.uri(
              ((m.extras?['download'] as bool?) ?? false)
                  ? Uri.file(m.id)
                  : Uri.parse(m.id),
              tag: m,
            );
          })
        ],
      ),
    );
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    final downloaded = (mediaItem.extras?['download'] as bool?) ?? false;
    final index = queue.value.indexWhere(
      (element) => downloaded
          ? element.id == mediaItem.extras!['mediaUrl']
          : element.id == mediaItem.id,
    );
    if (index != -1) {
      final currentIndex = audioPlayer.currentIndex;
      final position = audioPlayer.position;
      await (audioPlayer.audioSource as ConcatenatingAudioSource?)
          ?.removeAt(index);
      await (audioPlayer.audioSource as ConcatenatingAudioSource?)?.insert(
        index,
        AudioSource.uri(
          downloaded ? Uri.file(mediaItem.id) : Uri.parse(mediaItem.id),
          tag: mediaItem,
        ),
      );
      if (currentIndex == index &&
          (audioPlayer.processingState == ProcessingState.ready ||
              audioPlayer.processingState == ProcessingState.buffering)) {
        await audioPlayer.seek(position, index: index);
        if (audioPlayer.playing) {
          play();
        }
      }
    } else {
      if (audioPlayer.audioSource != null) {
        await (audioPlayer.audioSource as ConcatenatingAudioSource?)?.add(
          AudioSource.uri(
            downloaded ? Uri.file(mediaItem.id) : Uri.parse(mediaItem.id),
            tag: mediaItem,
          ),
        );
      } else {
        await addQueueItems([mediaItem]);
      }
    }
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final downloaded = (mediaItem.extras?['download'] as bool?) ?? false;
    final index = queue.value.indexWhere((m) => m.id == mediaItem.id);
    if (downloaded) {
      final currentIndex = audioPlayer.currentIndex;
      final position = audioPlayer.position;
      final newMediaItem = mediaItem.copyWith(
        id: mediaItem.extras!['mediaUrl'] as String,
        extras: {
          'hasLyrics': mediaItem.extras!['hasLyrics'],
          'lyrics': mediaItem.extras!['lyrics'],
        },
      );
      await removeQueueItemAt(index);
      await (audioPlayer.audioSource as ConcatenatingAudioSource?)?.insert(
        index == -1 ? 0 : index,
        AudioSource.uri(
          Uri.parse(newMediaItem.id),
          tag: newMediaItem,
        ),
      );
      if (currentIndex == index &&
          (audioPlayer.processingState == ProcessingState.ready ||
              audioPlayer.processingState == ProcessingState.buffering)) {
        await audioPlayer.seek(position, index: index);
        if (audioPlayer.playing) {
          play();
        }
      }
    } else {
      await removeQueueItemAt(index);
    }
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index != -1) {
      await (audioPlayer.audioSource as ConcatenatingAudioSource?)
          ?.removeAt(index);
    }
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
        try {
          mediaItem.add(index == null ? null : queue.value[index]);
        } catch (e) {
          // Stack();
        }
        break;
      default:
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (audioPlayer.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[audioPlayer.processingState]!,
      playing: audioPlayer.playing,
      updatePosition: audioPlayer.position,
      bufferedPosition: audioPlayer.bufferedPosition,
      speed: audioPlayer.speed,
      queueIndex: event.currentIndex,
    );
  }
}
