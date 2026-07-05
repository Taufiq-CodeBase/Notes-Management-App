# HELPING.md — AI assistant guide

This file tells an AI coding assistant (or a new contributor) how to safely extend the **Notes Management App** without breaking the architectural rules.

## 0. Read first

Before changing anything, read:

1. `ARCHITECTURE.md` — the layer rules and data flow.
2. `README.md` — the run instructions and Firestore rules.
3. The file you intend to change **and its nearest neighbors** (the cubit + state + screen that uses it).

## 1. Hard rules — non-negotiable

- **Dependency direction is one-way.** `presentation → domain ← data`. Never import `presentation/` from `domain/` or `data/`. Never import `data/` from `domain/`.
- **Domain stays pure Dart.** No `package:flutter/*` and no `package:firebase_*` in `features/*/domain/`. Validate this with:
  ```bash
  grep -RE "package:flutter|firebase_" lib/features/*/domain
  ```
  Expect zero hits.
- **No secrets in source.** Firebase keys live in `.env`, never in `firebase_options.dart` or anywhere under `lib/`. `.env` is git-ignored; `.env.example` is the template.
- **No borders, no shadows on cards.** Keep the premium look. `ShadCard` always uses `shadows: <BoxShadow>[]`. If you add a new theme element, prefer `ShadDecoration` over `BoxDecoration`.
- **All UI strings go through `AppStrings`.** Don't inline user-facing copy in widgets.
- **All colors go through `AppColors`.** No raw `Color(0xFF...)` in screens or widgets (theme files are the only exception).
- **State classes are sealed.** If you add a new state to a cubit, extend the sealed base and handle the new branch at every `switch` site.

## 2. Cubit rules

- A cubit exposes a **sealed state**. Use `Equatable` so `BlocBuilder` rebuilds only on real changes.
- Use the `_unset` sentinel pattern when `copyWith` needs to null an optional field:
  ```dart
  Object? fooError = _unset;
  fooError: identical(fooError, _unset) ? this.fooError : fooError as String?,
  ```
- Cancel long-lived subscriptions in `close()`:
  ```dart
  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
  ```
- For one-shot actions (`submit`, `delete`), guard against double-fire:
  ```dart
  if (state.status == EditorStatus.saving) return;
  ```

## 3. Adding a new feature

Follow the workflow in `ARCHITECTURE.md` §10. Minimum viable checklist:

- [ ] `features/<feature>/domain/entities/<thing>.dart`
- [ ] `features/<feature>/domain/repositories/<thing>_repository.dart` (abstract)
- [ ] One or more use-case classes in `features/<feature>/domain/usecases/`
- [ ] `features/<feature>/data/models/<thing>_model.dart`
- [ ] `features/<feature>/data/datasources/<thing>_remote_data_source.dart` (abstract + Impl)
- [ ] `features/<feature>/data/repositories/<thing>_repository_impl.dart`
- [ ] Cubits + sealed states in `features/<feature>/presentation/cubit/`
- [ ] Screens + reusable widgets in `features/<feature>/presentation/`
- [ ] New entries in `setupInjection()` in `core/di/injection.dart`
- [ ] Routes in `core/constants/app_routes.dart` and `NotesAppRouter.onGenerateRoute`
- [ ] Strings in `core/constants/app_strings.dart`
- [ ] Tokens (colors / sizes) added to `AppColors` / `AppSizes` if any new ones appear
- [ ] Run `flutter analyze` → expect `No issues found!`

## 4. Adding a new screen

1. Create a `StatelessWidget` in `features/<feature>/presentation/screens/`.
2. Wrap stateful needs in `BlocProvider` *inside* the screen (per-screen scope — don't lift to root unless shared).
3. Use `BlocBuilder` for render-only reactivity, `BlocListener` / `BlocConsumer` for one-shot side effects (snackbar, navigation).
4. Always check `context.mounted` after an `await Navigator.push` / dialog before reading context again.

## 5. Adding a new reusable widget

- Place it in `features/<feature>/presentation/widgets/` (or `core/widgets/` if it's feature-agnostic).
- Tokens only — never inline hex.
- Take callbacks (`onTap`, `onLongPress`) instead of coupling to navigation; the screen wires them up.
- Reuse `EmptyState`, `LoadingView`, `ErrorView` from `notes/presentation/widgets/` if they fit — generalize them later if a second feature needs them.

## 6. Working with Firestore

- **Never** write to a collection directly from a cubit. Always go through a use-case → repository → data source.
- Use `FieldValue.serverTimestamp()` for `createdAt` / `updatedAt` — never `DateTime.now()` in `toFirestore()`.
- Run writes inside `runTransaction` only when you need atomicity across multiple docs (e.g. the warm `/users/{uid}` doc + a new note).
- Wrap `FirebaseException` into `ServerException` at the data-source boundary; never let `FirebaseException` leak into cubits or UI.

## 7. Security rules reminder

The project ships with no rules file — you must paste the snippet from `README.md` §"Firestore rules" into the Firebase console before testing writes. The pattern is:

```
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

If you add a new top-level collection, **add a matching rule block**.

## 8. Environment variables

`.env` keys (all read via `String.fromEnvironment`):

| Key                          | Used by                        |
| ---------------------------- | ------------------------------ |
| `FIREBASE_API_KEY_WEB`       | `firebase_options.dart` (`_web`) |
| `FIREBASE_API_KEY_ANDROID`   | `_android`                     |
| `FIREBASE_API_KEY_IOS`       | `_ios`                         |
| `FIREBASE_PROJECT_ID`        | all platforms                  |
| `FIREBASE_APP_ID_WEB`        | `_web`                         |
| `FIREBASE_APP_ID_ANDROID`    | `_android`                     |
| `FIREBASE_APP_ID_IOS`        | `_ios`                         |
| `FIREBASE_MESSAGING_SENDER_ID` | all                          |
| `FIREBASE_AUTH_DOMAIN`       | `_web`                         |
| `FIREBASE_STORAGE_BUCKET`    | `_web`, `_android`, `_ios`     |
| `FIREBASE_IOS_BUNDLE_ID`     | `_ios`                         |

If a key is missing for the target you boot, `firebase_options.dart` throws a descriptive `StateError`. **Do not** silence that error — it exists so secrets don't accidentally end up in source.

## 9. Common pitfalls

- **Forgetting `await` on `runTransaction`.** It returns a `Future<void>` — call sites must `await` it.
- **Listening twice.** If you call `cubit.watch(uid)` twice without `await _subscription?.cancel()`, the second stream wins but the first listener still fires until cancelled.
- **Comparing `DateTime`s with `==`.** Use `isAtSameMomentAs` or rely on `Equatable`'s `props` (it deep-compares lists and DateTimes).
- **Hydrating a `TextField` from cubit state.** Don't bind via `initialValue` + a controller — use a `StatefulWidget` that syncs the controller in `didUpdateWidget`. The current editor screens use `TextEditingController(text: state.title)` which is acceptable for short forms but rebuilds the cursor; consider migrating to a controller-based form if needed.
- **Adding new dependencies.** Pin a version in `pubspec.yaml`, then run `flutter pub get`. Update this file's "Common pitfalls" if the dependency adds a constraint worth documenting.

## 10. Verification checklist before commit

- [ ] `flutter analyze` → "No issues found!"
- [ ] `flutter build web` → succeeds
- [ ] `git status` shows no `.env`, no `firebase_options.dart` with real keys, no `google-services.json` with live secrets
- [ ] New strings added to `AppStrings`
- [ ] New tokens added to `AppColors` / `AppSizes`
- [ ] DI updated in `setupInjection()`
- [ ] If Firestore layout changed, security rules updated to match