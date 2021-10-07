import 'package:awesome_music_rebased/utils/initial_bindings.dart';
import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:awesome_music_rebased/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'utils/routes/pages.dart';

class AwesomeMusic extends StatelessWidget {
  const AwesomeMusic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (FocusManager.instance.primaryFocus != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: GetMaterialApp(
        showPerformanceOverlay: kProfileMode,
        debugShowCheckedModeBanner: false,
        theme: theme,
        getPages: pages,
        initialRoute: Routes.home,
        initialBinding: InitialBindings(),
      ),
    );
  }
}
