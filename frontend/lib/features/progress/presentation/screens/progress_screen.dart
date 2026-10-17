import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../core/utils/app_error_handler.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import 'package:shri_nrityalaya_app/features/progress/domain/models/skill_assessment.dart';
import 'package:shri_nrityalaya_app/features/students/domain/models/student.dart';
import 'package:shri_nrityalaya_app/features/students/presentation/providers/student_providers.dart';
import 'package:shri_nrityalaya_app/features/auth/presentation/providers/auth_providers.dart'
    as auth;
import '../providers/progress_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _navyCardTop = AppColors.navyCardTop;
  static const Color _navyCardBottom = AppColors.navyCardBottom;
  static const Color _goldBright = AppColors.goldBright;
  static const Color _goldPrimary = AppColors.goldBorder;
  static const Color _darkNavyText = AppColors.darkNavyText;

  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(auth.authProvider).userRole;
      if (role == 'Student' || role == 'Parent') {
        setState(() => _selectedStudentId = 'me');
      }
    });
  }

  String _initialsForStudent(Student s) {
    final first = s.firstName.trim();
    final last = s.lastName.trim();
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isEmpty ? 'ST' : combined;
  }

  void _showStudentPickerSheet(List<Student> students) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: AppColors.creamModalSheet,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: _goldPrimary.withValues(alpha: 0.65),
              width: 1.2,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: _goldPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Select Student',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _darkNavyText,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final s = students[index];
                    final isSelected = s.id == _selectedStudentId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _navyHeader : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? _goldPrimary
                              : AppColors.creamWarmLightE2d9c5,
                          width: 1.2,
                        ),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        onTap: () {
                          setState(() => _selectedStudentId = s.id);
                          Navigator.pop(ctx);
                        },
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.navyRoyal203864
                                : AppColors.creamPillSoft,
                            border: Border.all(color: _goldPrimary, width: 1.3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initialsForStudent(s),
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? _goldBright : _darkNavyText,
                            ),
                          ),
                        ),
                        title: Text(
                          '${s.firstName} ${s.lastName}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isSelected ? Colors.white : _darkNavyText,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: _goldBright,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(auth.authProvider).userRole;
    final isTeacherOrAdmin = role == 'Teacher' || role == 'SystemAdmin';
    final studentsState = ref.watch(studentsProvider);

    // Auto-select first student for Teacher/Admin once loaded so the screen is immediately populated
    if (isTeacherOrAdmin &&
        _selectedStudentId == null &&
        studentsState.hasValue &&
        studentsState.value!.isNotEmpty) {
      _selectedStudentId = studentsState.value!.first.id;
    }

    final assessmentsAsync = (_selectedStudentId != null &&
            _selectedStudentId!.isNotEmpty)
        ? ref.watch(studentAssessmentsProvider(_selectedStudentId!))
        : const AsyncValue<List<SkillAssessment>>.data([]);

    final List<SkillAssessment> currentAssessments =
        assessmentsAsync.asData?.value ?? const [];

    final int milestoneCount = currentAssessments.length;
    final int overallAvg = milestoneCount == 0
        ? 0
        : (currentAssessments.fold<int>(0, (sum, a) => sum + a.score) /
                milestoneCount)
            .round();

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: _navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 62,
        leadingWidth: 64,
        leading: Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/dashboard');
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.navyAccentDark,
                border: Border.all(
                  color: AppColors.navyGradientMid,
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ),
        title: const Text(
          'Student Progress',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _goldBright,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.navyAccentDark,
                  border: Border.all(
                    color: AppColors.navyGradientMid,
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: _goldBright,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
      children: [
        Column(
          children: [
            // Top Hero Summary Card with Extended Navy Backdrop
            Stack(
              children: [
                Container(
                  height: isTeacherOrAdmin ? 74 : 46,
                  width: double.infinity,
                  color: _navyHeader,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_navyCardTop, _navyCardBottom],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _goldPrimary, width: 1.3),
                      boxShadow: [
                        BoxShadow(
                          color: _navyHeader.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isTeacherOrAdmin) ...[
                          studentsState.when(
                            loading: () => const SizedBox(
                              height: 42,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _goldBright,
                                  ),
                                ),
                              ),
                            ),
                            error: (err, _) => Text(
                              AppErrorHandler.toShortMessage(err),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            data: (students) {
                              if (students.isEmpty) {
                                return const Text(
                                  'No students found',
                                  style: TextStyle(color: Colors.white70),
                                );
                              }
                              final selectedStudent = students.firstWhere(
                                (s) => s.id == _selectedStudentId,
                                orElse: () => students.first,
                              );
                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _showStudentPickerSheet(students),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white
                                          .withValues(alpha: 0.10),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.navyRoyal284170,
                                          border: Border.all(
                                            color: _goldBright,
                                            width: 1.6,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          _initialsForStudent(selectedStudent),
                                          style: const TextStyle(
                                            color: _goldBright,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${selectedStudent.firstName} ${selectedStudent.lastName}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: _goldBright,
                                        size: 26,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          const SizedBox(height: 12),
                        ],
      
                        // Stats Summary Row: Overall Avg | Milestones Completed
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$overallAvg%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Overall Avg',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.80),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 34,
                              width: 1,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 22),
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$milestoneCount',
                                    style: const TextStyle(
                                      color: _goldBright,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w700,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Milestones Completed',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.80),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.auto_awesome,
                              color: _goldBright,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      
            // Timeline List
            Expanded(
              child: _selectedStudentId == null
                  ? const Center(
                      child: Text(
                        'Select a student to view progress.',
                        style: TextStyle(
                          color: _darkNavyText,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : _ProgressTimeline(
                      studentId: _selectedStudentId!,
                      bottomPadding: isTeacherOrAdmin ? 92 : 24,
                    ),
            ),
          ],
        ),
      
        // Bottom Full-Width "+ Record Assessment" Stadium Pill Button
        if (_selectedStudentId != null && isTeacherOrAdmin)
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _navyHeader,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _goldPrimary, width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: _navyHeader.withValues(alpha: 0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => _showAddAssessmentDialog(
                    context,
                    ref,
                    _selectedStudentId!,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: _goldBright, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Record Assessment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAssessmentDialog(
    BuildContext context,
    WidgetRef ref,
    String studentId,
  ) {
    final formKey = GlobalKey<FormState>();
    String skillType = 'Adavu';
    String skillLevel = 'Beginner';
    final nameCtrl = TextEditingController();
    final scoreCtrl = TextEditingController(text: '90');
    final remarksCtrl = TextEditingController();

    InputDecoration fieldDecoration(String label) {
      return InputDecoration(
        labelText: label,
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
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.creamModalSheet,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: _goldPrimary.withValues(alpha: 0.65),
                width: 1.2,
              ),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
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
                      'Record Assessment',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _darkNavyText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: skillType,
                      decoration: fieldDecoration('Type'),
                      items: ['Adavu', 'Margam', 'Theory']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setModalState(() => skillType = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: fieldDecoration(
                        'Skill Name (e.g. Footwork, Performance)',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: skillLevel,
                      decoration: fieldDecoration('Level'),
                      items: ['Beginner', 'Intermediate', 'Advanced']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setModalState(() => skillLevel = v!),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: scoreCtrl,
                      decoration: fieldDecoration('Score (out of 100)'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: remarksCtrl,
                      maxLines: 3,
                      decoration: fieldDecoration('Remarks'),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _darkNavyText,
                              side: const BorderSide(
                                color: _darkNavyText,
                                width: 1.2,
                              ),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navyHeader,
                              foregroundColor: _goldBright,
                              minimumSize: const Size.fromHeight(48),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                                side: const BorderSide(
                                  color: _goldPrimary,
                                  width: 1.3,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final assessment = SkillAssessment(
                                  studentId: studentId,
                                  teacherId:
                                      '00000000-0000-0000-0000-000000000000',
                                  batchId:
                                      '00000000-0000-0000-0000-000000000000',
                                  assessmentDate: DateTime.now(),
                                  skillType: skillType,
                                  skillName: nameCtrl.text.trim(),
                                  skillLevel: skillLevel,
                                  remarks: remarksCtrl.text.trim(),
                                  score: int.tryParse(scoreCtrl.text) ?? 0,
                                );
                                await ref
                                    .read(
                                      studentAssessmentsProvider(studentId)
                                          .notifier,
                                    )
                                    .addAssessment(assessment);
                                if (ctx.mounted) Navigator.pop(ctx);
                              }
                            },
                            child: const Text(
                              'Save Milestone',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _goldBright,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressTimeline extends ConsumerWidget {
  final String studentId;
  final double bottomPadding;

  const _ProgressTimeline({
    required this.studentId,
    required this.bottomPadding,
  });

  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _goldBright = AppColors.goldBright;
  static const Color _goldPrimary = AppColors.goldBorder;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _cardBorderNavy = AppColors.navyCardBorder;

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

  String _displayTitle(SkillAssessment a) {
    final name = a.skillName.trim();
    final type = a.skillType.trim();
    if (name.isEmpty) return type;
    if (name.toLowerCase().contains(type.toLowerCase()) || name.contains('-')) {
      return name;
    }
    return '$type - $name';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentAssessmentsProvider(studentId));

    return state.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: _navyHeader),
      ),
      error: (err, stack) => ErrorView(
        error: err,
        onRetry: () => ref.refresh(studentAssessmentsProvider(studentId)),
      ),
      data: (assessments) {
        if (assessments.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: 50,
                  color: _navyHeader.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 10),
                const Text(
                  'No milestones recorded yet.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textNeutralGray,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(14, 10, 16, bottomPadding),
          itemCount: assessments.length,
          itemBuilder: (context, index) {
            final a = assessments[index];
            final isFirst = index == 0;
            final isLast = index == assessments.length - 1;
            final isDashedBottom = index >= 1 && !isLast;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Vertical Timeline Column
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        // Upper line leading to node
                        Container(
                          width: 2,
                          height: 22,
                          color: isFirst
                              ? Colors.transparent
                              : (index > 1
                                  ? Colors.transparent
                                  : _goldPrimary),
                          child: (!isFirst && index > 1)
                              ? CustomPaint(
                                  painter: _DashedVerticalLinePainter(
                                    color: _darkNavyText,
                                  ),
                                )
                              : null,
                        ),
                        // Timeline Node Circle
                        _buildTimelineNode(index, isLast, a),
                        // Lower line extending to bottom of item
                        Expanded(
                          child: isLast
                              ? const SizedBox.shrink()
                              : isDashedBottom
                                  ? CustomPaint(
                                      size: const Size(2, double.infinity),
                                      painter: _DashedVerticalLinePainter(
                                        color: _darkNavyText,
                                      ),
                                    )
                                  : Container(
                                      width: 2,
                                      color: _goldPrimary,
                                    ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right Milestone Card
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _cardBorderNavy,
                          width: 1.4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _navyHeader.withValues(alpha: 0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Title + Level Pill + Circular Score Ring
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayTitle(a),
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w700,
                                        color: _darkNavyText,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    _buildLevelPill(a.skillLevel),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              _ScoreCircularBadge(score: a.score),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Gradient Progress Bar
                          Container(
                            height: 7,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _darkNavyText,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor:
                                  (a.score.clamp(0, 100)) / 100.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    colors: index == 0
                                        ? const [
                                            AppColors.blueAccent,
                                            AppColors.greenEmerald3e7b52,
                                            AppColors.goldBorder,
                                          ]
                                        : const [
                                            AppColors.crimsonAlertB8923a,
                                            AppColors.goldBright,
                                          ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Assessed Date Row
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 13.5,
                                color: AppColors.textMutedSlate,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Assessed on ${_formatDate(a.assessmentDate)}',
                                style: const TextStyle(
                                  fontSize: 12.2,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMutedSlate,
                                ),
                              ),
                            ],
                          ),

                          // Remarks Quote Block
                          if (a.remarks.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(12, 8, 12, 10),
                              decoration: BoxDecoration(
                                color: AppColors.creamWarmLightF6f1e6,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '“',
                                    style: TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: _goldPrimary,
                                      height: 0.75,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      a.remarks.trim(),
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontStyle: FontStyle.italic,
                                        color: AppColors.navySlate232c3d,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTimelineNode(int index, bool isLast, SkillAssessment a) {
    final levelLower = a.skillLevel.toLowerCase();
    if (index == 0) {
      // Top completed checkmark node
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _navyHeader,
          border: Border.all(color: _goldPrimary, width: 1.8),
        ),
        child: const Icon(Icons.check, size: 13.5, color: _goldBright),
      );
    } else if (levelLower == 'advanced' || (isLast && index >= 2)) {
      // Sparkle milestone node
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _navyHeader,
          border: Border.all(color: _goldPrimary, width: 1.8),
        ),
        child: const Icon(Icons.auto_awesome, size: 12, color: _goldBright),
      );
    } else {
      // Olive-green intermediate node with dark-navy ring
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.greenEmerald6b8a47,
          border: Border.all(color: _darkNavyText, width: 2.0),
        ),
      );
    }
  }

  Widget _buildLevelPill(String level) {
    final normalized = level.trim().toLowerCase();
    Color bg;
    Color fg;

    if (normalized == 'intermediate') {
      bg = AppColors.sandWarmMutedF5e6b8;
      fg = AppColors.bronzeDark6b5314;
    } else if (normalized == 'advanced') {
      bg = _navyHeader;
      fg = Colors.white;
    } else {
      // Beginner default
      bg = AppColors.greenBadgeBg;
      fg = AppColors.greenPresent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level.isEmpty ? 'Beginner' : level,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

/// Circular score badge showing `score / 100` inside a gold-arc progress ring.
class _ScoreCircularBadge extends StatelessWidget {
  final int score;
  const _ScoreCircularBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: CustomPaint(
        painter: _ScoreRingPainter(progress: (score.clamp(0, 100)) / 100.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 1.5),
              Text(
                '100',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  _ScoreRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dark navy inner disk
    final fillPaint = Paint()
      ..color = AppColors.navyHeader
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 2, fillPaint);

    // Subtle track ring
    final trackPaint = Paint()
      ..color = AppColors.navyRoyal283e66
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius - 2.5, trackPaint);

    // Gold progress arc
    final arcPaint = Paint()
      ..color = AppColors.goldBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2.5),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _DashedVerticalLinePainter extends CustomPainter {
  final Color color;
  _DashedVerticalLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4.5;
    const dashSpace = 4.0;
    double startY = 0;
    final x = size.width / 2;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, math.min(startY + dashHeight, size.height)),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
