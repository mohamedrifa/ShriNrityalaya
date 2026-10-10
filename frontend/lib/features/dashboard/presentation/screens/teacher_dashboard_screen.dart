import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_scaffold.dart';

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

    return AppScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontFamily: 'Georgia', color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: AppColors.primaryGold,
        iconTheme: const IconThemeData(color: AppColors.primaryGold),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: AppColors.primaryGold, height: 4.0),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications, color: AppColors.primaryGold), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => GoRouter.of(context).push('/profile'),
              child: SizedBox(height: 32, width: 32, child: profileAvatar),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(
        roleSubtitle: 'Teacher Dashboard',
        menuItems: [
          DrawerMenuItem(title: 'Fee Management', icon: Icons.emoji_events_outlined, route: '/fees'),
          DrawerMenuItem(title: 'Manage Students', icon: Icons.people_alt_outlined, route: '/students'),
          DrawerMenuItem(title: 'Directory', icon: Icons.contact_phone_outlined, route: '/directory'),
          DrawerMenuItem(title: 'Learning & Lessons', icon: Icons.play_circle_outline, route: '/learning'),
          DrawerMenuItem(title: 'Student Progress', icon: Icons.auto_graph_outlined, route: '/progress'),
          DrawerMenuItem(title: 'Messages', icon: Icons.campaign_outlined, route: '/messaging'),
          DrawerMenuItem(title: 'Academy Events', icon: Icons.calendar_today_outlined, route: '/events'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your academy from here.',
              style: TextStyle(fontSize: 18, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildGridCard(context, 'Students', Icons.people, '/students'),
                _buildGridCard(context, 'Directory', Icons.contact_page_outlined, '/directory'),
                _buildGridCard(context, 'Attendance', Icons.how_to_reg, '/attendance'),
                _buildGridCard(context, 'Fees', Icons.monetization_on_outlined, '/fees'),
                _buildGridCard(context, 'Lessons', Icons.menu_book, '/learning'),
                _buildGridCard(context, 'Progress', Icons.auto_graph, '/progress'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Top right decorative lotus
            Positioned(
              top: 8,
              right: 8,
              child: Icon(Icons.spa, size: 24, color: AppColors.primaryGold.withValues(alpha: 0.3)),
            ),
            // Bottom left decorative lotus
            Positioned(
              bottom: 8,
              left: 8,
              child: Icon(Icons.spa, size: 24, color: AppColors.primaryGold.withValues(alpha: 0.3)),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7E6), // Pale gold circle
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppColors.primaryGold, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryNavy,
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
