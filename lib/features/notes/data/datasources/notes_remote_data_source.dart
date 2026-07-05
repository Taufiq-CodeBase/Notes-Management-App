import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/note_model.dart';

abstract class NotesRemoteDataSource {
  Stream<List<NoteModel>> watchNotes(String ownerId);

  Future<NoteModel> addNote({
    required String ownerId,
    required String title,
    required String description,
  });

  Future<NoteModel> updateNote(NoteModel note);

  Future<void> deleteNoteForOwner({
    required String ownerId,
    required String id,
  });
}

class NotesRemoteDataSourceImpl implements NotesRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotesRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String ownerId) =>
      _firestore.collection('users').doc(ownerId).collection('notes');

  @override
  Stream<List<NoteModel>> watchNotes(String ownerId) {
    try {
      return _collection(ownerId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(NoteModel.fromFirestore)
                .toList(growable: false),
          )
          .handleError(
            (Object error, StackTrace stackTrace) =>
                throw ServerException('Failed to stream notes', error),
          );
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Firestore error', e);
    }
  }

  @override
  Future<NoteModel> addNote({
    required String ownerId,
    required String title,
    required String description,
  }) async {
    try {
      final docRef = _collection(ownerId).doc();
      final owner = _firestore.collection('users').doc(ownerId);
      final note = NoteModel(
        id: docRef.id,
        ownerId: ownerId,
        title: title,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore.runTransaction((txn) async {
        txn.set(
          owner,
          <String, dynamic>{'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
        txn.set(docRef, note.toFirestore());
      });
      return note;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to add note', e);
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      await _collection(note.ownerId).doc(note.id).update(note.toFirestore());
      return note;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update note', e);
    }
  }

  @override
  Future<void> deleteNoteForOwner({
    required String ownerId,
    required String id,
  }) async {
    try {
      await _collection(ownerId).doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete note', e);
    }
  }
}