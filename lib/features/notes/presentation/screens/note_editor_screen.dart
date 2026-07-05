import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/update_note.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../cubit/note_editor_cubit.dart';
import '../cubit/note_editor_state.dart';

class NoteEditorScreen extends StatelessWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthCubit>().state;
    if (auth is! Authenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return BlocProvider<NoteEditorCubit>(
      create: (_) {
        final cubit = NoteEditorCubit(
          addNote: getIt<AddNote>(),
          updateNote: getIt<UpdateNote>(),
          ownerId: auth.uid,
        );
        if (note != null) cubit.loadFor(note!);
        return cubit;
      },
      child: const _EditorView(),
    );
  }
}

class _EditorView extends StatelessWidget {
  const _EditorView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteEditorCubit, NoteEditorState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == EditorStatus.saved) {
          Navigator.of(context).pop();
        } else if (state.status == EditorStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? AppStrings.genericError,
              ),
            ),
          );
        }
      },
      builder: (context, state) => _EditorScaffold(state: state),
    );
  }
}

class _EditorScaffold extends StatelessWidget {
  final NoteEditorState state;

  const _EditorScaffold({required this.state});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceFor(context);
    final fg = AppColors.foregroundFor(context);

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: Text(
          state.isEditing ? AppStrings.editNote : AppStrings.newNote,
          style: TextStyle(
            color: fg,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacing12,
              vertical: AppSizes.spacing8,
            ),
            child: ShadButton(
              onPressed: state.canSubmit
                  ? () => context.read<NoteEditorCubit>().submit()
                  : null,
              child: state.status == EditorStatus.saving
                  ? const SizedBox(
                      width: AppSizes.iconMd,
                      height: AppSizes.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(AppStrings.save),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FieldLabel(text: AppStrings.titleLabel),
              const SizedBox(height: AppSizes.spacing8),
              _FieldShell(
                child: TextField(
                  controller: TextEditingController(text: state.title)
                    ..selection = TextSelection.collapsed(
                      offset: state.title.length,
                    ),
                  onChanged: (v) =>
                      context.read<NoteEditorCubit>().onTitleChanged(v),
                  decoration: InputDecoration(
                    hintText: AppStrings.titleHint,
                    errorText: state.titleError,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacing16),
              _FieldLabel(text: AppStrings.descriptionLabel),
              const SizedBox(height: AppSizes.spacing8),
              _FieldShell(
                child: TextField(
                  controller: TextEditingController(text: state.description)
                    ..selection = TextSelection.collapsed(
                      offset: state.description.length,
                    ),
                  onChanged: (v) =>
                      context.read<NoteEditorCubit>().onDescriptionChanged(v),
                  minLines: 5,
                  maxLines: 12,
                  decoration: InputDecoration(
                    hintText: AppStrings.descriptionHint,
                    errorText: state.descriptionError,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.foregroundFor(context),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  final Widget child;

  const _FieldShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return ShadInputDecorator(
      decoration: ShadDecoration(
        border: ShadBorder(
          radius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      child: child,
    );
  }
}