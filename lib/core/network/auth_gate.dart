import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../errors/exceptions.dart';

class AuthGate {
  final FirebaseAuth _auth;
  User? _cachedUser;

  AuthGate({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? get currentUser => _cachedUser ?? _auth.currentUser;

  String? get currentUid => currentUser?.uid;

  Future<String> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) {
      _cachedUser = existing;
      return existing.uid;
    }
    try {
      final result = await _auth.signInAnonymously();
      _cachedUser = result.user;
      final uid = result.user?.uid;
      if (uid == null) {
        throw const AuthException('Anonymous sign-in returned no user.');
      }
      return uid;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Anonymous sign-in failed.',
        e,
      );
    }
  }

  Stream<String?> watchUid() => _auth.authStateChanges().map((user) => user?.uid);

  Future<void> signOut() => _auth.signOut();
}