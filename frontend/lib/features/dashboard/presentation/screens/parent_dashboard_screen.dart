import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
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

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  static const Color _navyHeader = AppColors.navyHeroDeep;
  static const Color _darkNavyText = AppColors.navyHeader;
  static const Color _goldPrimary = AppColors.goldBrightAccent;
  static const Color _goldSoft = AppColors.goldTitle;
  static const Color _goldLink = AppColors.goldLinkText;

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
    final feesState = ref.watch(feeObligationsProvider);
    final eventsState = ref.watch(eventsProvider);
    final profileState = ref.watch(profileProvider);
    final baseUrl =
        ref.read(dioProvider).options.baseUrl.replaceAll('/api/v1', '');

    String username = 'Parent';
    String? imageUrl;
    profileState.whenData((profile) {
      username = profile['firstName'] ?? profile['userName'] ?? 'Parent';
      if (username.isEmpty) username = 'Parent';
      imageUrl = profile['profilePictureUrl'] as String?;
    });

    String? childName;
    String? childStudentId;
    feesState.whenData((obligations) {
      for (final ob in obligations) {
        if (ob.studentName != null && ob.studentName!.trim().isNotEmpty) {
          childName = ob.studentName!.trim();
          childStudentId = ob.studentId;
          break;
        }
      }
    });

    final assessmentsState = ref.watch(
      studentAssessmentsProvider(childStudentId ?? 'me'),
    );

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
        roleSubtitle: 'Parent Dashboard',
        menuItems: [
          DrawerMenuItem(
            title: 'Fee Management',
            icon: Icons.receipt_long,
            route: '/fees',
          ),
          DrawerMenuItem(
            title: 'Student Progress',
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
      
                    // Centered "Parent Dashboard" Serif Heading
                    const Center(
                      child: Text(
                        'Parent Dashboard',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: _goldSoft,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 18),
      
                    // Overlapping Welcome Card + Right Parents Illustration
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildWelcomeCard(context, username, feesState),
                        Positioned(
                          right: -6,
                          bottom: -40,
                          width: 170,
                          child: IgnorePointer(
                            child: Image.asset(
                              'assets/images/parent_avatar.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomRight,
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                      ],
                    ),
      
                    const SizedBox(height: 24),
      
                    // Attendance Tracking Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Attendance Tracking',
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w800,
                            color: _darkNavyText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(
                            '/attendance/student',
                            extra: {
                              'studentId': childStudentId ?? 'me',
                              'studentName': childName ?? 'Student',
                            },
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'View Logs',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _goldLink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildChildAttendanceCard(
                      context,
                      childName,
                      childStudentId,
                    ),

                    const SizedBox(height: 24),
      
                    // Recent Progress Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Progress',
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w800,
                            color: _darkNavyText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/progress'),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'View Report',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _goldLink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRecentProgressCard(
                      context,
                      assessmentsState,
                      childName,
                    ),
      
                    const SizedBox(height: 24),
      
                    // Upcoming Events Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w800,
                            color: _darkNavyText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/events'),
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _goldLink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildUpcomingEventsCard(context, eventsState),
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
      constraints: const BoxConstraints(minHeight: 148),
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
            padding: const EdgeInsets.only(right: 136),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome\n$username!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _darkNavyText,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Stay updated with your\nchild\'s progress.',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.navySlate1a2b49,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Conditional Fee Due Banner — ONLY shown when pending/unpaid fees exist
          feesState.when(
            data: (obligations) {
              final unpaid = obligations
                  .where((o) => (o.status ?? 'Unpaid') == 'Unpaid')
                  .toList();
              if (unpaid.isEmpty) return const SizedBox.shrink();

              final unpaidCount = unpaid.length;
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: GestureDetector(
                  onTap: () => context.push('/fees'),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(right: 118),
                    padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                    decoration: BoxDecoration(
                      color: AppColors.crimsonDueBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.crimsonDueBorder,
                        width: 1.1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.crimsonBadgeBorder,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.pan_tool_outlined,
                            color: AppColors.crimsonDeep8e1b1b,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.grayDark2b1818,
                                height: 1.28,
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
                                      ' — You have $unpaidCount\npending fee obligation${unpaidCount == 1 ? '' : 's'}.\nTap to view.',
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

  Widget _buildRecentProgressCard(
    BuildContext context,
    AsyncValue<List<SkillAssessment>> assessmentsState,
    String? childName,
  ) {
    final String displayStudent = childName ?? 'Student Progress';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navySlate14223d, width: 1.4),
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
          onTap: () => context.push('/progress'),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: assessmentsState.when(
              loading: () => const SizedBox(
                height: 64,
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
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.goldStarBadge,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.star_border_rounded,
                      color: _darkNavyText,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayStudent,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: _darkNavyText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'No milestones recorded yet.',
                          style: TextStyle(
                            fontSize: 12.8,
                            color: AppColors.textSecondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _goldLink,
                    size: 22,
                  ),
                ],
              ),
              data: (assessments) {
                if (assessments.isEmpty) {
                  return Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.goldStarBadge,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.star_border_rounded,
                          color: _darkNavyText,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayStudent,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: _darkNavyText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'No milestones recorded yet.',
                              style: TextStyle(
                                fontSize: 12.8,
                                color: AppColors.textSecondarySlate,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: _goldLink,
                        size: 22,
                      ),
                    ],
                  );
                }

                final latest = assessments.first;
                final sName = latest.skillName.trim();
                final sType = latest.skillType.trim();
                final level = latest.skillLevel.trim();
                String skillLine;
                if (sName.isNotEmpty &&
                    !sName.toLowerCase().contains(sType.toLowerCase())) {
                  skillLine =
                      '$sType - $sName${level.isNotEmpty ? ' ($level)' : ''}';
                } else if (sName.isNotEmpty) {
                  skillLine = '$sName${level.isNotEmpty ? ' ($level)' : ''}';
                } else {
                  skillLine = '$sType${level.isNotEmpty ? ' ($level)' : ''}';
                }
                final dateLine =
                    'Assessed on ${_formatDate(latest.assessmentDate)}';
                final score = latest.score;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left Gold Circle with Outlined Star
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.goldStarBadge,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.star_border_rounded,
                        color: _darkNavyText,
                        size: 27,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Center Details: Student Name, Skill, Progress Bar + Score Pill, Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayStudent,
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
                            skillLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDarkSlate,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (score.clamp(0, 100)) / 100.0,
                                    minHeight: 6,
                                    backgroundColor: AppColors.creamWarmLightE2e8f0,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.greenEmerald3e8e5a,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.greenEmerald238854,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Score: $score/100',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateLine,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _goldLink,
                      size: 22,
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

  Widget _buildUpcomingEventsCard(
    BuildContext context,
    AsyncValue eventsState,
  ) {
    String eventTitle = 'Live Workshop';
    String eventSubtitle = 'Annual Arangetram Showcase';
    String eventNote = "Next Month - Don't forget to register!";

    eventsState.whenData((events) {
      if (events.isNotEmpty) {
        final first = events.first;
        eventTitle = first.title;
        if (first.location.trim().isNotEmpty) {
          eventSubtitle = first.location.trim();
        }
        eventNote =
            "${_formatDate(first.eventDate)} - Don't forget to register!";
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamWarmLightFaf7ee,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _goldPrimary, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _navyHeader.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/events'),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Green Circle with Calendar Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenEmerald4d9460,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Center Event Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.8,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDarkSlate,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        eventNote,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondarySlate,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: _goldLink,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChildAttendanceCard(
    BuildContext context,
    String? childName,
    String? childStudentId,
  ) {
    final String displayChild = childName ?? 'Child';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldFrameBorder, width: 1.4),
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
          onTap: () => context.push(
            '/attendance/student',
            extra: {
              'studentId': childStudentId ?? 'me',
              'studentName': displayChild,
            },
          ),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenBadgeBg,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.how_to_reg_rounded,
                    color: AppColors.greenPresent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$displayChild's Attendance Record",
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: _darkNavyText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Monitor class presence, dates & topics',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondarySlate,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.navyDarkPill,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Track',
                    style: TextStyle(
                      color: AppColors.goldBright,
                      fontSize: 11.5,
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
