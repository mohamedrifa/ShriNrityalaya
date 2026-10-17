import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../events/presentation/providers/event_providers.dart';
import '../../../fees/presentation/providers/fee_obligations_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../progress/domain/models/skill_assessment.dart';
import '../../../progress/presentation/providers/progress_providers.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  static const Color _navyHeader = AppColors.navyHeroDeep;
  static const Color _darkNavyText = AppColors.navyHeader;
  static const Color _goldPrimary = AppColors.goldBrightAccent;
  static const Color _goldSoft = AppColors.goldTitle;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[(dt.month - 1).clamp(0, 11)];
    final d = dt.day.toString().padLeft(2, '0');
    return '$m $d, ${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsState = ref.watch(studentAssessmentsProvider('me'));
    final feesState = ref.watch(feeObligationsProvider);
    final eventsState = ref.watch(eventsProvider);
    final profileState = ref.watch(profileProvider);
    final baseUrl =
        ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String username = 'Student';
    String? imageUrl;
    profileState.whenData((profile) {
      username = profile['firstName'] ?? profile['userName'] ?? 'Student';
      if (username.isEmpty) username = 'Student';
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    final Widget profileAvatar = Container(
      width: 42,
      height: 42,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _goldPrimary, width: 1.8),
      ),
      child: CircleAvatar(
        backgroundColor: _goldPrimary.withValues(alpha: 0.25),
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage('$baseUrl$imageUrl')
            : null,
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Icon(Icons.person, color: _goldSoft, size: 22)
            : null,
      ),
    );

    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return AppScaffold(
      scaffoldKey: scaffoldKey,
      drawer: AppDrawer(
        roleSubtitle: 'Student Dashboard',
        menuItems: [
          DrawerMenuItem(
            title: 'Fee Management',
            icon: Icons.receipt_long,
            route: '/fees',
          ),
          DrawerMenuItem(
            title: 'Learning & Lessons',
            icon: Icons.video_library,
            route: '/learning',
          ),
          DrawerMenuItem(
            title: 'My Progress',
            icon: Icons.trending_up,
            route: '/progress',
          ),
          DrawerMenuItem(
            title: 'Announcements',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Stack(
          children: [
            // 1. Deep Navy Curved Header Backdrop
            Container(
              height: 228,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _navyHeader,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
      
            // 2. Foreground Content Column
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
      
                    // Top AppBar Row: Gold Menu Button + Brand + Bell & Avatar
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              scaffoldKey.currentState?.openDrawer(),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _goldPrimary,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.menu_rounded,
                              color: _darkNavyText,
                              size: 24,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 24),
                            child: Text(
                              'BHARATANATYAM\nACADEMY',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.creamWarmLightF3e6c6,
                                fontSize: 12.5,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/messaging'),
                              behavior: HitTestBehavior.opaque,
                              child: const Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.notifications_rounded,
                                  color: _goldPrimary,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: profileAvatar,
                            ),
                          ],
                        ),
                      ],
                    ),
      
                    const SizedBox(height: 12),
      
                    // Centered "Dashboard" Serif Heading
                    const Center(
                      child: Text(
                        'Dashboard',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: _goldSoft,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 18),
      
                    // Overlapping Welcome Card + Right Dancer Illustration
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildWelcomeCard(context, username, feesState),
                        Positioned(
                          top: -36,
                          right: -12,
                          width: 158,
                          child: IgnorePointer(
                            child: Image.asset(
                              'assets/images/student_avatar.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
      
                    const SizedBox(height: 22),
      
                    // Quick Actions Section
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondarySlate,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            context: context,
                            title: 'Lessons',
                            subtitle: 'View lessons',
                            icon: Icons.book_outlined,
                            route: '/learning',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionCard(
                            context: context,
                            title: 'Attendance',
                            subtitle: 'Track presence',
                            icon: Icons.fact_check_outlined,
                            route: '/attendance/student',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildQuickActionCard(
                            context: context,
                            title: 'Events',
                            subtitle: 'Explore events',
                            icon: Icons.calendar_today_outlined,
                            route: '/events',
                          ),
                        ),
                      ],
                    ),
      
                    const SizedBox(height: 24),
      
                    // MY MODULES SECTION
                    const Text(
                      'MY MODULES',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: _darkNavyText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Recent Activity & Presence',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondarySlate,
                      ),
                    ),
                    const SizedBox(height: 12),
      
                    // 1. Attendance Tracker Card
                    _buildAttendanceSummaryCard(context),

                    const SizedBox(height: 12),

                    // 2. Upcoming Events Card
                    _buildUpcomingEventCard(context, eventsState),
      
                    const SizedBox(height: 12),
      
                    // 3. Recent Progress Card
                    _buildRecentProgressCard(context, assessmentsState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildWelcomeCard(
    BuildContext context,
    String username,
    AsyncValue feesState,
  ) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: _goldSoft,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome $username!',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: _darkNavyText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Here is your academy\noverview.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.navySlate1a2b49,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Fee Due Alert Banner inside Welcome Card — ONLY shown when pending/unpaid fees exist
          feesState.when(
            data: (obligations) {
              final unpaid = obligations
                  .where((o) => (o.status ?? 'Unpaid') == 'Unpaid')
                  .toList();
              if (unpaid.isEmpty) return const SizedBox.shrink();

              final unpaidCount = unpaid.length;
              return Padding(
                padding: const EdgeInsets.only(top: 14),
                child: GestureDetector(
                  onTap: () => context.push('/fees'),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 28),
                    padding: const EdgeInsets.fromLTRB(12, 10, 56, 10),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonDueBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.crimsonDueBorder,
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.crimsonBadgeBorder,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.pan_tool_outlined,
                            color: AppColors.crimsonDeep8e1b1b,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12.2,
                                color: AppColors.grayDark2b1818,
                                height: 1.32,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'FEE Due',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.crimsonDarkText,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' — You have $unpaidCount\npending fee obligation${unpaidCount == 1 ? '' : 's'}. Tap\nto view. ',
                                ),
                                const WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Icon(
                                    Icons.warning_amber_rounded,
                                    size: 15,
                                    color: AppColors.crimsonAlertD9534f,
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
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.goldStarBadge,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: _darkNavyText, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _darkNavyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accentTone8c7a5b,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEventCard(BuildContext context, AsyncValue eventsState) {
    String eventTitle = 'Live Workshop';
    String eventSubtitle = 'Next Month, Jan 25';

    eventsState.whenData((events) {
      if (events.isNotEmpty) {
        final first = events.first;
        eventTitle = first.title;
        eventSubtitle = _formatDate(first.eventDate);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamWarmLightFaf6ec,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navySlate14223d, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/events'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenEmerald4d9460,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upcoming Events:',
                        style: TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        eventTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: _darkNavyText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eventSubtitle,
                        style: const TextStyle(
                          fontSize: 12.2,
                          color: AppColors.textMutedSlate,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'REGISTER',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _darkNavyText,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: _darkNavyText,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentProgressCard(
    BuildContext context,
    AsyncValue<List<SkillAssessment>> assessmentsState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamWarmLightFaf4e4,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldPrimary, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/progress'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: assessmentsState.when(
              loading: () => const SizedBox(
                height: 58,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: _goldPrimary,
                    ),
                  ),
                ),
              ),
              error: (_, _) => Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldStarBadge,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.star_border_rounded,
                      color: _darkNavyText,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Progress:',
                          style: TextStyle(
                            fontSize: 12.8,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDarkSlate,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'No milestones recorded yet.',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMutedSlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'VIEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _darkNavyText,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              data: (assessments) {
                if (assessments.isEmpty) {
                  return Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldStarBadge,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.star_border_rounded,
                          color: _darkNavyText,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent Progress:',
                              style: TextStyle(
                                fontSize: 12.8,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDarkSlate,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'No milestones recorded yet.',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMutedSlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'VIEW',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _darkNavyText,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  );
                }

                final latest = assessments.first;
                final sName = latest.skillName.trim();
                final sType = latest.skillType.trim();
                final level = latest.skillLevel.trim();
                String skillTitle;
                if (sName.isNotEmpty &&
                    !sName.toLowerCase().contains(sType.toLowerCase())) {
                  skillTitle =
                      '$sType - $sName${level.isNotEmpty ? ' ($level)' : ''}';
                } else if (sName.isNotEmpty) {
                  skillTitle = '$sName${level.isNotEmpty ? ' ($level)' : ''}';
                } else {
                  skillTitle = '$sType${level.isNotEmpty ? ' ($level)' : ''}';
                }
                final dateText =
                    'Assessed on ${_formatDate(latest.assessmentDate)}';
                final score = latest.score;

                return Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.goldStarBadge,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.star_border_rounded,
                        color: _darkNavyText,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Progress:',
                            style: TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            skillTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: _darkNavyText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateText,
                            style: const TextStyle(
                              fontSize: 12.2,
                              color: AppColors.textMutedSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: CustomPaint(
                            painter: _StudentScoreRingPainter(
                              progress: (score.clamp(0, 100)) / 100.0,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$score',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: _darkNavyText,
                                      height: 1.0,
                                    ),
                                  ),
                                  const Text(
                                    '100',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textNeutralGray,
                                      height: 1.05,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'VIEW',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _darkNavyText,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSummaryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _goldPrimary, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/attendance/student'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenBadgeBg,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.fact_check_rounded,
                    color: AppColors.greenPresent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Attendance:',
                        style: TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Track attendance & session logs',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: _darkNavyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.navyDarkPill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Track',
                    style: TextStyle(
                      color: AppColors.goldBright,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentScoreRingPainter extends CustomPainter {
  final double progress;
  _StudentScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2.5;

    final trackPaint = Paint()
      ..color = AppColors.creamWarmLightE9dfc4
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = AppColors.goldBrightAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StudentScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
