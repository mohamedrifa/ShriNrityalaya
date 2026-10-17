import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_error_handler.dart';

class ErrorView extends StatelessWidget {
  final dynamic error;
  final String? message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    this.error,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveText = (message != null && message!.isNotEmpty)
        ? AppErrorHandler.toShortMessage(message)
        : AppErrorHandler.toShortMessage(error);

    IconData iconData = Icons.error_outline_rounded;
    if (effectiveText == 'No Internet') {
      iconData = Icons.wifi_off_rounded;
    } else if (effectiveText == 'Internal Server Error') {
      iconData = Icons.cloud_off_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.crimsonErrorBannerBg,
                border: Border.all(color: AppColors.crimsonAlertF5b7b1, width: 1.2),
              ),
              alignment: Alignment.center,
              child: Icon(
                iconData,
                size: 30,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              effectiveText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please try again in a moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: AppColors.primaryGold,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.goldBorder, width: 1.2),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
