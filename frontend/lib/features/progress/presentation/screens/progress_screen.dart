import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/features/progress/domain/models/skill_assessment.dart';
import 'package:shri_nrityalaya_app/features/students/presentation/providers/student_providers.dart';
import '../providers/progress_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final studentsState = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: studentsState.when(
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error: $err'),
              data: (students) {
                if (students.isEmpty) return const Text('No students found');
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Student', border: OutlineInputBorder()),
                  value: _selectedStudentId,
                  items: students.map((s) {
                    return DropdownMenuItem(value: s.id!, child: Text('${s.firstName} ${s.lastName}'));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedStudentId = val);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _selectedStudentId == null
                ? const Center(child: Text('Select a student to view progress.'))
                : _ProgressTimeline(studentId: _selectedStudentId!),
          ),
        ],
      ),
      floatingActionButton: _selectedStudentId == null ? null : FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGold,
        onPressed: () => _showAddAssessmentDialog(context, ref, _selectedStudentId!),
        icon: const Icon(Icons.add, color: AppColors.primaryNavy),
        label: const Text('Record Milestone', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddAssessmentDialog(BuildContext context, WidgetRef ref, String studentId) {
    final formKey = GlobalKey<FormState>();
    String skillType = 'Adavu';
    String skillLevel = 'Beginner';
    final nameCtrl = TextEditingController();
    final scoreCtrl = TextEditingController(text: '90');
    final remarksCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Milestone'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: skillType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Adavu', 'Margam', 'Theory'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => skillType = v!,
                ),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Skill Name (e.g. Tatta Adavu)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: skillLevel,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: ['Beginner', 'Intermediate', 'Advanced'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => skillLevel = v!,
                ),
                TextFormField(
                  controller: scoreCtrl,
                  decoration: const InputDecoration(labelText: 'Score (out of 100)'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: remarksCtrl,
                  decoration: const InputDecoration(labelText: 'Remarks'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final assessment = SkillAssessment(
                  studentId: studentId,
                  teacherId: '00000000-0000-0000-0000-000000000000', // Mock teacher ID
                  batchId: '00000000-0000-0000-0000-000000000000', // Mock batch ID
                  assessmentDate: DateTime.now(),
                  skillType: skillType,
                  skillName: nameCtrl.text.trim(),
                  skillLevel: skillLevel,
                  remarks: remarksCtrl.text.trim(),
                  score: int.tryParse(scoreCtrl.text) ?? 0,
                );
                await ref.read(studentAssessmentsProvider(studentId).notifier).addAssessment(assessment);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ProgressTimeline extends ConsumerWidget {
  final String studentId;
  const _ProgressTimeline({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studentAssessmentsProvider(studentId));

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (assessments) {
        if (assessments.isEmpty) return const Center(child: Text('No milestones recorded yet.'));
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: assessments.length,
          itemBuilder: (context, index) {
            final a = assessments[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: a.skillType == 'Adavu' ? AppColors.primaryNavy : AppColors.primaryGold,
                  child: Icon(
                    a.skillType == 'Adavu' ? Icons.directions_walk : Icons.auto_awesome,
                    color: a.skillType == 'Adavu' ? Colors.white : AppColors.primaryNavy,
                  ),
                ),
                title: Text(a.skillName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('${a.skillType} | Level: ${a.skillLevel}\nScore: ${a.score}/100\nRemarks: ${a.remarks}'),
                trailing: Text(
                  '${a.assessmentDate.day}/${a.assessmentDate.month}/${a.assessmentDate.year}',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
