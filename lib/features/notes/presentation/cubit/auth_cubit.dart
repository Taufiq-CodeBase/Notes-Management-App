import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_gate.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthGate _authGate;

  AuthCubit(this._authGate) : super(const AuthInitial());

  Future<void> bootstrap() async {
    if (state is Authenticated) return;
    emit(const Authenticating());
    try {
      final uid = await _authGate.ensureSignedIn();
      emit(Authenticated(uid));
    } catch (e) {
      emit(AuthFailed(_humanize(e)));
    }
  }

  Future<void> signOut() async {
    await _authGate.signOut();
    emit(const AuthInitial());
    await bootstrap();
  }

  String _humanize(Object error) {
    final raw = error.toString();
    return raw.isEmpty ? 'Authentication failed' : raw;
  }
}