import '../repositories/notes_repository.dart';

class DeleteNote {
  final NotesRepository _repository;

  const DeleteNote(this._repository);

  Future<void> call({required String ownerId, required String id}) =>
      _repository.deleteNote(ownerId: ownerId, id: id);
}