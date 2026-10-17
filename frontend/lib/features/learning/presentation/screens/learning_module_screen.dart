import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../core/utils/app_error_handler.dart';
import 'dart:math' as math;
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart'
    as shri_nrityalaya_app_dio;
import '../../../auth/presentation/providers/auth_providers.dart'
    as shri_nrityalaya_app_auth;
import '../providers/lesson_providers.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class LearningModuleScreen extends ConsumerStatefulWidget {
  const LearningModuleScreen({super.key});

  @override
  ConsumerState<LearningModuleScreen> createState() =>
      _LearningModuleScreenState();
}

class _LearningModuleScreenState extends ConsumerState<LearningModuleScreen> {
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _goldBright = AppColors.goldBright;
  static const Color _goldPrimary = AppColors.goldBorder;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _cardBorderNavy = AppColors.navyCardBorder;
  static const Color _mutedSubtext = AppColors.textMutedSlate;
  static const Color _dividerSoft = AppColors.creamDivider;

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _durationBadgeForLesson(int orderSequence, int index) {
    // Provides a consistent MM:SS display in the thumbnail corner
    final presets = ['15:42', '22:15', '18:30', '12:45', '24:10', '19:05'];
    final seq = orderSequence > 0 ? orderSequence - 1 : index;
    return presets[seq % presets.length];
  }

  @override
  Widget build(BuildContext context) {
    final lessonsState = ref.watch(lessonsProvider);
    final userRole = ref.watch(shri_nrityalaya_app_auth.authProvider).userRole;
    final isTeacherOrAdmin =
        userRole == 'Teacher' || userRole == 'SystemAdmin';

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: _navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: _goldBright,
                decoration: InputDecoration(
                  hintText: 'Search lessons...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : const Text(
                'Learning & Lessons',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _goldBright,
                  letterSpacing: 0.3,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: lessonsState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _navyHeader),
        ),
        error: (err, stack) => ErrorView(
          error: err,
          onRetry: () => ref.refresh(lessonsProvider),
        ),
        data: (lessons) {
          final filteredLessons = lessons.where((lesson) {
            if (_searchQuery.trim().isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            final titleMatch = lesson.title.toLowerCase().contains(q);
            final descMatch =
                (lesson.description ?? '').toLowerCase().contains(q);
            return titleMatch || descMatch;
          }).toList();

          if (filteredLessons.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.ondemand_video_outlined,
                    size: 52,
                    color: _navyHeader.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No lessons match your search.'
                        : 'No lessons available.',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _mutedSubtext,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: filteredLessons.length,
            itemBuilder: (context, index) {
              final lesson = filteredLessons[index];
              final durationText =
                  _durationBadgeForLesson(lesson.orderSequence, index);

              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _cardBorderNavy, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyHeader.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Thumbnail Banner
                    GestureDetector(
                      onTap: () {
                        if (lesson.videoUrl != null) {
                          context.push('/learning/play', extra: lesson);
                        }
                      },
                      child: Container(
                        height: 182,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.88,
                            colors: [
                              AppColors.navyRoyal1f3868,
                              AppColors.navySlate112244,
                              AppColors.navyMidnight0a1428,
                            ],
                            stops: [0.0, 0.62, 1.0],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Top-Right Decorative Gold Lotus Accent
                            const Positioned(
                              top: 10,
                              right: 12,
                              child: _LotusCornerOrnament(size: 46),
                            ),
                            // Bottom-Left Decorative Gold Lotus Accent
                            const Positioned(
                              bottom: 10,
                              left: 12,
                              child: _LotusCornerOrnament(size: 46),
                            ),
                            // Center Glowing Gold "Play" Circle Button
                            Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.navyHeader
                                      .withValues(alpha: 0.85),
                                  border: Border.all(
                                    color: _goldBright,
                                    width: 2.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _goldBright.withValues(alpha: 0.45),
                                      blurRadius: 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Play',
                                  style: TextStyle(
                                    color: _goldBright,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-Right Duration Pill
                            Positioned(
                              bottom: 10,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.navyMidnight060c18
                                      .withValues(alpha: 0.82),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  durationText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Card Content Body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (lesson.videoUrl != null) {
                                context.push('/learning/play', extra: lesson);
                              }
                            },
                            child: Text(
                              lesson.title,
                              style: const TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _darkNavyText,
                                height: 1.25,
                              ),
                            ),
                          ),
                          if (lesson.description != null &&
                              lesson.description!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              lesson.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: _mutedSubtext,
                                height: 1.4,
                              ),
                            ),
                          ],
                          if (isTeacherOrAdmin) ...[
                            const SizedBox(height: 13),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _dividerSoft,
                            ),
                            const SizedBox(height: 13),
                            Row(
                              children: [
                                // Left: Edit Lesson Pill Button
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            _EditLessonSheet(lesson: lesson),
                                      );
                                    },
                                    child: Container(
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: AppColors.creamWarmLightFdfbf7,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: _darkNavyText,
                                          width: 1.3,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 16,
                                            color: _darkNavyText,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Edit Lesson',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _darkNavyText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                // Right: Watch Analytics Pill Button
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {
                                      if (lesson.id != null) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) =>
                                              _LessonProgressSheet(
                                            lessonId: lesson.id!,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: _navyHeader,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: _goldPrimary,
                                          width: 1.3,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.trending_up,
                                            size: 16,
                                            color: _goldBright,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Watch Analytics',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: _goldBright,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isTeacherOrAdmin
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: _darkNavyText, width: 1.3),
                boxShadow: [
                  BoxShadow(
                    color: _navyHeader.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/learning/upload'),
                backgroundColor: _goldPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                icon: const Icon(
                  Icons.upload_rounded,
                  color: _darkNavyText,
                  size: 20,
                ),
                label: const Text(
                  'Upload Lesson',
                  style: TextStyle(
                    color: _darkNavyText,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

/// Decorative gold line-art lotus ornament for video thumbnail corners.
class _LotusCornerOrnament extends StatelessWidget {
  final double size;
  const _LotusCornerOrnament({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.72),
      painter: _LotusPainter(),
    );
  }
}

class _LotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.goldBorder.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.5;
    final cy = size.height * 0.78;

    // Center upright lotus petal
    final centerPetal = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(
          cx - size.width * 0.16, cy - size.height * 0.45, cx, cy - size.height * 0.68)
      ..quadraticBezierTo(
          cx + size.width * 0.16, cy - size.height * 0.45, cx, cy);
    canvas.drawPath(centerPetal, paint);

    // Left inner petal
    final leftPetal = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx - size.width * 0.28, cy - size.height * 0.42,
          cx - size.width * 0.24, cy - size.height * 0.56)
      ..quadraticBezierTo(
          cx - size.width * 0.08, cy - size.height * 0.44, cx, cy);
    canvas.drawPath(leftPetal, paint);

    // Right inner petal
    final rightPetal = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx + size.width * 0.28, cy - size.height * 0.42,
          cx + size.width * 0.24, cy - size.height * 0.56)
      ..quadraticBezierTo(
          cx + size.width * 0.08, cy - size.height * 0.44, cx, cy);
    canvas.drawPath(rightPetal, paint);

    // Left outer petal
    final leftOuter = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx - size.width * 0.40, cy - size.height * 0.22,
          cx - size.width * 0.42, cy - size.height * 0.34)
      ..quadraticBezierTo(
          cx - size.width * 0.22, cy - size.height * 0.32, cx, cy);
    canvas.drawPath(leftOuter, paint);

    // Right outer petal
    final rightOuter = Path()
      ..moveTo(cx, cy)
      ..quadraticBezierTo(cx + size.width * 0.40, cy - size.height * 0.22,
          cx + size.width * 0.42, cy - size.height * 0.34)
      ..quadraticBezierTo(
          cx + size.width * 0.22, cy - size.height * 0.32, cx, cy);
    canvas.drawPath(rightOuter, paint);

    // Base flourish curve
    final baseCurve = Path()
      ..moveTo(cx - size.width * 0.32, cy + 2)
      ..quadraticBezierTo(cx, cy + 5, cx + size.width * 0.32, cy + 2);
    canvas.drawPath(baseCurve, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LessonProgressSheet extends ConsumerStatefulWidget {
  final String lessonId;
  const _LessonProgressSheet({required this.lessonId});

  @override
  ConsumerState<_LessonProgressSheet> createState() =>
      _LessonProgressSheetState();
}

class _LessonProgressSheetState extends ConsumerState<_LessonProgressSheet> {
  static const Color _sheetCream = AppColors.creamModalSheet;
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _goldPrimary = AppColors.goldBadgeBorder;
  static const Color _goldBright = AppColors.goldBright;

  List<dynamic> _progress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final dio = ref.read(shri_nrityalaya_app_dio.dioProvider);
      final response = await dio.get('/lessons/${widget.lessonId}/progress');
      if (response.statusCode == 200) {
        setState(() {
          _progress = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'ST';
    if (parts.length == 1) {
      final s = parts.first;
      return s.substring(0, math.min(2, s.length)).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '0:00';
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: _sheetCream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: _goldPrimary.withValues(alpha: 0.6), width: 1.2),
      ),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Drag Handle
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: _goldPrimary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          // Sheet Header Row: Thumbnail + "Student Watch Progress" + Chart Icon
          Row(
            children: [
              // Mini Video Thumbnail Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _navyHeader,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _goldPrimary, width: 1.3),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _goldBright, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _goldBright.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 15,
                    color: _goldBright,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Student Watch\nProgress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _darkNavyText,
                    height: 1.2,
                  ),
                ),
              ),
              // Analytics Bar Chart Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _goldPrimary.withValues(alpha: 0.45),
                  ),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 26,
                  color: _darkNavyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Student Progress Cards List
          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: _navyHeader),
                    ),
                  )
                : _progress.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              size: 44,
                              color: _navyHeader.withValues(alpha: 0.35),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No students have watched this yet.',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textNeutralGray,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _progress.length,
                        itemBuilder: (context, index) {
                          final p = _progress[index];
                          final studentName =
                              (p['studentName'] ?? 'Unknown').toString();
                          final isCompleted = p['isFullyWatched'] == true;
                          final seconds = (p['watchDurationSeconds'] is int)
                              ? p['watchDurationSeconds'] as int
                              : int.tryParse(
                                      '${p['watchDurationSeconds'] ?? 0}') ??
                                  0;
                          final isInProgress = !isCompleted && seconds > 0;

                          // Estimate percentage when in progress
                          final int pct = isCompleted
                              ? 100
                              : isInProgress
                                  ? math.min(
                                      95,
                                      math.max(15, (seconds * 100) ~/ 940),
                                    )
                                  : 0;

                          return _buildStudentProgressCard(
                            studentName: studentName,
                            initials: _initials(studentName),
                            isCompleted: isCompleted,
                            isInProgress: isInProgress,
                            seconds: seconds,
                            percentage: pct,
                          );
                        },
                      ),
          ),

          const SizedBox(height: 14),

          // Bottom "Close" Stadium Pill Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldPrimary,
                foregroundColor: _darkNavyText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(color: _darkNavyText, width: 1.3),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: _darkNavyText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProgressCard({
    required String studentName,
    required String initials,
    required bool isCompleted,
    required bool isInProgress,
    required int seconds,
    required int percentage,
  }) {
    final Color avatarBg = isCompleted
        ? AppColors.greenBadgeBg
        : isInProgress
            ? AppColors.creamPillSoft
            : AppColors.creamWarmLightE5e7eb;

    final Color pillBg = isCompleted
        ? AppColors.greenBadgeBg
        : isInProgress
            ? AppColors.creamPillSoft
            : AppColors.creamWarmLightE5e7eb;

    final Color pillText = isCompleted
        ? AppColors.greenPresent
        : isInProgress
            ? AppColors.bronzeOchreText
            : AppColors.textNeutralGray;

    final String subtitleText = isCompleted
        ? 'Completed (${_formatDuration(seconds > 0 ? seconds : 942)})'
        : isInProgress
            ? 'In Progress (${_formatDuration(seconds)})'
            : 'Not Started';

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.creamWarmLightE6dec8, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with status badge
          SizedBox(
            width: 50,
            height: 48,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarBg,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkNavyText,
                    ),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    bottom: 0,
                    right: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.greenEmerald218854,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (isInProgress)
                  Positioned(
                    bottom: -3,
                    left: -2,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: _goldPrimary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Text(
                          'In-progress',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: 0,
                    right: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grayMedium9ca3af,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Name, Status Subtitle, and Optional Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: _darkNavyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textNeutralGray,
                  ),
                ),
                if (isInProgress) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100.0,
                      minHeight: 5,
                      backgroundColor: AppColors.creamDivider,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_goldPrimary),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Percentage Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: pillText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditLessonSheet extends ConsumerStatefulWidget {
  final dynamic lesson;
  const _EditLessonSheet({required this.lesson});

  @override
  ConsumerState<_EditLessonSheet> createState() => _EditLessonSheetState();
}

class _EditLessonSheetState extends ConsumerState<_EditLessonSheet> {
  static const Color _sheetCream = AppColors.creamModalSheet;
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _goldPrimary = AppColors.goldBadgeBorder;

  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  bool _isLoading = false;
  PlatformFile? _selectedVideo;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.lesson.title);
    _descCtrl = TextEditingController(text: widget.lesson.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedVideo = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(shri_nrityalaya_app_dio.dioProvider);

      final formData = FormData.fromMap({
        'title': _titleCtrl.text,
        'description': _descCtrl.text,
      });

      if (_selectedVideo != null) {
        formData.files.add(
          MapEntry(
            'videoFile',
            await MultipartFile.fromFile(
              _selectedVideo!.path!,
              filename: _selectedVideo!.name,
            ),
          ),
        );
      }

      await dio.put('/lessons/${widget.lesson.id}', data: formData);
      ref.invalidate(lessonsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _sheetCream,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border:
            Border.all(color: _goldPrimary.withValues(alpha: 0.6), width: 1.2),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: _goldPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Edit Lesson',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _darkNavyText,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: 'Title',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.sandDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.sandDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _navyHeader, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.sandDivider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.sandDivider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: _navyHeader, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _darkNavyText,
              side: const BorderSide(color: _darkNavyText, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: _pickVideo,
            icon: const Icon(Icons.video_library_outlined, size: 18),
            label: Text(
              _selectedVideo != null
                  ? 'New Video: ${_selectedVideo!.name}'
                  : 'Replace Video (Optional)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldPrimary,
                foregroundColor: _darkNavyText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                  side: const BorderSide(color: _darkNavyText, width: 1.3),
                ),
              ),
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: _darkNavyText,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
