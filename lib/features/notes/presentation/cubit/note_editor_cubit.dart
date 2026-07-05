import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/update_note.dart';
import 'note_editor_state.dart';

class NoteEditorCubit extends Cubit<NoteEditorState> {
  final AddNote _addNote;
  final UpdateNote _updateNote;

  NoteEditorCubit({
    required AddNote addNote,
    required UpdateNote updateNote,
    required String ownerId,
  })  : _addNote = addNote,
        _updateNote = updateNote,
        super(NoteEditorState.empty(ownerId: ownerId));

  void loadFor(Note note) {
    emit(NoteEditorState.fromNote(note));
  }

  void onTitleChanged(String value) {
    emit(state.copyWith(
      title: value,
      titleError: null,
      status: EditorStatus.idle,
    ));
  }

  void onDescriptionChanged(String value) {
    emit(state.copyWith(
      description: value,
      descriptionError: null,
      status: EditorStatus.idle,
    ));
  }

  Future<void> submit() async {
    if (state.status == EditorStatus.saving) return;
    final title = state.title.trim();
    final description = state.description.trim();

    final titleError =
        title.isEmpty ? "Title can't be empty" : null;
    final descriptionError =
        description.isEmpty ? "Description can't be empty" : null;

    if (titleError != null || descriptionError != null) {
      emit(state.copyWith(
        titleError: titleError,
        descriptionError: descriptionError,
      ));
      return;
    }

    emit(state.copyWith(
      status: EditorStatus.saving,
      errorMessage: null,
    ));

    try {
      if (state.isEditing) {
        await _updateNote(
          id: state.id,
          ownerId: state.ownerId,
          title: title,
          description: description,
          createdAt: state.createdAt,
        );
      } else {
        await _addNote(
          ownerId: state.ownerId,
          title: title,
          description: description,
        );
      }
      emit(state.copyWith(status: EditorStatus.saved));
    } catch (e) {
      emit(state.copyWith(
        status: EditorStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}