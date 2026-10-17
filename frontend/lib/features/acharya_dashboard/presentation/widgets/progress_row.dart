import 'package:flutter/material.dart';
import '../../theme/acharya_colors.dart';
import '../../theme/acharya_text_styles.dart';

class ProgressRow extends StatelessWidget {
  final String title;
  final double progress;
  final bool isGold;
  final bool isCompleted;

  const ProgressRow({
    super.key,
    required this.title,
    required this.progress,
    this.isGold = false,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AcharyaTextStyles.subtitle),
            if (isCompleted)
              Row(
                children: [
                  const Icon(Icons.check, color: AcharyaColors.checkGreen, size: 14),
                  const SizedBox(width: 4),
                  Text('...ed', style: AcharyaTextStyles.subtitle.copyWith(color: Colors.white54, fontSize: 12)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isGold ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isGold ? AcharyaColors.gold : Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
