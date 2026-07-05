import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/watch_notes.dart';
import 'notes_list_state.dart';

class NotesListCubit extends Cubit<NotesListState> {
  final WatchNotes _watchNotes;
  final DeleteNote _deleteNote;
  StreamSubscription<void>? _subscription;

  NotesListCubit({
    required WatchNotes watchNotes,
    required DeleteNote deleteNote,
  })  : _watchNotes = watchNotes,
        _deleteNote = deleteNote,
        super(const NotesListInitial());

  void watch(String ownerId) {
    _subscription?.cancel();
    emit(const NotesListLoading());
    _subscription = _watchNotes(ownerId).listen(
      (notes) => emit(NotesListLoaded(notes)),
      onError: (Object error) => emit(NotesListError(error.toString())),
    );
  }

  Future<void> delete({required String ownerId, required String id}) async {
    try {
      await _deleteNote(ownerId: ownerId, id: id);
    } catch (e) {
      emit(NotesListError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}