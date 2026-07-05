import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/watch_notes.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../cubit/notes_list_cubit.dart';
import '../cubit/notes_list_state.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/note_tile.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotesListCubit>(
      create: (_) {
        final cubit = NotesListCubit(
          watchNotes: getIt<WatchNotes>(),
          deleteNote: getIt<DeleteNote>(),
        );
        final auth = context.read<AuthCubit>().state;
        if (auth is Authenticated) {
          cubit.watch(auth.uid);
        }
        return cubit;
      },
      child: const _NotesListView(),
    );
  }
}

class _NotesListView extends StatelessWidget {
  const _NotesListView();

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.foregroundFor(context);
    final surface = AppColors.surfaceFor(context);

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: Text(
          AppStrings.appTitle,
          style: TextStyle(
            color: fg,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
      ),
      floatingActionButton: const _NewNoteFab(),
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => curr is Authenticated,
        listener: (context, state) {
          if (state is Authenticated) {
            context.read<NotesListCubit>().watch(state.uid);
          }
        },
        builder: (context, _) {
          return BlocBuilder<NotesListCubit, NotesListState>(
            builder: (context, state) {
              return _Body(state: state);
            },
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final NotesListState state;

  const _Body({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is NotesListInitial || state is NotesListLoading) {
      return const LoadingView();
    }
    if (state is NotesListError) {
      final message = (state as NotesListError).message;
      return ErrorView(
        message: message,
        onRetry: () {
          final auth = context.read<AuthCubit>().state;
          if (auth is Authenticated) {
            context.read<NotesListCubit>().watch(auth.uid);
          }
        },
      );
    }
    final notes = (state as NotesListLoaded).notes;
    if (notes.isEmpty) {
      return const EmptyState();
    }
    return _NotesList(notes: notes);
  }
}

class _NotesList extends StatelessWidget {
  final List<Note> notes;

  const _NotesList({required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacing16,
        AppSizes.spacing8,
        AppSizes.spacing16,
        96,
      ),
      itemCount: notes.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppSizes.spacing12),
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteTile(
          note: note,
          onTap: () => _openEditor(context, note),
          onLongPress: () => _confirmAndDelete(context, note),
        );
      },
    );
  }

  Future<void> _openEditor(BuildContext context, Note note) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.noteEditor,
      arguments: note,
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, Note note) async {
    final confirmed = await showConfirmDeleteDialog(context);
    if (!confirmed || !context.mounted) return;
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) return;
    await context.read<NotesListCubit>().delete(
          ownerId: auth.uid,
          id: note.id,
        );
  }
}

class _NewNoteFab extends StatelessWidget {
  const _NewNoteFab();

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.foregroundFor(context);
    final accent = Theme.of(context).colorScheme.primary;
    return FloatingActionButton(
      backgroundColor: accent,
      foregroundColor: fg,
      shape: const CircleBorder(),
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.noteEditor),
      child: const Icon(Icons.add, size: AppSizes.iconLg),
    );
  }
}