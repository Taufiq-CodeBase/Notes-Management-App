import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/constants/app_routes.dart';
import '../core/theme/app_theme.dart' show AppTheme;
import '../core/di/injection.dart';
import '../core/network/auth_gate.dart';
import '../features/notes/presentation/cubit/auth_cubit.dart';
import '../features/notes/presentation/cubit/auth_state.dart';
import '../features/notes/presentation/screens/note_editor_screen.dart';
import '../features/notes/presentation/screens/notes_list_screen.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(getIt<AuthGate>())..bootstrap(),
      child: ShadApp(
        title: 'Notes',
        theme: AppTheme.shadLight(),
        darkTheme: AppTheme.shadDark(),
        themeMode: ThemeMode.system,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          Authenticated() => const NotesListScreen(),
          AuthFailed(:final message) => _AuthErrorView(message: message),
          _ => const _AuthLoadingView(),
        };
      },
    );
  }
}

class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _AuthErrorView extends StatelessWidget {
  final String message;

  const _AuthErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class NotesAppRouter {
  const NotesAppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.notesList:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotesListScreen(),
        );
      case AppRoutes.noteEditor:
        final arg = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NoteEditorScreen(note: arg as dynamic),
        );
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const NotesListScreen(),
        );
    }
  }
}