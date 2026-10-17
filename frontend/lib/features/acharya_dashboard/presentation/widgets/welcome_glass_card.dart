import 'package:flutter/material.dart';
import '../../theme/acharya_colors.dart';
import '../../theme/acharya_text_styles.dart';
import 'progress_row.dart';

class WelcomeGlassCard extends StatelessWidget {
  final String username;

  const WelcomeGlassCard({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.black,
            Colors.black,
            Colors.transparent,
          ],
          stops: const [0.0, 0.82, 1.0], // Fade right 18%
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AcharyaColors.navy.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AcharyaColors.gold.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Namaskaram,\n$username!',
              style: AcharyaTextStyles.greeting,
            ),
            const SizedBox(height: 6),
            Text(
              'Guide the next generation of mastery',
              style: AcharyaTextStyles.subtitle,
            ),
            const SizedBox(height: 14),
            const ProgressRow(
              title: 'View Class Roster',
              progress: 0.25,
            ),
            const SizedBox(height: 12),
            const ProgressRow(
              title: 'Grade Adavus - Part 1',
              progress: 0.60,
              isGold: true,
              isCompleted: true,
            ),
          ],
        ),
      ),
    );
  }
}
