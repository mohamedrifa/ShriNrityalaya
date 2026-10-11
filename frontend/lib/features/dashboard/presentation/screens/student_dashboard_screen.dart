import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../fees/presentation/providers/fee_obligations_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../progress/presentation/providers/progress_providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class StudentDashboardScreen extends ConsumerWidget {
  // ignore: use_super_parameters
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsState = ref.watch(studentAssessmentsProvider('me'));
    final feesState = ref.watch(feeObligationsProvider);
    final profileState = ref.watch(profileProvider);
    final baseUrl = ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String username = 'Student';
    String? imageUrl;
    profileState.whenData((profile) {
      username = profile['firstName'] ?? profile['userName'] ?? 'Student';
      if (username.isEmpty) username = 'Student';
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    Widget profileAvatar = CircleAvatar(
      backgroundColor: AppColors.primaryGold,
      backgroundImage: imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage('$baseUrl$imageUrl') : null,
      child: imageUrl == null || imageUrl!.isEmpty ? const Icon(Icons.person, color: AppColors.primaryNavy) : null,
    );

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return AppScaffold(
      scaffoldKey: scaffoldKey,
      drawer: AppDrawer(
        roleSubtitle: 'Student Dashboard',
        menuItems: [
          DrawerMenuItem(title: 'Fee Management', icon: Icons.receipt_long, route: '/fees'),
          DrawerMenuItem(title: 'Learning & Lessons', icon: Icons.video_library, route: '/learning'),
          DrawerMenuItem(title: 'My Progress', icon: Icons.trending_up, route: '/progress'),
          DrawerMenuItem(title: 'Announcements', icon: Icons.campaign_outlined, route: '/messaging'),
          DrawerMenuItem(title: 'Academy Events', icon: Icons.calendar_today_outlined, route: '/events'),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Background Structure
            Column(
              children: [
                // Fixed Navy Header Background
                Container(
                  height: 190,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Menu Icon (Simulating Profile Icon from mockup)
                      GestureDetector(
                        onTap: () => scaffoldKey.currentState?.openDrawer(),
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryGold,
                          child: Icon(Icons.menu, color: AppColors.primaryNavy),
                        ),
                      ),
                      // Title
                      const Column(
                        children: [
                          Text('BHARATANATYAM', style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                          Text('ACADEMY', style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          Text('Dashboard', style: TextStyle(color: AppColors.primaryGold, fontSize: 24, fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      // Notification + Profile
                      Row(
                        children: [
                          IconButton(icon: const Icon(Icons.notifications, color: AppColors.primaryGold), onPressed: () {}),
                          GestureDetector(
                            onTap: () => context.push('/profile'),
                            child: SizedBox(height: 40, width: 40, child: profileAvatar),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                // The Scrollable Content below the header
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 130, left: 16, right: 16, bottom: 24), // 130px top padding to clear the overlapping Welcome Card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Action Grid (Lessons & Events)
                        Row(
                          children: [
                            Expanded(
                              child: _buildGridCard(context, 'Lessons', Icons.menu_book, '/learning'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildGridCard(context, 'Events', Icons.event, '/events'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        const Text(
                          'MY MODULES',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Upcoming Events List
                        Card(
                          elevation: 2,
                          shadowColor: Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                              child: const Icon(Icons.calendar_month, color: Colors.white),
                            ),
                            title: const Text('Upcoming Events:\nLive Workshop', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                            subtitle: const Text('Next Month'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.push('/events'),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Recent Progress List
                        assessmentsState.when(
                          data: (assessments) {
                            if (assessments.isEmpty) return const SizedBox.shrink();
                            final latest = assessments.first;
                            return Card(
                              elevation: 2,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(color: AppColors.primaryGold, shape: BoxShape.circle),
                                  child: const Icon(Icons.star, color: Colors.white),
                                ),
                                title: Text('Recent Progress:\n${latest.skillName.isNotEmpty ? latest.skillName : 'Skill'} - Level Up', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                                subtitle: Text(latest.assessmentDate.toLocal().toString().split(' ')[0]),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () => context.push('/progress'),
                              ),
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
            
            // The Welcome Card Overlapping the Header
            Positioned(
              top: 130, // Overlaps the bottom 60px of the header
              left: 16,
              right: 16,
              child: _buildWelcomeCard(context, username, feesState),
            ),

            // The Dancer Avatar Overlapping the Welcome Card (Right Aligned)
            Positioned(
              top: 70, // Peaks above the Welcome Card
              right: -20, // Bleeds off the right edge
              width: 180, // Sized perfectly
              child: Image.asset('assets/images/student_avatar.png'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String username, AsyncValue feesState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFAFD5D7), // Light teal matches mockup
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome $username!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
          ),
          const SizedBox(height: 4),
          const Text(
            'Here is your academy\noverview.',
            style: TextStyle(fontSize: 16, color: AppColors.deepNavy),
          ),
          const SizedBox(height: 16),
          
          // Fee Alert inside the Welcome Card
          feesState.when(
            data: (obligations) {
              final unpaid = obligations.where((o) => o.status == 'Unpaid').toList();
              if (unpaid.isEmpty) return const SizedBox.shrink();
              return Container(
                width: 220, // Keep it from going behind the dancer avatar too much
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8), // Soft red tint
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pan_tool_rounded, color: AppColors.error, size: 28), // Matches the stop hand icon
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('FEE Due', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 16)),
                          Text('You have ${unpaid.length} pending fee\nobligation(s). Tap to view.', style: const TextStyle(color: AppColors.error, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryGold, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
