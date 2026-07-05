import '../entities/note.dart';

abstract class NotesRepository {
  Stream<List<Note>> watchNotes(String ownerId);

  Future<Note> addNote({
    required String ownerId,
    required String title,
    required String description,
  });

  Future<Note> updateNote(Note note);

  Future<void> deleteNote({required String ownerId, required String id});
}