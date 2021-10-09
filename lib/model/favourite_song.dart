import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteSong {
  final String id;
  final String image;
  final String mediaUrl;
  final String title;
  final String subtitle;
  final String description;
  final int duration;
  final DocumentSnapshot? snapshot;
  final DocumentReference? reference;
  final String? documentID;

  FavouriteSong({
    required this.id,
    required this.image,
    required this.mediaUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.duration,
    this.snapshot,
    this.reference,
    this.documentID,
  });

  factory FavouriteSong.fromFirestore(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>?;
    return FavouriteSong(
      id: map!['id'] as String,
      image: map['image'] as String,
      mediaUrl: map['mediaUrl'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      description: map['description'] as String? ?? '',
      duration: map['duration'] as int,
      snapshot: snapshot,
      reference: snapshot.reference,
      documentID: snapshot.id,
    );
  }

  factory FavouriteSong.fromMap(Map<String, dynamic> map) {
    return FavouriteSong(
      id: map['id'] as String,
      image: map['image'] as String,
      mediaUrl: map['mediaUrl'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      description: map['description'] as String,
      duration: map['duration'] as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'image': image,
        'mediaUrl': mediaUrl,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'duration': duration,
      };

  FavouriteSong copyWith({
    String? id,
    String? image,
    String? mediaUrl,
    String? title,
    String? subtitle,
    String? description,
    int? duration,
  }) =>
      FavouriteSong(
        id: id ?? this.id,
        image: image ?? this.image,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        description: description ?? this.description,
        duration: duration ?? this.duration,
      );

  @override
  String toString() {
    return '$id, $image, $mediaUrl, $title, $subtitle, $description, ';
  }

  @override
  bool operator ==(Object other) =>
      other is FavouriteSong && documentID == other.documentID;

  @override
  int get hashCode => documentID.hashCode;
}
