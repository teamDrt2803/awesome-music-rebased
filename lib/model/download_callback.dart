import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadCallbackParse {
  final String id;
  final DownloadTaskStatus status;
  final int progress;

  DownloadCallbackParse({
    required this.id,
    required this.status,
    required this.progress,
  });

  factory DownloadCallbackParse.from(List data) {
    return DownloadCallbackParse(
      id: data[0] as String,
      status: data[1] as DownloadTaskStatus,
      progress: data[2] as int,
    );
  }
}
