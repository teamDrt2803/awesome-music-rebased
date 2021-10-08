import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:dart_des/dart_des.dart';
import 'package:jiosaavn_wrapper/modals/song.dart';

extension Cleansing on String? {
  String get sanitize => this == null
      ? ''
      : this!
          .replaceAll('&amp;', '&')
          .replaceAll('http:', 'https:')
          .replaceAll('&quot;', '"')
          .replaceAll('&#039;', "'");

  String get highRes =>
      this == null ? '' : this!.replaceAll('150x150', '500x500');
  String get lowRes => this == null ? '' : this!.replaceAll('150x150', '75x75');
  String get mediumRes =>
      this == null ? '' : this!.replaceAll('150x150', '250x250');
  String get artwork =>
      this == null ? '' : this!.replaceAll('.m4a', '_artwork.jpg');

  String get decryptUrl {
    if (this == null) return '';
    const key = '38346591';
    final desECB = DES(key: key.codeUnits, paddingType: DESPaddingType.PKCS7);
    final decrypted = desECB.decrypt(base64Decode(this!));
    return utf8.decode(decrypted);
  }

  String? get isPasswordValid {
    if (this == null) return 'Please enter a valid password';
    if (this!.length < 8) {
      return 'Password should not be less than 8 characters';
    }
    // ignore: unnecessary_raw_strings
    if (!this!.contains(RegExp(r"[a-z]"))) {
      return 'Password should contain atleast 1 lowercase letter';
    }
    // ignore: unnecessary_raw_strings
    if (!this!.contains(RegExp(r"[A-Z]"))) {
      return 'Password should contain atleast 1 uppercase letter';
    }
    // ignore: unnecessary_raw_strings
    if (!this!.contains(RegExp(r"[0-9]"))) {
      return 'Password should contain atleast 1 digit';
    }
    if (!this!.contains(RegExp(r'[!@#$%^&£*(),.?":{}|<>]'))) {
      return 'Password should contain atleast 1 special character';
    }
    return null;
  }

  String? get isPhoneValid {
    if (this == null) return 'Please enter a valid Phone';
    if (this!.length < 10) return 'Please enter a valid Phone';
    return null;
  }
}

extension SongExtensions on Song {
  MediaItem get mediaItem => MediaItem(
        id: mediaURL.isEmpty ? id : mediaURL,
        title: title,
        album: album,
        artist: artist.isNotEmpty ? artist.first.name : '',
        duration: duration,
        artUri: imageURI,
        displaySubtitle: subtitle,
        extras: {
          'hasLyrics': hasLyrics,
          'lyrics': lyrics,
        },
      );
}
