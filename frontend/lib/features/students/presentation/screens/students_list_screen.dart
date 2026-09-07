import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../providers/student_providers.dart';

class StudentsListScreen extends ConsumerWidget {
  const StudentsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsState = ref.watch(studentsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: studentsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (students) {
          if (students.isEmpty) {
            return const Center(child: Text('No students found. Add one!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    '${student.firstName} ${student.lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  subtitle: Text(
                    'Status: ${student.status}\nJoined: ${student.joiningDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(color: AppColors.mutedText),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primaryGold),
                        onPressed: () {
                          context.push('/students/form', extra: student);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () => _confirmDelete(context, ref, student.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGold,
        onPressed: () {
          context.push('/students/form');
        },
        child: const Icon(Icons.add, color: AppColors.primaryNavy),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String studentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(studentsProvider.notifier).deleteStudent(studentId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete student: $e')),
          );
        }
      }
    }
  }
}
