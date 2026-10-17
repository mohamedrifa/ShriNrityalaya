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
    final baseUrl =
        ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String username = 'Teacher';
    String? imageUrl;
    profileState.whenData((profile) {
      username = profile['firstName'] ?? profile['userName'] ?? 'Teacher';
      if (username.isEmpty) username = 'Teacher';
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    final Widget profileAvatar = Container(
      padding: const EdgeInsets.all(2.2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AcharyaColors.screenBackground,
        border: Border.all(color: AcharyaColors.navy, width: 2.2),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AcharyaColors.navy, width: 1.6),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AcharyaColors.pageBackground,
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage('$baseUrl$imageUrl')
              : null,
          child: imageUrl == null || imageUrl!.isEmpty
              ? const Icon(Icons.person, color: AppColors.primaryNavy, size: 20)
              : null,
        ),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      drawer: AppDrawer(
        roleSubtitle: 'Teacher Dashboard',
        menuItems: [
          DrawerMenuItem(
            title: 'Fee Management',
            icon: Icons.emoji_events_outlined,
            route: '/fees',
          ),
          DrawerMenuItem(
            title: 'Manage Students',
            icon: Icons.people_alt_outlined,
            route: '/students',
          ),
          DrawerMenuItem(
            title: 'Directory',
            icon: Icons.contact_phone_outlined,
            route: '/directory',
          ),
          DrawerMenuItem(
            title: 'Learning & Lessons',
            icon: Icons.play_circle_outline,
            route: '/learning',
          ),
          DrawerMenuItem(
            title: 'Student Progress',
            icon: Icons.auto_graph_outlined,
            route: '/progress',
          ),
          DrawerMenuItem(
            title: 'Messages',
            icon: Icons.campaign_outlined,
            route: '/messaging',
          ),
          DrawerMenuItem(
            title: 'Academy Events',
            icon: Icons.calendar_today_outlined,
            route: '/events',
          ),
        ],
      ),
      backgroundColor: AcharyaColors.screenBackground,
      body: Stack(
        children: [
          // Temple Background
          Positioned.fill(
            top: 150,
            bottom: 80,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/temple_bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Temple background image error: $error');
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // Phone surface
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: const BoxDecoration(
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
                      padding: const EdgeInsets.only(bottom: 92),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AcharyaHeroBanner(username: username),

                          // Academy Modules Section Header
                          const Padding(
                            padding: EdgeInsets.fromLTRB(18, 14, 18, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Academy Modules',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navyHeader,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Manage your academy from here.',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.navySlate1b2b45,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Academy Modules 2x3 Horizontal Cards Grid
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 1.82,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildModuleCard(
                                  context: context,
                                  title: 'Students',
                                  icon: Icons.people_alt_rounded,
                                  route: '/students',
                                  showBottomLeftLotus: true,
                                ),
                                _buildModuleCard(
                                  context: context,
                                  title: 'Directory',
                                  icon: Icons.call_rounded,
                                  route: '/directory',
                                  showBottomLeftLotus: false,
                                ),
                                _buildModuleCard(
                                  context: context,
                                  title: 'Attendance',
                                  icon: Icons.event_available_rounded,
                                  route: '/attendance',
                                  showBottomLeftLotus: false,
                                ),
                                _buildModuleCard(
                                  context: context,
                                  title: 'Fees',
                                  icon: Icons.credit_card_rounded,
                                  route: '/fees',
                                  showBottomLeftLotus: false,
                                ),
                                _buildModuleCard(
                                  context: context,
                                  title: 'Lessons',
                                  icon: Icons.play_circle_fill_rounded,
                                  route: '/learning',
                                  showBottomLeftLotus: true,
                                ),
                                _buildModuleCard(
                                  context: context,
                                  title: 'Progress',
                                  icon: Icons.assessment_rounded,
                                  route: '/progress',
                                  showBottomLeftLotus: true,
                                ),
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
            bottom: 0,
            left: 0,
            right: 0,
            child: AppBottomNav(currentIndex: 0),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String route,
    required bool showBottomLeftLotus,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyHeader.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Top-Right Line-Art Gold Lotus Ornament
              const Positioned(
                top: 6,
                right: 8,
                child: _ModuleLotusOrnament(size: 42),
              ),

              // Bottom-Left Line-Art Gold Lotus Ornament
              if (showBottomLeftLotus)
                const Positioned(
                  bottom: -2,
                  left: -4,
                  child: _ModuleLotusOrnament(size: 38),
                ),

              // Horizontal Content: Pale Gold Circle Icon + Bold Navy Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.creamWarmLightFdf2db,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          color: AppColors.crimsonAlertCda756,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyHeader,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Delicate gold line-art lotus blossom for the Academy Module cards.
class _ModuleLotusOrnament extends StatelessWidget {
  final double size;
  const _ModuleLotusOrnament({required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(size, size * 0.72),
        painter: _ModuleLotusPainter(),
      ),
    );
  }
}

class _ModuleLotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldLightShadeD6b872.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width * 0.5;
    final cy = size.height * 0.86;

    // Center upright petal
    final centerPetal = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.16,
        cy - size.height * 0.46,
        cx,
        cy - size.height * 0.76,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.16,
        cy - size.height * 0.46,
        cx,
        cy,
      );
    canvas.drawPath(centerPetal, paint);

    // Left inner petal
    final leftInner = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.30,
        cy - size.height * 0.42,
        cx - size.width * 0.25,
        cy - size.height * 0.62,
      )
      ..quadraticBezierTo(
        cx - size.width * 0.08,
        cy - size.height * 0.46,
        cx,
        cy,
      );
    canvas.drawPath(leftInner, paint);

    // Right inner petal
    final rightInner = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx + size.width * 0.30,
        cy - size.height * 0.42,
        cx + size.width * 0.25,
        cy - size.height * 0.62,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.08,
        cy - size.height * 0.46,
        cx,
        cy,
      );
    canvas.drawPath(rightInner, paint);

    // Left outer petal
    final leftOuter = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.44,
        cy - size.height * 0.20,
        cx - size.width * 0.44,
        cy - size.height * 0.38,
      )
      ..quadraticBezierTo(
        cx - size.width * 0.22,
        cy - size.height * 0.34,
        cx,
        cy,
      );
    canvas.drawPath(leftOuter, paint);

    // Right outer petal
    final rightOuter = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx + size.width * 0.44,
        cy - size.height * 0.20,
        cx + size.width * 0.44,
        cy - size.height * 0.38,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.22,
        cy - size.height * 0.34,
        cx,
        cy,
      );
    canvas.drawPath(rightOuter, paint);

    // Base petals
    final leftBase = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.32,
        cy + size.height * 0.04,
        cx - size.width * 0.46,
        cy - size.height * 0.08,
      )
      ..quadraticBezierTo(
        cx - size.width * 0.26,
        cy - size.height * 0.14,
        cx,
        cy,
      );
    canvas.drawPath(leftBase, paint);

    final rightBase = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
        cx + size.width * 0.32,
        cy + size.height * 0.04,
        cx + size.width * 0.46,
        cy - size.height * 0.08,
      )
      ..quadraticBezierTo(
        cx + size.width * 0.26,
        cy - size.height * 0.14,
        cx,
        cy,
      );
    canvas.drawPath(rightBase, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
