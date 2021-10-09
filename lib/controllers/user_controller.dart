import 'package:audio_service/audio_service.dart';
import 'package:awesome_music_rebased/controllers/auth_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:awesome_music_rebased/model/favourite_playlist.dart';
import 'package:awesome_music_rebased/model/favourite_song.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiosaavn_wrapper/modals/playlist.dart';
import 'package:jiosaavn_wrapper/modals/song.dart';
import 'package:simpler_login/simpler_login.dart';

class UserController extends GetxController with SingleGetTickerProviderMixin {
  SimplerLogin simplerLogin = SimplerLogin.instance;
  AuthController authController = Get.find();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxList<FavouritePlaylist> favouritePlaylist = RxList();
  RxList<FavouriteSong> favouriteSongs = RxList();
  late TabController tabController;

  User? get currentUser => authController.user.value;
  bool get isLoggedIn => currentUser != null && currentUser?.uid != null;
  bool isPlaylistFavourite(String id) =>
      favouritePlaylist.any((element) => element.id == id);
  bool isSongFavourite(String id) =>
      favouriteSongs.any((element) => element.mediaUrl == id);

  GeneralPlaylist<FavouriteSong, IconData> get favouriteSongPlaylist =>
      GeneralPlaylist<FavouriteSong, IconData>(
        id: 'favourite_songs',
        title: 'Favourites',
        subtitle: 'Favourite Songs',
        description: 'All of your favourite songs reside in here',
        permaURL: '',
        image: Icons.favorite,
        totalSongs: favouriteSongs.length,
        songs: favouriteSongs,
      );

  Future<void> addToPlaylist(Playlist playlist) async {
    await firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('saved_playlists')
        .add(playlist.toMap());
  }

  Future<void> addToFavouriteSong<T>(T song) async {
    switch (T) {
      case Song:
        await firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('favourite_songs')
            .add((song as Song).toMap());
        break;
      default:
        final selectedSong = song as MediaItem;
        final bool downloaded =
            selectedSong.extras?['download'] as bool? ?? false;
        final map = <String, dynamic>{
          'id': 'favourite_song_${favouriteSongs.length + 1}',
          'image': selectedSong.artUri.toString(),
          'mediaUrl':
              !downloaded ? selectedSong.id : selectedSong.extras!['mediaUrl'],
          'title': selectedSong.title,
          'subtitle': selectedSong.displaySubtitle,
          'description': selectedSong.displayDescription,
          'duration': selectedSong.duration!.inSeconds,
        };
        await firestore
            .collection('users')
            .doc(currentUser!.uid)
            .collection('favourite_songs')
            .add(map);
        break;
    }
  }

  Future<void> deleteFromPlaylist(Playlist playlist) async {
    await favouritePlaylist
        .firstWhere((element) => element.id == playlist.id)
        .reference
        ?.delete();
  }

  Future<void> deleteFromFavouriteSong<T>(T song) async {
    switch (T) {
      case Song:
        await favouriteSongs
            .firstWhere((element) => element.id == (song as Song).id)
            .reference
            ?.delete();
        break;
      default:
        await favouriteSongs
            .firstWhere(
              (element) =>
                  element.mediaUrl == (song as MediaItem).id ||
                  element.mediaUrl == song.extras?['mediaUrl'],
            )
            .reference
            ?.delete();
        break;
    }
  }

  Stream<List<FavouritePlaylist>> get streamFavouritePlaylist => firestore
      .collection('users')
      .doc(currentUser!.uid)
      .collection('saved_playlists')
      .snapshots()
      .map(
        (event) =>
            [...event.docs.map((e) => FavouritePlaylist.fromFirestore(e))],
      );

  Stream<List<FavouriteSong>> get streamFavouriteSongs => firestore
      .collection('users')
      .doc(currentUser!.uid)
      .collection('favourite_songs')
      .snapshots()
      .map(
        (event) => [...event.docs.map((e) => FavouriteSong.fromFirestore(e))],
      );

  void handleSignIn() {
    favouritePlaylist.bindStream(streamFavouritePlaylist);
    favouriteSongs.bindStream(streamFavouriteSongs);
  }

  Future<void> signOut() async {
    final controller = Get.find<SongController>();
    controller.audioHandler.stop();
    await authController.simplerLogin.signOut();
  }

  @override
  void onReady() {
    super.onReady();
    tabController = TabController(length: 3, vsync: this);
  }
}
