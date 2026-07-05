import 'package:equatable/equatable.dart';

import '../../domain/entities/note.dart';

sealed class NotesListState extends Equatable {
  const NotesListState();

  @override
  List<Object?> get props => const [];
}

class NotesListInitial extends NotesListState {
  const NotesListInitial();
}

class NotesListLoading extends NotesListState {
  const NotesListLoading();
}

class NotesListLoaded extends NotesListState {
  final List<Note> notes;

  const NotesListLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

class NotesListError extends NotesListState {
  final String message;

  const NotesListError(this.message);

  @override
  List<Object?> get props => [message];
}