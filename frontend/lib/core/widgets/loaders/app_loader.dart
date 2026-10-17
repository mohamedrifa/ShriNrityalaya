import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color color;
  final String? message;

  const AppLoader({
    super.key,
    this.size = 32.0,
    this.color = AppColors.primaryGold,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final loader = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );

    if (message != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            loader,
            const SizedBox(height: 12),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Center(child: loader);
  }
}
