import 'package:equatable/equatable.dart';

import '../../domain/entities/note.dart';

enum EditorStatus { idle, saving, saved, failure }

class NoteEditorState extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? titleError;
  final String? descriptionError;
  final EditorStatus status;
  final String? errorMessage;
  final bool isEditing;

  const NoteEditorState({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.titleError,
    required this.descriptionError,
    required this.status,
    required this.errorMessage,
    required this.isEditing,
  });

  factory NoteEditorState.empty({required String ownerId}) {
    final now = DateTime.now();
    return NoteEditorState(
      id: '',
      ownerId: ownerId,
      title: '',
      description: '',
      createdAt: now,
      titleError: null,
      descriptionError: null,
      status: EditorStatus.idle,
      errorMessage: null,
      isEditing: false,
    );
  }

  factory NoteEditorState.fromNote(Note note) {
    return NoteEditorState(
      id: note.id,
      ownerId: note.ownerId,
      title: note.title,
      description: note.description,
      createdAt: note.createdAt,
      titleError: null,
      descriptionError: null,
      status: EditorStatus.idle,
      errorMessage: null,
      isEditing: true,
    );
  }

  bool get canSubmit =>
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      status != EditorStatus.saving;

  NoteEditorState copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    DateTime? createdAt,
    Object? titleError = _unset,
    Object? descriptionError = _unset,
    EditorStatus? status,
    Object? errorMessage = _unset,
    bool? isEditing,
  }) {
    return NoteEditorState(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      titleError:
          identical(titleError, _unset) ? this.titleError : titleError as String?,
      descriptionError: identical(descriptionError, _unset)
          ? this.descriptionError
          : descriptionError as String?,
      status: status ?? this.status,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  static const _unset = Object();

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        createdAt,
        titleError,
        descriptionError,
        status,
        errorMessage,
        isEditing,
      ];
}