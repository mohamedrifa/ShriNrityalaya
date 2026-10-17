import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_version_constants.dart';
import '../theme/app_colors.dart';
import 'app_update_info.dart';

/// An elegant Bharathanatyam-themed modal dialog that notifies users of
/// an available application update.
class AppUpdateDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;
  final VoidCallback? onLater;

  const AppUpdateDialog({
    super.key,
    required this.updateInfo,
    this.onLater,
  });

  static bool isDialogOpen = false;
  static AppUpdateInfo? currentActiveUpdate;

  /// Displays the dialog.
  /// If [updateInfo.isMandatoryUpdate] is true, the dialog cannot be dismissed.
  static Future<void> show(
    BuildContext context,
    AppUpdateInfo updateInfo, {
    VoidCallback? onProceed,
  }) async {
    // If dialog is already showing
    if (isDialogOpen) {
      if (currentActiveUpdate?.isMandatoryUpdate == false && updateInfo.isMandatoryUpdate) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } else {
        return;
      }
    }

    isDialogOpen = true;
    currentActiveUpdate = updateInfo;

    try {
      await showDialog(
        context: context,
        barrierDismissible: !updateInfo.isMandatoryUpdate,
        builder: (dialogCtx) {
          return PopScope(
            canPop: !updateInfo.isMandatoryUpdate,
            child: AppUpdateDialog(
              updateInfo: updateInfo,
              onLater: () {
                Navigator.of(dialogCtx).pop();
                if (onProceed != null) onProceed();
              },
            ),
          );
        },
      );
    } finally {
      isDialogOpen = false;
      currentActiveUpdate = null;
    }
  }

  Future<void> _handleDownload(BuildContext context) async {
    final rawUrl = updateInfo.appUrl.trim();
    if (rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download link is currently unavailable.'),
          backgroundColor: AppColors.crimsonAbsent,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open download link: $e'),
              backgroundColor: AppColors.crimsonAbsent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMandatory = updateInfo.isMandatoryUpdate;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.goldFrameBorder.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Decorative Icon
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navyHeader, AppColors.navyHeroDeep],
                  ),
                  border: Border.all(
                    color: AppColors.goldFrameBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyHeroDeep.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  color: AppColors.goldBright,
                  size: 32,
                ),
              ),

              const SizedBox(height: 14),

              // 2. Mandatory Alert Tag (if applicable)
              if (isMandatory) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.crimsonDueBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.crimsonDueBorder,
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 13,
                        color: AppColors.crimsonAbsent,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'MANDATORY UPDATE',
                        style: TextStyle(
                          color: AppColors.crimsonAbsent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 3. Title
              const Text(
                'New Update Available',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavyText,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 8),

              // 4. Subtitle Description
              Text(
                isMandatory
                    ? 'A required update of Shri Nrityalaya is available. You must update to the latest version to continue.'
                    : 'A new version of Shri Nrityalaya is ready with the latest features, improvements, and performance enhancements.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondarySlate.withValues(alpha: 0.95),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 16),

              // 5. Version Comparison Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.creamCardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.sandDivider,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'CURRENT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textMutedSlate,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v${AppVersionConstants.currentAppVersion}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkNavyText,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.goldTitle,
                      size: 18,
                    ),
                    Column(
                      children: [
                        const Text(
                          'LATEST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.goldTitle,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v${updateInfo.displayVersion}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyHeader,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. Primary Action: Download Update
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _handleDownload(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyHeader,
                    foregroundColor: AppColors.goldBright,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: AppColors.goldFrameBorder,
                        width: 1.2,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: Text(
                    isMandatory ? 'Download Update Now' : 'Download Update',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // 7. Secondary "Later" Button (only shown for non-mandatory updates)
              if (!isMandatory) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: TextButton(
                    onPressed: onLater,
                    child: const Text(
                      'Later',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondarySlate,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
