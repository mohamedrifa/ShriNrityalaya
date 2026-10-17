import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../theme/acharya_colors.dart';
import '../../theme/acharya_text_styles.dart';

class ActionCard extends StatelessWidget {
  final String title;
  final String body;
  final String linkText;
  final IconData linkIcon;

  const ActionCard({
    super.key,
    required this.title,
    required this.body,
    required this.linkText,
    required this.linkIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AcharyaColors.cardFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AcharyaColors.cardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AcharyaTextStyles.cardTitle),
            const SizedBox(height: 6),
            Text(body, style: AcharyaTextStyles.cardBody, maxLines: 3, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Divider(color: AppColors.sandBorderSoft, height: 1, thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(linkText, style: AcharyaTextStyles.cardLink),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AcharyaColors.gold,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(linkIcon, color: Colors.white, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
