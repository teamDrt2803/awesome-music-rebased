import 'package:awesome_music_rebased/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class AccountScreen extends GetView<UserController> {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: controller.isLoggedIn
            ? Column(
                children: [
                  // UserAccountsDrawerHeader(
                  //   accountName: Text(controller.currentUser!.displayName!),
                  //   accountEmail: Text(controller.currentUser!.email!),
                  // )
                  GestureDetector(
                    onLongPress: () {
                      controller.signOut();
                    },
                    child: Card(
                      color: Colors.black,
                      borderOnForeground: false,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              height: 56,
                              width: 56,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.currentUser!.displayName ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                                Text(
                                  controller.currentUser!.email ??
                                      controller.currentUser!.phoneNumber!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
