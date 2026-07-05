import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

Future<bool> showConfirmDeleteDialog(BuildContext context) async {
  final destructive = AppColors.destructive;
  final result = await showShadDialog<bool>(
    context: context,
    builder: (context) {
      return ShadDialog(
        title: Text(
          AppStrings.confirmDeleteTitle,
          style: TextStyle(
            color: AppColors.foregroundFor(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        description: Text(
          AppStrings.confirmDeleteBody,
          style: TextStyle(color: AppColors.mutedFor(context)),
        ),
        actions: [
          ShadButton.outline(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          ShadButton(
            onPressed: () => Navigator.of(context).pop(true),
            backgroundColor: destructive,
            foregroundColor: Colors.white,
            child: const Text(AppStrings.delete),
          ),
        ],
      );
    },
  );
  return result ?? false;
}