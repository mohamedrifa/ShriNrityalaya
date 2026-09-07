import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../providers/lesson_providers.dart';

class LearningModuleScreen extends ConsumerWidget {
  const LearningModuleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsState = ref.watch(lessonsProvider);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Learning & Practice'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: lessonsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (lessons) {
          if (lessons.isEmpty) return const Center(child: Text('No lessons available.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lesson.videoUrl != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        color: Colors.black87,
                        child: const Center(
                          child: Icon(Icons.play_circle_fill, size: 64, color: AppColors.primaryGold),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lesson ${lesson.orderSequence}: ${lesson.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                          if (lesson.description != null && lesson.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(lesson.description!, style: const TextStyle(color: AppColors.mutedText)),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/learning/upload'),
        backgroundColor: AppColors.primaryGold,
        icon: const Icon(Icons.upload, color: AppColors.primaryNavy),
        label: const Text('Upload Lesson', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
