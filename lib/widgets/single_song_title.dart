import 'package:awesome_music_rebased/controllers/download_controller.dart';
import 'package:awesome_music_rebased/controllers/songs_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class SingleSongTile extends GetView<DownloadController> {
  const SingleSongTile({
    Key? key,
    required this.songController,
    required this.index,
  }) : super(key: key);

  final SongController songController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final song = songController.getSongFromTopSong(index);
        final isPlaying = songController.isThisSongPlaying(song);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                isPlaying ? BorderRadius.circular(10) : BorderRadius.zero,
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                      offset: const Offset(0, 3),
                      blurRadius: 16.0,
                      color: Colors.grey.shade200,
                    ),
                  ]
                : [],
          ),
          child: ListTile(
            isThreeLine: true,
            onTap: () {
              songController.playSong(song.mediaURL);
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.network(
                song.mediumResImage,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              onPressed: () => controller.download(song),
              icon: const Icon(Icons.download_outlined),
            ),
          ),
        );
      },
    );
  }
}
