import 'package:awesome_music_rebased/utils/routes/routes.dart';
import 'package:awesome_music_rebased/views/auth/login.dart';
import 'package:awesome_music_rebased/views/auth/signup.dart';
import 'package:awesome_music_rebased/views/full_screen_player.dart';
import 'package:awesome_music_rebased/views/grouped_song/album_sreen.dart';
import 'package:awesome_music_rebased/views/grouped_song/artist_details_screen.dart';
import 'package:awesome_music_rebased/views/home/home.dart';
import 'package:awesome_music_rebased/widgets/artist_top_song.dart';
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
        fullscreenDialog: true,
        preventDuplicates: true,
      ),
      GetPage(
        name: Routes.albumScreen,
        page: () => AlbumScreen(),
      ),
      GetPage(
        name: Routes.artistDetailsScreen,
        page: () => ArtistDetailsScreen(),
      ),
      GetPage(
        name: Routes.artistTopSong,
        page: () => ArtistTopSongs(),
      ),
      GetPage(
        name: Routes.login,
        page: () => LoginScreen(),
      ),
      GetPage(
        name: Routes.signUp,
        page: () => SignUpScreen(),
      )
    ];
