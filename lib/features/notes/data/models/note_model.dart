import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
    required super.ownerId,
  });

  factory NoteModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final createdAt = _readTimestamp(data['createdAt']) ?? DateTime.now();
    final updatedAt = _readTimestamp(data['updatedAt']) ?? createdAt;
    return NoteModel(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      ownerId: (data['ownerId'] as String?) ?? '',
    );
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    final createdAt = _readTimestamp(map['createdAt']) ?? DateTime.now();
    final updatedAt = _readTimestamp(map['updatedAt']) ?? createdAt;
    return NoteModel(
      id: (map['id'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      ownerId: (map['ownerId'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => <String, dynamic>{
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': ownerId,
      };

  static DateTime? _readTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}