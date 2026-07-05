import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return _web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions not configured for this platform.',
        );
    }
  }

  static String get _apiKeyWeb =>
      const String.fromEnvironment('FIREBASE_API_KEY_WEB');
  static String get _apiKeyAndroid =>
      const String.fromEnvironment('FIREBASE_API_KEY_ANDROID');
  static String get _apiKeyIos =>
      const String.fromEnvironment('FIREBASE_API_KEY_IOS');
  static String get _projectId =>
      const String.fromEnvironment('FIREBASE_PROJECT_ID');
  static String get _appIdWeb =>
      const String.fromEnvironment('FIREBASE_APP_ID_WEB');
  static String get _appIdAndroid =>
      const String.fromEnvironment('FIREBASE_APP_ID_ANDROID');
  static String get _appIdIos =>
      const String.fromEnvironment('FIREBASE_APP_ID_IOS');
  static String get _messagingSenderId =>
      const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static String get _authDomain =>
      const String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static String get _storageBucket =>
      const String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static String get _iosBundleId =>
      const String.fromEnvironment('FIREBASE_IOS_BUNDLE_ID');

  static Never _missing(String key) => throw StateError(
        'Missing --dart-define $key=<value>. '
        'Pass the value from .env at build/run time. '
        'Never commit secrets to source control.',
      );

  static FirebaseOptions get _web {
    if (_apiKeyWeb.isEmpty ||
        _appIdWeb.isEmpty ||
        _projectId.isEmpty ||
        _messagingSenderId.isEmpty ||
        _authDomain.isEmpty ||
        _storageBucket.isEmpty) {
      _missing('FIREBASE_API_KEY_WEB');
    }
    return FirebaseOptions(
      apiKey: _apiKeyWeb,
      appId: _appIdWeb,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      authDomain: _authDomain,
      storageBucket: _storageBucket,
    );
  }

  static FirebaseOptions get _android {
    if (_apiKeyAndroid.isEmpty ||
        _appIdAndroid.isEmpty ||
        _projectId.isEmpty ||
        _messagingSenderId.isEmpty ||
        _storageBucket.isEmpty) {
      _missing('FIREBASE_API_KEY_ANDROID');
    }
    return FirebaseOptions(
      apiKey: _apiKeyAndroid,
      appId: _appIdAndroid,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket,
    );
  }

  static FirebaseOptions get _ios {
    if (_apiKeyIos.isEmpty ||
        _appIdIos.isEmpty ||
        _projectId.isEmpty ||
        _messagingSenderId.isEmpty ||
        _storageBucket.isEmpty ||
        _iosBundleId.isEmpty) {
      _missing('FIREBASE_API_KEY_IOS');
    }
    return FirebaseOptions(
      apiKey: _apiKeyIos,
      appId: _appIdIos,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket,
      iosBundleId: _iosBundleId,
    );
  }
}