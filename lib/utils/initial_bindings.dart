import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/controllers/auth_controller.dart';
import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/controllers/user_controller.dart';
import 'package:get/instance_manager.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(UserController());
    Get.put(SongController());
    Get.put(AppController());
    Get.put(DownloadController());
  }
}
