import 'package:awesome_music_rebased/controllers/auth_controller.dart';
import 'package:awesome_music_rebased/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class LoginScreen extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final type = controller.authType.value;
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AutofillGroup(
                  child: Form(
                    key: controller.formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.authType.value == AuthType.phone) ...[
                          const SizedBox(height: 36),
                          Text(
                            'Enter your phone',
                            style:
                                Theme.of(context).textTheme.headline4?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                          ),
                          const SizedBox(height: 24),
                          InputField(
                            key: const ValueKey('Name (Optional)'),
                            controller: controller.displayNameController,
                            label: 'Name (Optional)',
                            autofillHints: const [AutofillHints.name],
                            validator: (name) => null,
                          ),
                          const SizedBox(height: 24),
                          InputField.phone(
                            key: const ValueKey('phone number'),
                            controller: controller.phoneController,
                            validator: (phone) => phone.isPhoneValid,
                          ),
                          if (controller.otpSent.value)
                            InputField(
                              key: const ValueKey('OTP'),
                              controller: controller.otpController,
                              label: 'OTP',
                              limit: 6,
                              keyboardType: TextInputType.number,
                              autofillHints: const [AutofillHints.oneTimeCode],
                            ),
                          Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  controller.forgotPassword();
                                },
                                child: const Text('Resend OTP in 00:00'),
                              ),
                            ],
                          ),
                        ],
                        if (controller.authType.value != AuthType.phone) ...[
                          const SizedBox(height: 36),
                          Text(
                            type == AuthType.singup ? 'Sign Up' : 'Login',
                            style:
                                Theme.of(context).textTheme.headline4?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                          ),
                          if (type == AuthType.singup) ...[
                            const SizedBox(height: 24),
                            InputField(
                              key: const ValueKey('Name (Optional)'),
                              controller: controller.displayNameController,
                              label: 'Name (Optional)',
                              autofillHints: const [AutofillHints.name],
                              validator: (name) => null,
                            ),
                          ],
                          const SizedBox(height: 24),
                          InputField.email(
                            key: const ValueKey('Email'),
                            controller: controller.emailController,
                            validator: (email) => !(email?.isEmail ?? false)
                                ? 'Enter a valid email.'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          InputField.password(
                            key: const ValueKey('Password'),
                            controller: controller.passwordController,
                            passwordVisibilityController:
                                controller.showPasswordController,
                            validator: (password) => password.isPasswordValid,
                          ),
                          Row(
                            children: [
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  controller.forgotPassword();
                                },
                                child: const Text('Forgot password?'),
                              ),
                            ],
                          ),
                          if (controller.hasError)
                            Text(
                              '*${controller.currentError!}',
                              style:
                                  Theme.of(context).textTheme.caption?.copyWith(
                                        color: Colors.red,
                                      ),
                            ),
                        ],
                        const SizedBox(height: 48),
                        ...[
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 55,
                              width: Get.width * 0.7,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                                onPressed: () {
                                  if (controller.authType.value ==
                                      AuthType.login) {
                                    controller.signInWithEmailAndPassword();
                                  } else if (controller.authType.value ==
                                      AuthType.singup) {
                                    controller
                                        .createAccountWithEmailAndPassword();
                                  } else if (!controller.otpSent.value) {
                                    controller.sendOTP();
                                  } else {
                                    controller.verifyOTP();
                                  }
                                },
                                child: (controller.isSigningUpbyEmail ||
                                        controller.isLoggingInbyEmail ||
                                        controller.isLoggingInbyPhone)
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        type == AuthType.phone
                                            ? controller.otpSent.value
                                                ? 'Verify OTP'
                                                : 'Send OTP'
                                            : type == AuthType.singup
                                                ? 'Sign Up'
                                                : 'Login',
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: const [
                                Expanded(child: Divider(thickness: 2)),
                                SizedBox(width: 16),
                                Text('OR'),
                                SizedBox(width: 16),
                                Expanded(child: Divider(thickness: 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            child: SizedBox(
                              height: 55,
                              width: Get.width * 0.7,
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  minimumSize: MaterialStateProperty.all(
                                    Size(Get.width * 0.7, 55),
                                  ),
                                ),
                                onPressed: () {
                                  controller.signInWithGoogle();
                                },
                                icon: controller.isLoggingInbyGoogle
                                    ? const SizedBox.shrink()
                                    : const Icon(FontAwesomeIcons.google),
                                label: controller.isLoggingInbyGoogle
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text('Google'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            child: SizedBox(
                              height: 55,
                              width: Get.width * 0.7,
                              child: ElevatedButton.icon(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                  foregroundColor: MaterialStateProperty.all(
                                    Colors.black,
                                  ),
                                ),
                                onPressed: () {
                                  if (type != AuthType.phone) {
                                    controller.authType.value = AuthType.phone;
                                  } else {
                                    controller.authType.value = AuthType.login;
                                  }
                                },
                                icon: controller.isLoggingInbyPhone
                                    ? const SizedBox.shrink()
                                    : type != AuthType.phone
                                        ? const Icon(Icons.phone_outlined)
                                        : const Icon(Icons.email_outlined),
                                label: Text(
                                  type != AuthType.phone ? 'Phone' : 'Email',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (type != AuthType.phone)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  type == AuthType.singup
                                      ? 'Already have an account'
                                      : "Don't have and account?",
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (type == AuthType.singup) {
                                      controller.authType.value =
                                          AuthType.login;
                                      return;
                                    }
                                    controller.authType.value = AuthType.singup;
                                  },
                                  child: Text(
                                    type == AuthType.singup
                                        ? 'Sign In'
                                        : 'SignUp',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class InputField extends StatelessWidget {
  const InputField({
    Key? key,
    required this.controller,
    this.label,
    this.trailing,
    this.maskText = false,
    this.autofillHints,
    this.passwordVisibilityController,
    this.keyboardType,
    this.validator,
    this.limit,
  })  : type = InputFieldType.custom,
        super(key: key);

  InputField.email({
    Key? key,
    required this.controller,
    this.trailing,
    this.validator,
    this.limit,
  })  : keyboardType = TextInputType.emailAddress,
        passwordVisibilityController = null,
        type = InputFieldType.email,
        label = 'Email',
        autofillHints = [AutofillHints.email],
        maskText = false,
        super(key: key);

  InputField.phone({
    Key? key,
    required this.controller,
    this.validator,
  })  : limit = 10,
        keyboardType = TextInputType.number,
        trailing = null,
        passwordVisibilityController = null,
        type = InputFieldType.email,
        label = 'Phone',
        autofillHints = [AutofillHints.telephoneNumber],
        maskText = false,
        super(key: key);

  InputField.password({
    Key? key,
    required this.controller,
    this.passwordVisibilityController,
    this.validator,
    this.limit,
  })  : keyboardType = TextInputType.visiblePassword,
        trailing = ValueListenableBuilder<bool>(
          valueListenable: passwordVisibilityController!,
          builder: (_, showPassword, ___) {
            return GestureDetector(
              onTap: () {
                passwordVisibilityController.value =
                    !passwordVisibilityController.value;
              },
              child: Icon(
                showPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            );
          },
        ),
        type = InputFieldType.password,
        label = 'Password',
        autofillHints = [AutofillHints.password],
        maskText = true,
        super(key: key);

  final TextEditingController controller;
  final String? label;
  final Widget? trailing;
  final bool maskText;
  final List<String>? autofillHints;
  final InputFieldType type;
  final ValueNotifier<bool>? passwordVisibilityController;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    return (type == InputFieldType.password &&
            passwordVisibilityController != null)
        ? ValueListenableBuilder<bool>(
            valueListenable: passwordVisibilityController!,
            builder: (_, showPassword, ___) {
              return _buildtextFormField(showPassword);
            },
          )
        : _buildtextFormField(true);
  }

  TextFormField _buildtextFormField(bool showText) {
    return TextFormField(
      validator: validator,
      controller: controller,
      obscureText: maskText && showText,
      autofillHints: autofillHints,
      inputFormatters: [
        LengthLimitingTextInputFormatter(limit),
      ],
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffix: trailing,
      ),
    );
  }
}

enum InputFieldType { email, password, custom }
