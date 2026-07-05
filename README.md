# Notes Management App

A Flutter + Firebase Firestore notes app with anonymous auth, clean architecture, Cubit state management, and a shadcn_ui (no-border / no-shadow) aesthetic.

----

## Features

- Anonymous sign-in — no password, no email, ever.
- Per-user note collection at `/users/{uid}/notes`.
- Live updates via Firestore streams (no manual refresh).
- Create, edit, delete notes with title + description.
- Inline validation (empty title / description).
- Light + dark themes, system-driven.
- Premium shadcn look — no card borders, no shadows.

---

## Stack

| Concern         | Choice                                    |
| --------------- | ----------------------------------------- |
| Framework       | Flutter 3.38 / Dart 3.10                  |
| State           | `flutter_bloc` Cubits                     |
| DI              | `get_it`                                  |
| Backend         | Firebase Auth (anonymous) + Firestore     |
| UI              | Material `ThemeData` + `shadcn_ui`        |
| Date formatting | `intl`                                    |
| Secrets         | `.env` via `--dart-define-from-file`      |

---

## Project layout

See [`ARCHITECTURE.md`](./ARCHITECTURE.md) for the full layer map and data flow.

```
lib/
├── app/                  # NotesApp + router
├── core/
│   ├── constants/        # AppColors, AppSizes, AppStrings, AppRoutes, AppEnv
│   ├── di/               # injection.dart (GetIt)
│   ├── errors/           # exceptions.dart + failures.dart
│   ├── network/          # auth_gate.dart (FirebaseAuth wrapper)
│   ├── theme/            # app_theme.dart (Material + Shad)
│   └── utils/            # date_formatter.dart
├── features/notes/
│   ├── domain/           # Note, NotesRepository (abstract), use-cases
│   ├── data/             # NoteModel, NotesRemoteDataSource (+ Impl), Repo Impl
│   └── presentation/     # Cubits, screens, widgets
├── firebase_options.dart # Reads keys via String.fromEnvironment
└── main.dart             # Firebase init + DI setup + runApp
```

---

## Prerequisites

1. **Flutter** stable channel, ≥ 3.38.
2. **A Firebase project** with:
   - Authentication → Anonymous sign-in enabled.
   - Firestore → Native mode.
   - A web app + (optionally) Android/iOS apps registered.
3. **Firebase CLI** + **FlutterFire CLI** if you want to regenerate `firebase.json`:
   ```powershell
   dart pub global activate flutterfire_cli
   ```

---

## Setup

### 1. Clone and install dependencies

```powershell
git clone <repo-url>
cd 'notes_app'
flutter pub get
```

### 2. Configure Firebase keys

The repo intentionally has **no secrets in source**. You must provide them via `.env`.

```powershell
Copy-Item .env.example .env
notepad .env
```

Fill in at minimum the **web** keys (and android/ios if you target those):

```
FIREBASE_API_KEY_WEB=AIza...
FIREBASE_API_KEY_ANDROID=AIza...
FIREBASE_API_KEY_IOS=AIza...
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_APP_ID_WEB=1:...:web:...
FIREBASE_APP_ID_ANDROID=1:...:android:...
FIREBASE_APP_ID_IOS=1:...:ios:...
FIREBASE_MESSAGING_SENDER_ID=...
FIREBASE_AUTH_DOMAIN=your-project-id.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_IOS_BUNDLE_ID=com.notes.app
```

> The keys are read at compile time via `String.fromEnvironment`. If a key is missing for the target you run, the app throws a descriptive `StateError` — that's intentional, it stops you from shipping placeholder secrets.

### 3. Enable Anonymous auth

Firebase console → **Authentication** → **Sign-in method** → enable **Anonymous**.

### 4. Set Firestore rules

Firebase console → **Firestore** → **Rules** → paste:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

Publish, then wait a few seconds for the rules to propagate.

---

## Running

### Web (Chrome)

```powershell
pwsh scripts\run.ps1 -Target web
```

Or directly:

```powershell
flutter run -d chrome --dart-define-from-file=.env
```

### Android

```powershell
pwsh scripts\run.ps1 -Target android
```

### iOS (macOS only)

```powershell
pwsh scripts\run.ps1 -Target ios
```

The script validates `.env` exists, then forwards to `flutter run --dart-define-from-file=.env -d <target>`.

---

## Building

```powershell
flutter build web --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
flutter build ios --dart-define-from-file=.env
```

The `build/web/` directory is fully static — drop it on any static host.

---

## Verifying the project

```powershell
flutter analyze
```

Expect:

```
No issues found! (ran in <N>s)
```

---

## Contributing

See [`HELPING.md`](./HELPING.md) for the AI-assistant / contributor guide (hard rules, cubit patterns, Firestore layout, common pitfalls).

---

## License

Private project — all rights reserved unless explicitly stated otherwise.
