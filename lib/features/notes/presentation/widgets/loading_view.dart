import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.mutedFor(context);
    return Center(
      child: SizedBox(
        width: AppSizes.iconLg,
        height: AppSizes.iconLg,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(muted),
        ),
      ),
    );
  }
}