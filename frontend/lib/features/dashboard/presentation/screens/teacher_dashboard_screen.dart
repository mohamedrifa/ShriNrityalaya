import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../core/network/api_client.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final baseUrl = ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String? imageUrl;
    profileState.whenData((profile) {
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    Widget profileAvatar = CircleAvatar(
      backgroundColor: AppColors.primaryGold,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage('$baseUrl$imageUrl') : null,
      child: imageUrl == null || imageUrl!.isEmpty ? const Icon(Icons.person, color: AppColors.primaryNavy) : null,
    );

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: profileAvatar,
            onPressed: () {
              GoRouter.of(context).push('/profile');
            }
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primaryNavy),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: profileAvatar,
                  ),
                  const SizedBox(height: 10),
                  const Text('Shri Nrityalaya', style: TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppColors.warning),
              title: const Text('Fee Management'),
              onTap: () {
                Navigator.pop(context); // close drawer
                GoRouter.of(context).push('/fees');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.primaryNavy),
              title: const Text('Manage Students'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/students');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_phone, color: AppColors.success),
              title: const Text('Directory'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/directory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library, color: AppColors.primaryNavy),
              title: const Text('Learning & Lessons'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/learning');
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.primaryGold),
              title: const Text('Student Progress'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/progress');
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: AppColors.error),
              title: const Text('Messages'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/messaging');
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: AppColors.success),
              title: const Text('Academy Events'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/events');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Profile & Settings'),
              onTap: () {
                Navigator.pop(context);
                GoRouter.of(context).push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your academy from here.',
              style: TextStyle(fontSize: 16, color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGridCard(context, 'Students', Icons.people, AppColors.primaryNavy, '/students'),
                _buildGridCard(context, 'Directory', Icons.contact_phone, AppColors.success, '/directory'),
                _buildGridCard(context, 'Attendance', Icons.check_circle, AppColors.success, '/attendance'),
                _buildGridCard(context, 'Fees', Icons.receipt_long, AppColors.warning, '/fees'),
                _buildGridCard(context, 'Lessons', Icons.video_library, AppColors.primaryNavy, '/learning'),
                _buildGridCard(context, 'Progress', Icons.trending_up, AppColors.primaryGold, '/progress'),
                _buildGridCard(context, 'Messages', Icons.campaign, AppColors.error, '/messaging'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
