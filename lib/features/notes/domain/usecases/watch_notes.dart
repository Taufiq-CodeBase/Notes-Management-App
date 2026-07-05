import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class WatchNotes {
  final NotesRepository _repository;

  const WatchNotes(this._repository);

  Stream<List<Note>> call(String ownerId) => _repository.watchNotes(ownerId);
}