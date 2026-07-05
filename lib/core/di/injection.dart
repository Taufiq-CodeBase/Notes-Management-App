import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/notes/data/datasources/notes_remote_data_source.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/domain/usecases/add_note.dart';
import '../../features/notes/domain/usecases/delete_note.dart';
import '../../features/notes/domain/usecases/update_note.dart';
import '../../features/notes/domain/usecases/watch_notes.dart';
import '../../features/notes/presentation/cubit/auth_cubit.dart';
import '../../features/notes/presentation/cubit/note_editor_cubit.dart';
import '../../features/notes/presentation/cubit/notes_list_cubit.dart';
import '../network/auth_gate.dart';

final GetIt getIt = GetIt.instance;

void setupInjection() {
  if (getIt.isRegistered<FirebaseAuth>()) return;

  // External SDKs
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Core wrappers
  getIt.registerLazySingleton<AuthGate>(
    () => AuthGate(auth: getIt<FirebaseAuth>()),
  );

  // Data layer
  getIt.registerLazySingleton<NotesRemoteDataSource>(
    () => NotesRemoteDataSourceImpl(firestore: getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(getIt<NotesRemoteDataSource>()),
  );

  // Use-cases
  getIt.registerLazySingleton(() => WatchNotes(getIt<NotesRepository>()));
  getIt.registerLazySingleton(() => AddNote(getIt<NotesRepository>()));
  getIt.registerLazySingleton(() => UpdateNote(getIt<NotesRepository>()));
  getIt.registerLazySingleton(() => DeleteNote(getIt<NotesRepository>()));

  // Cubits
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthGate>()));
  getIt.registerFactory<NotesListCubit>(
    () => NotesListCubit(
      watchNotes: getIt<WatchNotes>(),
      deleteNote: getIt<DeleteNote>(),
    ),
  );
  getIt.registerFactoryParam<NoteEditorCubit, String, void>(
    (ownerId, _) => NoteEditorCubit(
      addNote: getIt<AddNote>(),
      updateNote: getIt<UpdateNote>(),
      ownerId: ownerId,
    ),
  );
}
