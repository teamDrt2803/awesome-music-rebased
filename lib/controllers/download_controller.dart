import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jiosaavn_wrapper/modals/search_result.dart';
import 'package:jiosaavn_wrapper/modals/song.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadController extends GetxController {
  Rxn<Directory> downloadPath = Rxn();
  final ReceivePort _port = ReceivePort();
  Rxn<dynamic> downloadProgress = Rxn();
  Box downloadBox = Hive.box('downloads');
  RxList<DownloadedSong> downloadedSongs = RxList();
  SongController songController = Get.find();

  Future<void> download(dynamic song) async {
    if (song is MediaItem) {
      ///FIXME: Find the reason why disabling this lets the file to be donwloaded succesffully
      final taskId = await FlutterDownloader.enqueue(
        url: song.id,
        savedDir: getLocalPath,
        fileName: song.id.split('/').last,
        openFileFromNotification: false,
      );
      if (taskId != null) {
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
            filename: song.id.split('/').last,
          ).toMap(),
        );
      } else {}
    } else if (song is SongSearchResult) {
      final songResult = await songController.jioSaavnWrapper
          .fetchSongDetails(songId: song.id);
      await download(songResult.mediaItem);
      return;
    }
  }

  Future<void> downloadPlaylist(String token) async {
    debugPrint('downloading playlist..... for token $token');
    final playlist = songController.playlists.value[token]!;
    final songList = playlist.songs;
    final downloadedList =
        downloadBox.values.map((e) => DownloadedSong.fromMap(e));
    for (final song in songList) {
      if (!downloadedList.any((element) => element.mediaUrl == song.mediaURL)) {
        await download(song.mediaItem);
      }
    }
  }

  bool isDownloaded(Song song) {
    final downloadedList =
        downloadBox.values.map((e) => DownloadedSong.fromMap(e));

    return downloadedList
        .any((downloaded) => downloaded.mediaUrl == song.mediaURL);
  }

  Future<void> _handleDownloadProgressChanged(dynamic data) async {
    final downloadCallback = DownloadCallback.from(data as List);
    if (downloadBox.containsKey(downloadCallback.id)) {
      final downloadedSong =
          DownloadedSong.fromMap(downloadBox.get(downloadCallback.id));
      if (downloadCallback.status == DownloadTaskStatus.failed ||
          downloadCallback.status == DownloadTaskStatus.canceled) {
        await FlutterDownloader.retry(taskId: downloadedSong.taskId);
        return;
      }
      if (downloadCallback.status == DownloadTaskStatus.complete) {
        if (!(await File(downloadedSong.fileLocation).exists())) {
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

  Future<void> deletePlaylist(String token) async {
    debugPrint('deleting playlist..... for token $token');
    final playlist = songController.playlists.value[token]!;
    final songList = playlist.songs;
    final downloadedList =
        downloadBox.values.map((e) => DownloadedSong.fromMap(e));
    for (final song in downloadedList) {
      if (songList.any((element) => element.mediaURL == song.mediaUrl)) {
        await delete(song.taskId);
      }
    }
  }

  Future<void> delete(String taskId) async {
    await FlutterDownloader.remove(
      taskId: taskId,
    ).then((value) async {
      final downloadedSong = DownloadedSong.fromMap(downloadBox.get(taskId));
      if (File(downloadedSong.filename).existsSync()) {
        await File(downloadedSong.filename).delete();
      }
      await downloadBox.delete(taskId);
      await songController.audioHandler
          .removeQueueItem(downloadedSong.mediaItem);
    });
  }

  String get getLocalPath =>
      (downloadPath.value?.path ?? '') +
      (Platform.isIOS ? Platform.pathSeparator : '');

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    downloadPath.value = await getApplicationDocumentsDirectory();
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
    for (final value
        in downloadBox.values.map((e) => DownloadedSong.fromMap(e))) {
      if (await File(value.fileLocation).exists()) {
        await songController.audioHandler.addQueueItem(value.mediaItem);
      } else {
        delete(value.taskId);
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
  final String filename;

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
    required this.filename,
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
        'filename': filename,
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
      filename: map['filename'] as String,
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
    String? filename,
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
        filename: filename ?? this.filename,
      );

  String get fileLocation =>
      Get.find<DownloadController>().getLocalPath + filename;

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
          'filename': filename,
        },
      );
}

//flutter: File name is  /var/mobile/Containers/Data/Application/B91A88C1-A65F-42A9-A3A5-C7088AEB1F32/Documents/115d5cb9924b84b4b8ff3a5a4d732ef1_96.mp4
