import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jiosaavn_wrapper/modals/search_result.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';

class DownloadController extends GetxController {
  late Directory downloadPath;
  final ReceivePort _port = ReceivePort();
  Rxn<dynamic> downloadProgress = Rxn();
  Box downloadBox = Hive.box('downloads');
  RxList<DownloadedSong> downloadedSongs = RxList();
  SongController songController = Get.find();

  Future<void> download(dynamic song) async {
    if (song is MediaItem) {
      final taskId = await FlutterDownloader.enqueue(
        url: song.id,
        savedDir: downloadPath.path,
        fileName: '${song.title}.${song.id.split('.').last}',
      );
      if (taskId != null) {
        ScaffoldMessenger.of(Get.overlayContext!).showSnackBar(
          SnackBar(
            content: Text(
              'Downloading ${song.title}',
              style: Get.textTheme.button?.copyWith(color: Colors.green),
            ),
          ),
        );
        debugPrint('Successfully enqueued task with id as $taskId');
        await downloadBox.put(
          taskId,
          DownloadedSong(
            taskId: taskId,
            mediaUrl: song.id,
            title: song.title,
            subtitle: song.displaySubtitle ?? '',
            description: null,
            status: DownloadTaskStatus.enqueued,
            downloadProgress: 0,
            imageUrl: song.artUri.toString(),
            duration: (song.duration?.inSeconds) ?? 0,
            lyrics: (song.extras?['lyrics'] as String?) ?? '',
            fileLocation:
                '${downloadPath.path}${Platform.pathSeparator}${song.title}.${song.id.split('.').last}',
          ).toMap(),
        );
      } else {
        debugPrint('Failed to enqueue task');
      }
    } else if (song is SongSearchResult) {
      final songResult = await songController.jioSaavnWrapper
          .fetchSongDetails(songId: song.id);
      await download(songResult.mediaItem);
      return;
    }
  }

  Future<void> _handleDownloadProgressChanged(dynamic data) async {
    final downloadCallback = DownloadCallback.from(data as List);
    if (downloadBox.containsKey(downloadCallback.id)) {
      final downloadedSong =
          DownloadedSong.fromMap(downloadBox.get(downloadCallback.id));
      if (downloadCallback.status == DownloadTaskStatus.failed ||
          downloadCallback.status == DownloadTaskStatus.canceled) {
        await delete(downloadCallback.id);
        return;
      }
      if (downloadCallback.status == DownloadTaskStatus.complete) {
        debugPrint(
          'Filed existing status is: ${File(downloadedSong.fileLocation).existsSync()}',
        );
        if (!File(downloadedSong.fileLocation).existsSync()) {
          ScaffoldMessenger.of(Get.overlayContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to download ${downloadedSong.title}',
                style: Get.textTheme.button?.copyWith(color: Colors.red),
              ),
            ),
          );

          await delete(downloadCallback.id);
        } else {
          downloadBox.put(
            downloadCallback.id,
            downloadedSong
                .copyWith(
                  status: downloadCallback.status,
                  downloadProgress: downloadCallback.progress,
                )
                .toMap(),
          );
          ScaffoldMessenger.of(Get.overlayContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Downloaded ${downloadedSong.title}',
                style: Get.textTheme.button?.copyWith(color: Colors.green),
              ),
            ),
          );
          await songController.audioHandler
              .addQueueItem(downloadedSong.mediaItem);
        }
      } else {
        downloadBox.put(
          downloadCallback.id,
          downloadedSong
              .copyWith(
                status: downloadCallback.status,
                downloadProgress: downloadCallback.progress,
              )
              .toMap(),
        );
      }
    }
  }

  Future<void> delete(String taskId) async {
    await FlutterDownloader.remove(
      taskId: taskId,
      shouldDeleteContent: true,
    ).then((value) async {
      final downloadedSong = DownloadedSong.fromMap(downloadBox.get(taskId));
      await downloadBox.delete(taskId);
      await songController.audioHandler
          .removeQueueItem(downloadedSong.mediaItem);
    });
  }

  Future<String?> getPath(String taskId) async {
    return FlutterDownloader.loadTasksWithRawQuery(
      query: 'SELECT * FROM task WHERE task_id="$taskId"',
    ).then(
      (value) => (value == null || value.isEmpty)
          ? null
          : value.first.savedDir.replaceAll('/(null)', '') +
              Platform.pathSeparator +
              value.first.filename!,
    );
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await FlutterDownloader.registerCallback(downloadCallback);
    await Permission.storage.request();
    ever(downloadProgress, _handleDownloadProgressChanged);
    var registered = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      downloadPortName,
    );
    if (!registered) {
      IsolateNameServer.removePortNameMapping(downloadPortName);
      registered = IsolateNameServer.registerPortWithName(
        _port.sendPort,
        downloadPortName,
      );
    }
    downloadProgress.bindStream(_port.asBroadcastStream());
    // _port.listen((message) {
    //   debugPrint(message[0].toString());
    //   downloadProgress.value = message;
    //   _handleDownloadProgressChanged(message);
    // });
    debugPrint('Port registration result was $registered');
    await FlutterDownloader.loadTasks();
    downloadPath = await getApplicationSupportDirectory();
    for (final value in downloadBox.values) {
      final downloadedSong = DownloadedSong.fromMap(value);
      if (downloadedSong.downloadProgress == 0 ||
          downloadedSong.status == DownloadTaskStatus.failed ||
          downloadedSong.status == DownloadTaskStatus.canceled) {
        delete(downloadedSong.taskId);
      } else {
        await songController.audioHandler
            .addQueueItem(downloadedSong.mediaItem);
      }
    }
  }
}

void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(downloadPortName);
  send?.send([id, status, progress]);
}

class DownloadCallback {
  final String id;
  final DownloadTaskStatus status;
  final int progress;

  DownloadCallback({
    required this.id,
    required this.status,
    required this.progress,
  });

  factory DownloadCallback.from(List data) {
    return DownloadCallback(
      id: data[0] as String,
      status: data[1] as DownloadTaskStatus,
      progress: data[2] as int,
    );
  }
}

class DownloadedSong {
  final String taskId;
  final String mediaUrl;
  final String title;
  final String subtitle;
  final String? description;
  final DownloadTaskStatus status;
  final int downloadProgress;
  final String imageUrl;
  final int duration;
  final bool hasLyrics;
  final String? lyrics;
  final String fileLocation;

  DownloadedSong({
    required this.taskId,
    required this.mediaUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.status,
    required this.downloadProgress,
    required this.imageUrl,
    required this.duration,
    required this.fileLocation,
    this.hasLyrics = false,
    this.lyrics,
  });

  Map<String, dynamic> toMap() => {
        'taskId': taskId,
        'mediaUrl': mediaUrl,
        'title': title,
        'subtitle': subtitle,
        'descripton': description,
        'status': status.value,
        'downloadProgress': downloadProgress,
        'imageUrl': imageUrl,
        'hasLyrics': hasLyrics,
        'lyrics': lyrics,
        'duration': duration,
        'fileLocation': fileLocation,
      };

  factory DownloadedSong.fromMap(dynamic map) {
    return DownloadedSong(
      taskId: map['taskId'] as String,
      mediaUrl: map['mediaUrl'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      description: map['description'] as String?,
      status: DownloadTaskStatus.from(map['status'] as int),
      downloadProgress: map['downloadProgress'] as int,
      imageUrl: map['imageUrl'] as String,
      duration: map['duration'] as int,
      hasLyrics: map['hasLyrics'] as bool,
      lyrics: map['lyrics'] as String?,
      fileLocation: map['fileLocation'] as String,
    );
  }

  DownloadedSong copyWith({
    String? taskId,
    String? mediaUrl,
    String? title,
    String? subtitle,
    String? description,
    DownloadTaskStatus? status,
    int? downloadProgress,
    String? imageUrl,
    int? duration,
    bool? hasLyrics,
    String? lyrics,
    String? fileLocation,
  }) =>
      DownloadedSong(
        taskId: taskId ?? this.taskId,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        description: description ?? this.description,
        status: status ?? this.status,
        downloadProgress: downloadProgress ?? this.downloadProgress,
        imageUrl: imageUrl ?? this.imageUrl,
        duration: duration ?? this.duration,
        hasLyrics: hasLyrics ?? this.hasLyrics,
        lyrics: lyrics ?? lyrics,
        fileLocation: fileLocation ?? this.fileLocation,
      );

  MediaItem get mediaItem => MediaItem(
        id: fileLocation,
        title: title,
        artUri: Uri.parse(imageUrl),
        displaySubtitle: subtitle,
        displayDescription: description,
        duration: Duration(seconds: duration),
        displayTitle: title,
        extras: {
          'mediaUrl': mediaUrl,
          'hasLyrics': hasLyrics,
          'lyrics': lyrics,
          'taskId': taskId,
          'fileLocation': fileLocation,
          'download': true,
        },
      );
}
