import 'package:flutter/material.dart';
import '../../theme/acharya_colors.dart';
import '../../theme/acharya_text_styles.dart';
import 'package:go_router/go_router.dart';

class HeaderBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final String initials;

  const HeaderBar({
    super.key,
    required this.onMenuTap,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Hamburger menu that opens menu drawer
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.menu, color: AcharyaColors.navy, size: 28),
                  onPressed: onMenuTap,
                  tooltip: 'Open menu',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),

            // Center: Logo and Brand
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_crescent.png',
                    height: 40,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'BHARATANATYAM\nACADEMY',
                    textAlign: TextAlign.center,
                    style: AcharyaTextStyles.brand,
                  ),
                ],
              ),
            ),

            // Right: Bell + Settings icons
            SizedBox(
              width: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: AcharyaColors.navy, size: 24),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: AcharyaColors.navy,
                      child: Icon(Icons.person, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
