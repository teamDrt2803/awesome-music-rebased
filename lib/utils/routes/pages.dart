import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:awesome_music_rebased/views/full_screen_player.dart';
import 'package:awesome_music_rebased/views/home/home.dart';
import 'package:get/route_manager.dart';

List<GetPage> get pages => [
      GetPage(
        name: Routes.home,
        page: () => const HomeScreen(),
      ),
      GetPage(
        name: Routes.fullScreenPlayer,
        transition: Transition.cupertinoDialog,
        page: () => const FullScreenPlayer(),
      ),
    ];
