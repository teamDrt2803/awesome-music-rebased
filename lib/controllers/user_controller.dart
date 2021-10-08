import 'package:awesome_music_rebased/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:simpler_login/simpler_login.dart';

class UserController extends GetxController {
  SimplerLogin simplerLogin = SimplerLogin.instance;
  AuthController authController = Get.find();

  User? get currentUser => authController.user.value;
  bool get isLoggedIn => currentUser != null && currentUser?.uid != null;

  void signOut() => authController.simplerLogin.signOut();
}
