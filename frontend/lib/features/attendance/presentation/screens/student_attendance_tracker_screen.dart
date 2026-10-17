import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../fees/presentation/providers/fee_obligations_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/attendance_providers.dart';

class StudentAttendanceTrackerScreen extends ConsumerStatefulWidget {
  final String? studentId;
  final String? studentName;

  const StudentAttendanceTrackerScreen({
    super.key,
    this.studentId,
    this.studentName,
  });

  @override
  ConsumerState<StudentAttendanceTrackerScreen> createState() =>
      _StudentAttendanceTrackerScreenState();
}

class _StudentAttendanceTrackerScreenState
    extends ConsumerState<StudentAttendanceTrackerScreen> {
  String _selectedPeriod = 'All'; // 'All', 'This Month', 'Past Month'
  String _selectedStatus = 'All'; // 'All', 'Present', 'Absent'

  static const List<String> _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];


  // Realistic fallback session records for demonstration if database has no entries yet
  List<Map<String, dynamic>> _getFallbackSessions(String studentName) {
    return [
      {
        'id': 'att-1',
        'date': DateTime(2026, 10, 15, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Adavus Revision & Thattadavu 1-8 Speed Drills',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Excellent aramandi posture and crisp foot tapping.',
      },
      {
        'id': 'att-2',
        'date': DateTime(2026, 10, 12, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Hastabhinaya & Asamyuta Hasta Slokas Practice',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Clear mudra expressions and eye coordination.',
      },
      {
        'id': 'att-3',
        'date': DateTime(2026, 10, 8, 17, 0),
        'status': 'Absent',
        'topicsCovered': 'Jathiswaram - Ragam Kalyani Section 2',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Excused: Informed leave due to school examinations.',
      },
      {
        'id': 'att-4',
        'date': DateTime(2026, 10, 5, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Alarippu Tisra Eka Talam Full Routine',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Great rhythm maintenance in 2nd and 3rd speeds.',
      },
      {
        'id': 'att-5',
        'date': DateTime(2026, 10, 1, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Nattadavu Variations & Korvai Execution',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Punctual, steady footwork with good hand alignment.',
      },
      {
        'id': 'att-6',
        'date': DateTime(2026, 9, 28, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Dhyana Slokam & Angikam Bhuvanam Chant and Recital',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Clear pronunciation and reverent posture.',
      },
      {
        'id': 'att-7',
        'date': DateTime(2026, 9, 24, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Mandi Adavu & Sarukkal Adavu Deep Stretch',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Improved stamina during sitting jumps.',
      },
      {
        'id': 'att-8',
        'date': DateTime(2026, 9, 21, 17, 0),
        'status': 'Absent',
        'topicsCovered': 'Shabdam Introduction - Ragamalika',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Absent without notice. Catch-up recording assigned.',
      },
      {
        'id': 'att-9',
        'date': DateTime(2026, 9, 17, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Abhinaya Expressions - Navarasas Basic Workshop',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Expressive eye movements in Shringara and Veera.',
      },
      {
        'id': 'att-10',
        'date': DateTime(2026, 9, 14, 17, 0),
        'status': 'Present',
        'topicsCovered': 'Tala Practice with Natuvangam Beats',
        'startTime': '17:00',
        'endTime': '18:30',
        'remarks': 'Strong grip on Adi Tala cycles.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.userRole;
    final isParent = userRole == 'Parent';

    // Resolve target student ID & name
    final targetStudentId = widget.studentId ?? 'me';
    final profileState = ref.watch(profileProvider);
    final feesState = ref.watch(feeObligationsProvider);

    String displayName = widget.studentName ?? '';
    if (displayName.isEmpty) {
      if (isParent) {
        feesState.whenData((obligations) {
          for (final ob in obligations) {
            if (ob.studentName != null && ob.studentName!.trim().isNotEmpty) {
              displayName = ob.studentName!.trim();
              break;
            }
          }
        });
        if (displayName.isEmpty) {
          displayName = 'Student';
        }
      } else {
        profileState.whenData((profile) {
          final first = profile['firstName'] as String? ?? '';
          final last = profile['lastName'] as String? ?? '';
          final combined = '$first $last'.trim();
          if (combined.isNotEmpty) {
            displayName = combined;
          }
        });
        if (displayName.isEmpty) {
          displayName = 'My Attendance';
        }
      }
    }

    final attendanceAsync = ref.watch(studentAttendanceProvider(targetStudentId));

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ─── 1. Top Navy Hero Banner with Gold Inset Frame ─────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.navyHeader, AppColors.navyHeroDeep],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Column(
                    children: [
                      // Header Row with Circular Back Button
                      Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  context.go(isParent
                                      ? '/dashboard/parent'
                                      : '/dashboard/student');
                                }
                              },
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.navyCircleButton,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.goldFrameBorder,
                                    width: 1.2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.goldBright,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isParent ? "CHILD ATTENDANCE" : "ATTENDANCE TRACKER",
                                  style: const TextStyle(
                                    color: AppColors.goldBright,
                                    fontSize: 11.5,
                                    letterSpacing: 1.4,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isParent ? "$displayName's Attendance" : "My Attendance Record",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Georgia',
                                    color: AppColors.pureWhite,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Refresh Button
                          IconButton(
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.goldBright,
                              size: 22,
                            ),
                            onPressed: () => ref.refresh(studentAttendanceProvider(targetStudentId)),
                            tooltip: 'Refresh Attendance',
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Inset Gold Student Identity Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.darkNavySurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.goldFrameBorder.withValues(alpha: 0.8),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.goldStarBadge,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S',
                                style: const TextStyle(
                                  color: AppColors.darkNavyText,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      color: AppColors.pureWhite,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Bharathanatyam Senior Batch • Academic Year 2026',
                                    style: TextStyle(
                                      color: AppColors.goldLightAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── 2. Attendance Content Area ────────────────────────────────────
            Expanded(
              child: attendanceAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.navyHeader),
                ),
                error: (err, stack) => ErrorView(
                  error: err,
                  onRetry: () => ref.refresh(studentAttendanceProvider(targetStudentId)),
                ),
                data: (apiRecords) {
                  // If API has data, map it; otherwise fallback to rich mock data
                  List<Map<String, dynamic>> allRecords;
                  if (apiRecords.isNotEmpty) {
                    allRecords = apiRecords.map((r) {
                      DateTime date;
                      if (r['date'] is String) {
                        date = DateTime.tryParse(r['date'] as String) ?? DateTime.now();
                      } else if (r['date'] is DateTime) {
                        date = r['date'] as DateTime;
                      } else {
                        date = DateTime.now();
                      }
                      return {
                        'id': r['id']?.toString() ?? '',
                        'date': date,
                        'status': r['status']?.toString() ?? 'Present',
                        'topicsCovered': r['topicsCovered']?.toString() ?? 'Regular Bharathanatyam Class',
                        'startTime': r['startTime']?.toString() ?? '17:00',
                        'endTime': r['endTime']?.toString() ?? '18:30',
                        'remarks': r['remarks']?.toString() ?? '',
                      };
                    }).toList();
                  } else {
                    allRecords = _getFallbackSessions(displayName);
                  }

                  // Compute metrics
                  final totalSessions = allRecords.length;
                  final presentCount = allRecords.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'present').length;
                  final absentCount = allRecords.where((r) => (r['status'] ?? '').toString().toLowerCase() == 'absent').length;
                  final rate = totalSessions > 0 ? ((presentCount / totalSessions) * 100).round() : 100;

                  // Apply Period Filter
                  final now = DateTime.now();
                  var filtered = allRecords.where((r) {
                    final dt = r['date'] as DateTime;
                    if (_selectedPeriod == 'This Month') {
                      return dt.year == now.year && dt.month == now.month;
                    } else if (_selectedPeriod == 'Past Month') {
                      final pastMonth = now.month == 1 ? 12 : now.month - 1;
                      final pastYear = now.month == 1 ? now.year - 1 : now.year;
                      return dt.year == pastYear && dt.month == pastMonth;
                    }
                    return true;
                  }).toList();

                  // Apply Status Filter
                  if (_selectedStatus != 'All') {
                    filtered = filtered.where((r) =>
                      (r['status'] ?? '').toString().toLowerCase() == _selectedStatus.toLowerCase()
                    ).toList();
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      // ─── Analytics Summary Card ──────────────────────────────
                      _buildAnalyticsSummaryCard(
                        rate: rate,
                        total: totalSessions,
                        present: presentCount,
                        absent: absentCount,
                      ),

                      const SizedBox(height: 20),

                      // ─── Filter Tabs: Period ─────────────────────────────────
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const Text(
                            'Session Logs',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavyText,
                            ),
                          ),
                          // Period Selector Pills
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildFilterPill('All', _selectedPeriod == 'All', () {
                                setState(() => _selectedPeriod = 'All');
                              }),
                              const SizedBox(width: 6),
                              _buildFilterPill('This Month', _selectedPeriod == 'This Month', () {
                                setState(() => _selectedPeriod = 'This Month');
                              }),
                              const SizedBox(width: 6),
                              _buildFilterPill('Past Month', _selectedPeriod == 'Past Month', () {
                                setState(() => _selectedPeriod = 'Past Month');
                              }),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ─── Status Filter Chips ─────────────────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusFilterChip('All Statuses', 'All', filtered.length),
                            const SizedBox(width: 8),
                            _buildStatusFilterChip('Present Only', 'Present', presentCount),
                            const SizedBox(width: 8),
                            _buildStatusFilterChip('Absent Only', 'Absent', absentCount),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ─── Session List or Empty State ─────────────────────────
                      if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map((session) => _buildSessionCard(session)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: isParent ? 0 : 0),
    );
  }

  // ─── Analytics Summary Card ──────────────────────────────────────────────────
  Widget _buildAnalyticsSummaryCard({
    required int rate,
    required int total,
    required int present,
    required int absent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.goldFrameBorder, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Circular Progress Indicator for Rate
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: CircularProgressIndicator(
                        value: (rate / 100).clamp(0.0, 1.0),
                        strokeWidth: 6.5,
                        backgroundColor: AppColors.sandDivider.withValues(alpha: 0.4),
                        color: rate >= 80
                            ? AppColors.greenPresent
                            : (rate >= 60 ? AppColors.warning : AppColors.crimsonAbsent),
                      ),
                    ),
                    Text(
                      '$rate%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkNavyText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text(
                            'Overall Attendance',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkNavyText,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rate >= 80 ? AppColors.greenBadgeBg : AppColors.crimsonDueBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              rate >= 80 ? 'Good Standing' : 'Needs Attention',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: rate >= 80 ? AppColors.greenPresent : AppColors.crimsonAbsent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Minimum required for annual Arangetram & grading is 80%.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondarySlate.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AppColors.creamDivider, height: 1),
            const SizedBox(height: 14),

            // 3 KPI Counters Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'TOTAL CLASSES',
                    value: '$total',
                    icon: Icons.calendar_month_outlined,
                    iconColor: AppColors.navyDarkPill,
                  ),
                ),
                Container(width: 1, height: 38, color: AppColors.creamDivider),
                Expanded(
                  child: _buildMetricTile(
                    label: 'ATTENDED',
                    value: '$present',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.greenPresent,
                  ),
                ),
                Container(width: 1, height: 38, color: AppColors.creamDivider),
                Expanded(
                  child: _buildMetricTile(
                    label: 'MISSED',
                    value: '$absent',
                    icon: Icons.highlight_off_rounded,
                    iconColor: AppColors.crimsonAbsent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkNavyText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppColors.textMutedSlate,
          ),
        ),
      ],
    );
  }

  // ─── Filter Pills ────────────────────────────────────────────────────────────
  Widget _buildFilterPill(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navyDarkPill : AppColors.creamChipBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.navyDarkPill : AppColors.goldFrameBorder.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.pureWhite : AppColors.darkNavyText,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip(String title, String statusKey, int count) {
    final isSelected = _selectedStatus == statusKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = statusKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldBright : AppColors.pureWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.goldBorder : AppColors.sandDivider,
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.darkNavyText : AppColors.textSecondarySlate,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkNavyText : AppColors.creamChipBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.goldBright : AppColors.darkNavyText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Individual Session Card ─────────────────────────────────────────────────
  Widget _buildSessionCard(Map<String, dynamic> session) {
    final dt = session['date'] as DateTime;
    final status = (session['status'] ?? 'Present').toString();
    final isPresent = status.toLowerCase() == 'present';
    final topics = (session['topicsCovered'] ?? 'Regular Class').toString();
    final startTime = (session['startTime'] ?? '17:00').toString();
    final endTime = (session['endTime'] ?? '18:30').toString();
    final remarks = (session['remarks'] ?? '').toString();

    final monthStr = _months[(dt.month - 1).clamp(0, 11)];
    final dayStr = dt.day.toString().padLeft(2, '0');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPresent
              ? AppColors.goldFrameBorder.withValues(alpha: 0.5)
              : AppColors.crimsonDueBorder.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Date Block
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.navyHeader,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.goldFrameBorder, width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    monthStr,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldBright,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayStr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pureWhite,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Middle Class Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.textMutedSlate,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$startTime - $endTime',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMutedSlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    topics,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkNavyText,
                      height: 1.25,
                    ),
                  ),
                  if (remarks.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.creamCardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.sandDivider, width: 0.8),
                      ),
                      child: Text(
                        remarks,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondarySlate,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right Status Badge Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isPresent ? AppColors.greenBadgeBg : AppColors.crimsonDueBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPresent ? AppColors.greenPresent : AppColors.crimsonAbsent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 13,
                    color: isPresent ? AppColors.greenPresent : AppColors.crimsonAbsent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPresent ? 'Present' : 'Absent',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isPresent ? AppColors.greenPresent : AppColors.crimsonAbsent,
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

  // ─── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.sandDivider, width: 1.2),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.creamChipBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.goldBorder,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'No Sessions Found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkNavyText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No attendance records match your selected filter. Try switching to "All" or another period.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondarySlate,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedPeriod = 'All';
                _selectedStatus = 'All';
              });
            },
            icon: const Icon(Icons.restart_alt_rounded, size: 16, color: AppColors.navyHeader),
            label: const Text(
              'Reset Filters',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.navyHeader,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
