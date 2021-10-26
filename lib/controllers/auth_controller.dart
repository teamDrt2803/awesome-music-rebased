import 'package:awesome_music_rebased/controllers/app_controllers.dart';
import 'package:awesome_music_rebased/controllers/user_controller.dart';
import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simpler_login/simpler_login.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  ValueNotifier<bool> showPasswordController = ValueNotifier(false);
  Rxn<String> profilePicUrl = Rxn<String>();
  Rxn<String> errorStream = Rxn<String>();
  SimplerLogin simplerLogin = SimplerLogin.instance;
  Rxn<User> user = Rxn();
  Rx<AuthType> authType = Rx(AuthType.login);
  RxBool isSigningUp = RxBool(false);
  RxBool otpSent = RxBool(false);
  GlobalKey<FormState> formKey = GlobalKey();

  bool get isSigningUpbyEmail =>
      isSigningUp.value && authType.value == AuthType.singup;
  bool get isLoggingInbyEmail =>
      isSigningUp.value && authType.value == AuthType.login;
  bool get isLoggingInbyGoogle =>
      isSigningUp.value && authType.value == AuthType.google;
  bool get isLoggingInbyPhone =>
      isSigningUp.value && authType.value == AuthType.phone;
  bool get hasError => errorStream.value != null;
  String? get currentError => errorStream.value;

  Future<void> signInWithGoogle() async {
    authType.value = AuthType.google;
    isSigningUp.value = true;
    await simplerLogin.signInWithGoogle();
    isSigningUp.value = false;
  }

  Future<void> signInWithEmailAndPassword() async {
    if (!isFormValid) return;
    isSigningUp.value = true;
    await simplerLogin.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
      onError: (error) {
        errorStream.value = error;
      },
    );
    isSigningUp.value = false;
  }

  Future<void> createAccountWithEmailAndPassword() async {
    if (!isFormValid) return;
    isSigningUp.value = true;
    await simplerLogin.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
      updateProfile: true,
      displayName: displayNameController.text,
    );
    isSigningUp.value = false;
  }

  Future<void> sendOTP() async {
    if (!isFormValid) return;
    isSigningUp.value = true;
    await simplerLogin
        .verifyPhoneNumber(
          phoneNumber: '+91${phoneController.text}',
          timeout: const Duration(seconds: 30),
        )
        .then((value) => isSigningUp.value = false);
  }

  Future<void> verifyOTP() async {
    if (!isFormValid) return;
    isSigningUp.value = true;
    await simplerLogin.verifyOtp(
      smsCode: otpController.text,
      updateProfile: true,
      displayName: displayNameController.text,
    );
    isSigningUp.value = false;
  }

  void _handleUserChanges(User? user) {
    /// TODO: Bind userdata stream from firestore in the [UserController]
    if (user?.uid == null && Get.currentRoute != Routes.login) {
      ///Only navigates if current route is not login screen
      Get.offNamed(Routes.login);
    } else {
      _handleAuthTypeChange(authType.value);
      Get.find<UserController>().handleSignIn();

      ///Checks if the current route is home
      ///If not then route the app to homescreen
      if (Get.currentRoute != Routes.home) {
        Get.offNamed(Routes.home);
      }
    }
  }

  bool get isFormValid => formKey.currentState?.validate() ?? false;

  void forgotPassword() {}

  void _handleAuthTypeChange(AuthType authType) {
    emailController.clear();
    passwordController.clear();
    displayNameController.clear();
    phoneController.clear();
    otpController.clear();
    otpSent.value = false;
    showPasswordController.value = false;
    profilePicUrl.value = null;
  }

  @override
  void onReady() {
    super.onReady();
    ever(user, _handleUserChanges);
    ever(authType, _handleAuthTypeChange);
    user.bindStream(simplerLogin.userStream);
    errorStream.bindStream(simplerLogin.errorStream);
    otpSent.bindStream(simplerLogin.otpSent);
    emailController.addListener(() {
      errorStream.value = null;
    });
    displayNameController.addListener(() {
      errorStream.value = null;
    });
    passwordController.addListener(() {
      errorStream.value = null;
    });
    phoneController.addListener(() {
      errorStream.value = null;
    });
  }
}

enum AuthType { login, singup, phone, google }
