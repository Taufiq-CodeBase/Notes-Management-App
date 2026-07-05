import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failures.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

class UpdateNote {
  final NotesRepository _repository;

  const UpdateNote(this._repository);

  Future<Note> call({
    required String id,
    required String ownerId,
    required String title,
    required String description,
    required DateTime createdAt,
  }) {
    final cleanTitle = title.trim();
    final cleanDescription = description.trim();

    if (cleanTitle.isEmpty) {
      throw ValidationFailure(field: 'title', message: AppStrings.emptyTitleError);
    }
    if (cleanDescription.isEmpty) {
      throw ValidationFailure(
        field: 'description',
        message: AppStrings.emptyDescriptionError,
      );
    }

    return _repository.updateNote(
      Note(
        id: id,
        ownerId: ownerId,
        title: cleanTitle,
        description: cleanDescription,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      ),
    );
  }
}