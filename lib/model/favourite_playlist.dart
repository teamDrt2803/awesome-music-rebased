import 'package:cloud_firestore/cloud_firestore.dart';

class FavouritePlaylist {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final String permaURL;
  final DocumentSnapshot? snapshot;
  final DocumentReference? reference;
  final String? documentID;

  FavouritePlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.permaURL,
    this.snapshot,
    this.reference,
    this.documentID,
  });

  factory FavouritePlaylist.fromFirestore(DocumentSnapshot snapshot) {
    final map = snapshot.data() as Map<String, dynamic>?;
    return FavouritePlaylist(
      id: map!['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String? ?? '',
      description: map['description'] as String,
      image: map['image'] as String,
      permaURL: map['perma_url'] as String,
      snapshot: snapshot,
      reference: snapshot.reference,
      documentID: snapshot.id,
    );
  }

  factory FavouritePlaylist.fromMap(Map<String, dynamic> map) {
    return FavouritePlaylist(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      permaURL: map['perma_url'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'image': image,
        'perma_url': permaURL,
      };

  FavouritePlaylist copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? description,
    String? image,
    String? permaURL,
  }) {
    return FavouritePlaylist(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      image: image ?? this.image,
      permaURL: permaURL ?? this.permaURL,
    );
  }

  String get token => permaURL.split('/').last;

  @override
  String toString() {
    return '$id, $title, $subtitle, $description, $image, $permaURL';
  }

  @override
  bool operator ==(Object other) =>
      other is FavouritePlaylist && documentID == other.documentID;

  @override
  int get hashCode => documentID.hashCode;
}
