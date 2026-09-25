import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart' as shri_nrityalaya_app_dio;
import '../../../auth/presentation/providers/auth_providers.dart' as shri_nrityalaya_app_auth;
import '../providers/lesson_providers.dart';

class LearningModuleScreen extends ConsumerWidget {
  const LearningModuleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsState = ref.watch(lessonsProvider);
    final userRole = ref.watch(shri_nrityalaya_app_auth.authProvider).userRole;

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
                child: InkWell(
                  onTap: () {
                    if (lesson.videoUrl != null) {
                      context.push('/learning/play', extra: lesson);
                    }
                  },
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
                            Text(lesson.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                            if (lesson.description != null && lesson.description!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                lesson.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.mutedText),
                              ),
                            ],
                            if (userRole == 'Teacher' || userRole == 'SystemAdmin') ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => _EditLessonSheet(lesson: lesson),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, color: AppColors.primaryNavy),
                                    label: const Text('Edit', style: TextStyle(color: AppColors.primaryNavy)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) => _LessonProgressSheet(lessonId: lesson.id!),
                                      );
                                    },
                                    icon: const Icon(Icons.analytics, color: AppColors.primaryNavy),
                                    label: const Text('Progress', style: TextStyle(color: AppColors.primaryNavy)),
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: (userRole == 'Teacher' || userRole == 'SystemAdmin') ? FloatingActionButton.extended(
        onPressed: () => context.push('/learning/upload'),
        backgroundColor: AppColors.primaryGold,
        icon: const Icon(Icons.upload, color: AppColors.primaryNavy),
        label: const Text('Upload Lesson', style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold)),
      ) : null,
    );
  }
}

class _LessonProgressSheet extends ConsumerStatefulWidget {
  final String lessonId;
  const _LessonProgressSheet({required this.lessonId});

  @override
  ConsumerState<_LessonProgressSheet> createState() => _LessonProgressSheetState();
}

class _LessonProgressSheetState extends ConsumerState<_LessonProgressSheet> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Progress', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _progress.isEmpty
                    ? const Center(child: Text('No students have watched this yet.'))
                    : ListView.builder(
                        itemCount: _progress.length,
                        itemBuilder: (context, index) {
                          final p = _progress[index];
                          return ListTile(
                            leading: Icon(
                              p['isFullyWatched'] == true ? Icons.check_circle : Icons.play_circle_outline,
                              color: p['isFullyWatched'] == true ? AppColors.success : AppColors.primaryGold,
                            ),
                            title: Text(p['studentName'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Watched: ${p['watchDurationSeconds']} seconds'),
                            trailing: p['isFullyWatched'] == true ? const Text('Completed', style: TextStyle(color: AppColors.success)) : null,
                          );
                        },
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick video: $e')));
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
        formData.files.add(MapEntry(
          'videoFile',
          await MultipartFile.fromFile(_selectedVideo!.path!, filename: _selectedVideo!.name),
        ));
      }

      await dio.put('/lessons/${widget.lesson.id}', data: formData);
      ref.invalidate(lessonsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Edit Lesson', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickVideo,
            icon: const Icon(Icons.video_library),
            label: Text(_selectedVideo != null ? 'New Video: ${_selectedVideo!.name}' : 'Replace Video (Optional)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy),
              onPressed: _isLoading ? null : _save,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
