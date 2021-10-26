import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:jiosaavn_wrapper/modals/song.dart';

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
  Song get song => Song(
        id: fileLocation,
        albumId: '',
        album: '',
        label: '',
        title: title,
        subtitle: subtitle,
        lowResImage: imageUrl.lowRes,
        mediumResImage: imageUrl.mediumRes,
        highResImage: imageUrl.highRes,
        imageURI: Uri.parse(imageUrl),
        playCount: 0,
        year: 2021,
        permaURL: '',
        hasLyrics: hasLyrics,
        copyRightText: '',
        mediaURL: mediaUrl,
        duration: Duration(seconds: duration),
        releaseDate: DateTime(2021),
        allArtists: [],
      );
}
