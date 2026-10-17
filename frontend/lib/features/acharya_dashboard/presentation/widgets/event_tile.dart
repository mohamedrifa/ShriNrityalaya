import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../theme/acharya_colors.dart';
import '../../theme/acharya_text_styles.dart';

class EventTile extends StatelessWidget {
  final String dateDay;
  final String dateMonth;
  final String title;
  final String actionText;

  const EventTile({
    super.key,
    required this.dateDay,
    required this.dateMonth,
    required this.title,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, // ~56 plus padding
      margin: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AcharyaColors.cardFill,
        borderRadius: BorderRadius.circular(14),
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
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            // Date Block
            SizedBox(
              width: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dateDay, style: AcharyaTextStyles.eventDateNumber),
                  Text(dateMonth, style: AcharyaTextStyles.eventDateMonth),
                ],
              ),
            ),
            
            // Vertical Divider
            Container(
              width: 1,
              height: 36,
              color: AppColors.sandBorderSoft,
            ),
            
            // Title
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  title,
                  style: AcharyaTextStyles.eventTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Pill Button
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.creamWarmIvory,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AcharyaColors.gold, width: 1),
                ),
                child: Text(actionText, style: AcharyaTextStyles.pillLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
