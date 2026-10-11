import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../acharya_dashboard/presentation/screens/acharya_dashboard_screen.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final profileState = ref.watch(profileProvider);
    final baseUrl = ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String? imageUrl;
    profileState.whenData((profile) {
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    final Widget profileAvatar = CircleAvatar(
      radius: 16,
      backgroundColor: AppColors.primaryGold,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage('$baseUrl$imageUrl') : null,
      child: imageUrl == null || imageUrl!.isEmpty ? const Icon(Icons.person, color: AppColors.primaryNavy, size: 20) : null,
    );

    return Scaffold(
      key: scaffoldKey,
      drawer: AppDrawer(
        roleSubtitle: 'Teacher Dashboard',
        menuItems: [
          DrawerMenuItem(title: 'Fee Management',     icon: Icons.emoji_events_outlined,  route: '/fees'),
          DrawerMenuItem(title: 'Manage Students',    icon: Icons.people_alt_outlined,     route: '/students'),
          DrawerMenuItem(title: 'Directory',          icon: Icons.contact_phone_outlined,  route: '/directory'),
          DrawerMenuItem(title: 'Learning & Lessons', icon: Icons.play_circle_outline,     route: '/learning'),
          DrawerMenuItem(title: 'Student Progress',   icon: Icons.auto_graph_outlined,     route: '/progress'),
          DrawerMenuItem(title: 'Messages',           icon: Icons.campaign_outlined,        route: '/messaging'),
          DrawerMenuItem(title: 'Academy Events',     icon: Icons.calendar_today_outlined, route: '/events'),
        ],
      ),
      backgroundColor: AcharyaColors.pageBackground,
      body: Stack(
        children: [
          // Left temple BG
          Positioned(
            left: 0, bottom: 0,
            width: MediaQuery.of(context).size.width * 0.35,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset('assets/images/temple_left.png',
                fit: BoxFit.fitWidth, alignment: Alignment.bottomLeft,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
          ),
          // Right temple BG
          Positioned(
            right: 0, bottom: 0,
            width: MediaQuery.of(context).size.width * 0.35,
            child: Opacity(
              opacity: 0.55,
              child: Image.asset('assets/images/temple_right.png',
                fit: BoxFit.fitWidth, alignment: Alignment.bottomRight,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            ),
          ),

          // Phone surface
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: const BoxDecoration(
                color: AcharyaColors.screenBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // Header: hamburger opens AppDrawer, profile avatar opens /profile
                  AcharyaHeaderBar(
                    onMenuTap: () => scaffoldKey.currentState?.openDrawer(),
                    profileAvatar: profileAvatar,
                    onProfileTap: () => context.push('/profile'),
                  ),

                  // Scrollable body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AcharyaHeroBanner(),

                          // Action cards — route to real pages
                          SizedBox(
                            height: 158,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(left: 16),
                              children: [
                                AcharyaActionCard(
                                  title: 'MY CLASSES',
                                  body: 'Manage student lists and attendance. 3 Classes Active.',
                                  linkText: 'Manage Classes',
                                  linkIcon: Icons.chevron_right,
                                  onTap: () => context.push('/students'),
                                ),
                                AcharyaActionCard(
                                  title: 'CURRICULUM REVIEW',
                                  body: 'Approve student submissions for Alarippu and Jatiswaram.',
                                  linkText: 'Review Submissions',
                                  linkIcon: Icons.check,
                                  onTap: () => context.push('/progress'),
                                ),
                                AcharyaActionCard(
                                  title: 'STUDENT PROGRESS',
                                  body: 'Track progress and share feedback.',
                                  linkText: 'Review Progress',
                                  linkIcon: Icons.chevron_right,
                                  onTap: () => context.push('/progress'),
                                ),
                              ],
                            ),
                          ),

                          // Academy Modules Grid from previous commit
                          Padding(
                            padding: const EdgeInsets.only(left: 20, top: 24,),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Academy Modules',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Manage your academy from here.',
                                  style: TextStyle(fontSize: 14, color: AppColors.deepNavy),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero, // Removes GridView's default padding
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
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom nav (existing AppBottomNav for real routing)
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: AppBottomNav(currentIndex: 0),
          ),
        ],
      ),
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
