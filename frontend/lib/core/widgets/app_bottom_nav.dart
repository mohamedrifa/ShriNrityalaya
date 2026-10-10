import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show bottom nav if logged in (safety check)
    final role = ref.watch(authProvider);
    if (role == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryNavy,
        unselectedItemColor: AppColors.primaryNavy.withValues(alpha: 0.5),
        showUnselectedLabels: true,
        currentIndex: currentIndex,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Lessons'),
          const BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Events'),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentIndex == 3 ? AppColors.primaryGold.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_outline),
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == currentIndex) return; // Do nothing if already on the tab

          if (index == 0) {
            final userRole = ref.read(authProvider).userRole;
            if (userRole == 'Teacher' || userRole == 'SystemAdmin') context.go('/dashboard/teacher');
            else if (userRole == 'Student') context.go('/dashboard/student');
            else if (userRole == 'Parent') context.go('/dashboard/parent');
            else context.go('/dashboard/teacher'); // fallback
          } else if (index == 1) {
            context.go('/learning');
          } else if (index == 2) {
            context.go('/events');
          } else if (index == 3) {
            context.go('/profile');
          }
        },
      ),
    );
  }
}
