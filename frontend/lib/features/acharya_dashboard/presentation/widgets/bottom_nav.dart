import 'package:flutter/material.dart';
import '../../theme/acharya_colors.dart';
import '../../theme/acharya_text_styles.dart';

class AcharyaBottomNav extends StatelessWidget {
  final int currentIndex;

  const AcharyaBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AcharyaColors.screenBackground.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, 'Home', Icons.person_outline),
          _buildNavItem(1, 'Classes', Icons.group_outlined),
          _buildNavItem(2, 'Lessons', Icons.menu_book_outlined),
          _buildNavItem(3, 'Feedback', Icons.chat_bubble_outline),
          _buildNavItem(4, 'Settings', Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isActive = index == currentIndex;

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AcharyaColors.goldPale,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AcharyaColors.gold, width: 2),
              ),
              child: Icon(icon, color: AcharyaColors.navy, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: AcharyaTextStyles.bottomNavLabel.copyWith(color: AcharyaColors.navy, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AcharyaColors.navInactive, size: 26),
            const SizedBox(height: 6),
            Text(label, style: AcharyaTextStyles.bottomNavLabel.copyWith(color: AcharyaColors.navInactive)),
          ],
        ),
      ),
    );
  }
}
