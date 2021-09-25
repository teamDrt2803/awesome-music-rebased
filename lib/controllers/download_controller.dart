import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:jiosaavn_wrapper/modals/song.dart';

class DownloadController extends GetxController {
  bool isDownloaded(String id) => false;

  Future<void> download(Song song) async {}

  @override
  void onReady() {
    super.onReady();
    FlutterDownloader.initialize(debug: kDebugMode || kProfileMode);
  }
}
