# Architecture — Notes Management App

A Flutter + Firebase Firestore notes app following **Clean Architecture**, **Cubit** for state, and **shadcn_ui** for a border-free, shadow-free UI.

---

## 1. High-level layers

```
┌───────────────────────────────────────────────────────────┐
│  Presentation  (Flutter widgets, Cubits, sealed states)   │
│      │                                                   │
│      ▼  depends on                                       │
│  Domain  (pure Dart: entities, repository contract,      │
│           use-cases, Failure hierarchy)                   │
│      ▲                                                   │
│      │  implements contract, depends on Domain           │
│  Data  (Firestore models, remote data source,            │
│        repository implementation)                        │
└───────────────────────────────────────────────────────────┘
```

The dependency rule is one-way only: `presentation → domain ← data`. Neither the data nor the domain layer imports anything from `presentation`.

```
presentation ─▶ domain ◀─ data
                  ▲
                  │
            core (constants, errors, network, theme, di, utils)
```

`core/` is shared infrastructure (no Flutter UI in non-UI files; no Firebase in `core/errors`/`core/constants`/`core/utils`).

---

## 2. Feature folder layout

```
lib/
├── app/                       # Top-level widget tree + router
│   └── app.dart
├── core/
│   ├── constants/             # AppColors, AppSizes, AppStrings,
│   │                          # AppRoutes, AppEnv
│   ├── di/                    # GetIt container + setupInjection()
│   ├── errors/                # ServerException, AuthException,
│   │                          # NotFoundException + sealed Failure
│   ├── network/               # AuthGate (FirebaseAuth wrapper)
│   ├── theme/                 # AppTheme (Material + Shad)
│   └── utils/                 # DateFormatter
├── features/
│   └── notes/
│       ├── domain/
│       │   ├── entities/      # Note
│       │   ├── repositories/  # NotesRepository (abstract)
│       │   └── usecases/      # Watch, Add, Update, Delete
│       ├── data/
│       │   ├── models/        # NoteModel (Firestore mapping)
│       │   ├── datasources/   # NotesRemoteDataSource (abstract) + Impl
│       │   └── repositories/  # NotesRepositoryImpl
│       └── presentation/
│           ├── cubit/         # Auth, NotesList, NoteEditor
│           ├── screens/       # NotesListScreen, NoteEditorScreen
│           └── widgets/       # NoteTile, EmptyState, LoadingView,
│                              # ErrorView, ConfirmDeleteDialog
├── firebase_options.dart      # Reads keys via String.fromEnvironment
└── main.dart                  # Firebase init + DI setup + runApp
```

---

## 3. Data flow

### Read path — `NotesListScreen`

```
NotesListScreen
  └─ BlocProvider<NotesListCubit>(create: ...getIt<WatchNotes>()...)
       └─ cubit.watch(uid)
            └─ WatchNotes(uid)
                 └─ NotesRepository.watchNotes(uid)
                      └─ NotesRemoteDataSource.watchNotes(uid)
                           └─ Firestore /users/{uid}/notes
                                .orderBy(updatedAt, descending: true)
                                .snapshots()
```

The stream is owned by the cubit (`_subscription`), which cancels the previous subscription when `watch()` is called again and on `close()`.

### Write path — `NoteEditorCubit.submit()`

```
NoteEditorCubit.submit()
  ├─ validate (trim, length)
  ├─ if editing: UpdateNote(id, ownerId, title, description, createdAt)
  │    └─ NotesRepository.updateNote(Note)
  │         └─ NotesRemoteDataSource.updateNote(NoteModel)
  │              └─ Firestore .doc(note.id).update(map)
  └─ else: AddNote(ownerId, title, description)
       └─ NotesRepository.addNote(...)
            └─ NotesRemoteDataSource.addNote(...)
                 └─ Firestore runTransaction:
                       set(/users/{uid}, merged updatedAt) + set(new note, map)
```

`FieldValue.serverTimestamp()` is used inside `NoteModel.toFirestore()` so the server assigns `createdAt` / `updatedAt` authoritatively.

### Delete path

```
NotesListCubit.delete(ownerId, id)
  └─ DeleteNote({ownerId, id})
       └─ NotesRepository.deleteNote(ownerId: ..., id: ...)
            └─ NotesRemoteDataSource.deleteNoteForOwner(ownerId, id)
                 └─ Firestore .doc(id).delete()
```

---

## 4. Auth flow

`AuthGate` wraps `FirebaseAuth.instance`:

- `ensureSignedIn()` returns the current uid, or performs `signInAnonymously()` on first launch (caches the user to avoid re-auth).
- `signOut()` signs out and the cubit re-bootstraps.
- `watchUid()` exposes `authStateChanges` for any listener that needs sign-in/sign-out events.

`AuthCubit` exposes a sealed `AuthState` → `Initial` / `Authenticating` / `Authenticated(uid)` / `AuthFailed(message)`. `NotesApp`'s `_AuthGate` widget switches between loading, error, and `NotesListScreen` based on this state.

`getIt` is shared across the app — every cubit resolved through `BlocProvider` is constructed from `getIt` lookups. `AuthGate` is registered as a lazy singleton so we have exactly one FirebaseAuth reference.

---

## 5. State management

- All states are **sealed** (`AuthState`, `NotesListState`, `NoteEditorState`) so the analyzer enforces exhaustive handling at every `switch` site.
- `Equatable` powers all equality for `BlocBuilder` rebuilds.
- `NoteEditorState.copyWith` uses a private `_unset` sentinel so nullable fields (`titleError`, `descriptionError`, `errorMessage`) can be explicitly cleared.
- `BlocConsumer` is used for screens that need to listen for side effects (snackbar, navigation).

---

## 6. Repository contract — ownership

Every repository method carries `ownerId` explicitly:

```dart
Stream<List<Note>> watchNotes(String ownerId);
Future<Note> addNote({required String ownerId, required String title, required String description});
Future<Note> updateNote(Note note);
Future<void> deleteNote({required String ownerId, required String id});
```

This keeps the source of truth in the caller (the cubit) and prevents the repository from inventing context. The Firestore layout is `/users/{uid}/notes/{noteId}`, locked down by security rules (see `README.md`).

---

## 7. Error model

- `core/errors/exceptions.dart` — `ServerException`, `AuthException`, `NotFoundException` (data layer exceptions).
- `core/errors/failures.dart` — sealed `Failure` with `ServerFailure`, `NetworkFailure`, `AuthFailure`, `ValidationFailure(field)`, `NotFoundFailure`.
- Data layer throws → cubits catch → emit `*Error(message)` or surface as a snackbar.

---

## 8. DI graph (`core/di/injection.dart`)

```
FirebaseAuth        (lazy singleton)
FirebaseFirestore   (lazy singleton)
AuthGate            (lazy singleton)
NotesRemoteDataSource (lazy singleton, ← Firestore)
NotesRepository     (lazy singleton, ← DataSource)
WatchNotes          (lazy singleton, ← Repository)
AddNote             (lazy singleton, ← Repository)
UpdateNote          (lazy singleton, ← Repository)
DeleteNote          (lazy singleton, ← Repository)
AuthCubit           (factory)
NotesListCubit      (factory)
NoteEditorCubit     (factoryParam<ownerId>)
```

`setupInjection()` is idempotent: a re-entry guard (`isRegistered<FirebaseAuth>()`) prevents double-registration.

---

## 9. Styling rules

- Material `ThemeData` (for `AppBar`, `InputDecoration`, splash colors).
- `ShadThemeData` (for `ShadApp`, `ShadCard`, `ShadDialog`, `ShadButton`, `ShadInputDecorator`).
- All `ShadCard`s use `shadows: <BoxShadow>[]` — **no elevation, no borders** (the premium look).
- `splashFactory: NoSplash.splashFactory`, transparent highlight/splash colors — interactions are still tappable, but visually quiet.
- Tokens (`AppColors`, `AppSizes`, `AppStrings`) are the single source of truth: no inline hex literals in screens/widgets.

---

## 10. Adding a new feature (workflow)

1. Add an entity in `features/<feature>/domain/entities/`.
2. Add a repository abstract in `features/<feature>/domain/repositories/`.
3. Add use-case classes in `features/<feature>/domain/usecases/`.
4. Implement the remote data source + repo in `features/<feature>/data/`.
5. Register everything new in `setupInjection()`.
6. Build cubits in `features/<feature>/presentation/cubit/`.
7. Build screens + widgets in `features/<feature>/presentation/`.
8. Add a route in `core/constants/app_routes.dart` and wire it in `NotesAppRouter.onGenerateRoute`.

Run `flutter analyze` after each step.
