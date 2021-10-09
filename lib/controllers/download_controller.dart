import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/model/download_callback.dart';
import 'package:awesome_music_rebased/model/downloaded_song.dart';
import 'package:awesome_music_rebased/utils/constants.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jiosaavn_wrapper/modals/playlist.dart';
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
  Rxn<Playlist> downloads = Rxn();

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

  Future<void> downloadArtistTopSongs(String token) async {
    final playlist = songController.artistDetails.value[token]!;
    final songList = playlist.topSongs;
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

  DownloadedSong fromSongToDownloadedSong(Song song) {
    final downloadedList =
        downloadBox.values.map((e) => DownloadedSong.fromMap(e)).toList();
    return downloadedList
        .firstWhere((downloaded) => downloaded.mediaUrl == song.mediaURL);
  }

  Future<void> _handleDownloadProgressChanged(dynamic data) async {
    final downloadCallback = DownloadCallbackParse.from(data as List);
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

  Future<void> deleteArtistTopSongs(String token) async {
    final playlist = songController.artistDetails.value[token]!;
    final songList = playlist.topSongs;
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
      (downloadPath.value?.path ?? '') + Platform.pathSeparator;

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
    downloads.value = Playlist(
      id: 'downloadedSongs',
      title: 'Downloaded Songs',
      subtitle: 'List of all your downloaded songs',
      description: '',
      permaURL: '',
      image: 'https://www.jiosaavn.com/_i/3.0/artist-default-music.png',
      totalSongs: 0,
      songs: [],
      followers: 0,
    );
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
        if (value.status != DownloadTaskStatus.complete) {
          if (value.status == DownloadTaskStatus.paused) {
            FlutterDownloader.resume(taskId: value.taskId);
          } else if (value.status == DownloadTaskStatus.failed) {
            final newTaskId =
                await FlutterDownloader.retry(taskId: value.taskId);
            downloadBox.delete(value.taskId);
            downloadBox.put(
              newTaskId,
              value.copyWith(taskId: newTaskId).toMap(),
            );
          } else if (value.status == DownloadTaskStatus.canceled) {
            delete(value.taskId);
          } else if (value.status == DownloadTaskStatus.enqueued) {
            try {
              final newTaskId =
                  await FlutterDownloader.retry(taskId: value.taskId);
              downloadBox.delete(value.taskId);
              downloadBox.put(
                newTaskId,
                value.copyWith(taskId: newTaskId).toMap(),
              );
            } catch (e) {
              delete(value.taskId);
            }
          }
        } else {
          downloads.value = downloads.value?.copyWith(
            totalSongs: downloads.value!.totalSongs,
            songs: [...downloads.value!.songs, value.song],
          );
        }
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
