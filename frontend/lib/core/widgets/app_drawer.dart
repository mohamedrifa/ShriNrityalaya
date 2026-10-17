import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/profile/presentation/providers/profile_providers.dart';

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String route;

  DrawerMenuItem({required this.title, required this.icon, required this.route});
}

class AppDrawer extends ConsumerWidget {
  final String roleSubtitle;
  final List<DrawerMenuItem> menuItems;

  const AppDrawer({
    super.key,
    required this.roleSubtitle,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final baseUrl = ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String? imageUrl;
    profileState.whenData((profile) {
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    Widget profileAvatar = CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage('$baseUrl$imageUrl') : null,
      child: imageUrl == null || imageUrl!.isEmpty ? const Icon(Icons.person, color: AppColors.primaryNavy, size: 30) : null,
    );

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.creamWarmLightFdf5e6, // Light cream background
          image: DecorationImage(
            image: AssetImage('assets/images/temple_drawer_bg.png'),
            fit: BoxFit.fitHeight,
            alignment: Alignment.centerLeft,
            opacity: 0.1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
              decoration: const BoxDecoration(
                color: AppColors.primaryNavy,
                border: Border(bottom: BorderSide(color: AppColors.primaryGold, width: 4)),
              ),
              child: Row(
                children: [
                  // Mandala Frame + Avatar
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/mandala_frame.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryNavy,
                          child: profileAvatar,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shri Nrityalaya',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            color: AppColors.primaryGold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          roleSubtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Top Lotus
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Icon(Icons.spa, color: AppColors.primaryGold.withValues(alpha: 0.7), size: 32),
            ),

            // Scrollable Menu Items
            Expanded(
              child: Stack(
                children: [
                  // Temple background outline
                  Positioned(
                    right: -30,
                    bottom: -10,
                    width: 260, // Fixed width to keep it on the right side
                    child: Opacity(
                      opacity: 0.15,
                      child: Image.asset(
                        'assets/images/temple_drawer_bg.png',
                        color: AppColors.primaryGold,
                        colorBlendMode: BlendMode.srcIn,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: menuItems.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppColors.primaryGold.withValues(alpha: 0.2),
                      height: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                        leading: Icon(item.icon, color: AppColors.primaryGold, size: 28),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Close drawer
                          GoRouter.of(context).push(item.route);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Bottom Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.primaryNavy, thickness: 2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(Icons.spa, color: AppColors.primaryGold.withValues(alpha: 0.8), size: 24),
                  ),
                  const Expanded(child: Divider(color: AppColors.primaryNavy, thickness: 2)),
                ],
              ),
            ),

            // Profile & Settings
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              leading: const Icon(Icons.settings_outlined, color: AppColors.primaryGold, size: 28),
              title: const Text(
                'Profile & Settings',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/profile');
              },
            ),

            // Logout
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              leading: const Icon(Icons.logout, color: AppColors.primaryGold, size: 28),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(secureStorageProvider).delete(key: 'jwt_token');
                ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),

            // Bottom Lotus
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
              child: Icon(Icons.spa, color: AppColors.primaryGold.withValues(alpha: 0.5), size: 32),
            ),
          ],
        ),
      ),
    );
  }
}
