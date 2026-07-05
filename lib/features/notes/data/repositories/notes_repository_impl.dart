import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_remote_data_source.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  final NotesRemoteDataSource _remoteDataSource;

  NotesRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<Note>> watchNotes(String ownerId) =>
      _remoteDataSource.watchNotes(ownerId);

  @override
  Future<Note> addNote({
    required String ownerId,
    required String title,
    required String description,
  }) =>
      _remoteDataSource.addNote(
        ownerId: ownerId,
        title: title,
        description: description,
      );

  @override
  Future<Note> updateNote(Note note) {
    return _remoteDataSource.updateNote(
      NoteModel(
        id: note.id,
        ownerId: note.ownerId,
        title: note.title,
        description: note.description,
        createdAt: note.createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> deleteNote({required String ownerId, required String id}) =>
      _remoteDataSource.deleteNoteForOwner(ownerId: ownerId, id: id);
}