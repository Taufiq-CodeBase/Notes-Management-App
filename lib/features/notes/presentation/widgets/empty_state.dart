import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final fg = AppColors.foregroundFor(context);
    final muted = AppColors.mutedFor(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppStrings.emptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacing8),
            Text(
              AppStrings.emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}