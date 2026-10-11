import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final Color selectedColor = AppColors.primaryNavy;
    final Color unselectedColor =
        AppColors.primaryNavy.withValues(alpha: 0.48);

    return SafeArea(
      top: false,
      child: Container(
        height: 77,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selectedColor.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: selectedColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(
              context: context,
              index: 0,
              currentIndex: currentIndex,
              icon: Icons.home_rounded,
              label: 'Home',
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                if (currentIndex == 0) return;

                final userRole = authState.userRole;

                if (userRole == 'Teacher' || userRole == 'SystemAdmin') {
                  context.go('/dashboard/teacher');
                } else if (userRole == 'Student') {
                  context.go('/dashboard/student');
                } else if (userRole == 'Parent') {
                  context.go('/dashboard/parent');
                } else {
                  context.go('/dashboard/teacher');
                }
              },
            ),
            _buildNavItem(
              context: context,
              index: 1,
              currentIndex: currentIndex,
              icon: Icons.menu_book_rounded,
              label: 'Lessons',
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                if (currentIndex != 1) {
                  context.go('/learning');
                }
              },
            ),
            _buildNavItem(
              context: context,
              index: 2,
              currentIndex: currentIndex,
              icon: Icons.calendar_month_rounded,
              label: 'Events',
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                if (currentIndex != 2) {
                  context.go('/events');
                }
              },
            ),
            _buildNavItem(
              context: context,
              index: 3,
              currentIndex: currentIndex,
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () {
                if (currentIndex != 3) {
                  context.go('/profile');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required Color selectedColor,
    required Color unselectedColor,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 4,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: isSelected ? 76 : 52,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? selectedColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : unselectedColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}