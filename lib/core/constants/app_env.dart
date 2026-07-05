class AppEnv {
  const AppEnv._();

  static String? get _raw => const String.fromEnvironment('APP_FIREBASE_OPTIONS');

  static String? get firebaseOptionsPath {
    final value = _raw;
    return value == null || value.isEmpty ? null : value;
  }

  static bool get hasFirebaseOptions =>
      (firebaseOptionsPath ?? '').isNotEmpty;
}