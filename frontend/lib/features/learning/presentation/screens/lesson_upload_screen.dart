import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../providers/lesson_providers.dart';

class LessonUploadScreen extends ConsumerStatefulWidget {
  const LessonUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LessonUploadScreen> createState() => _LessonUploadScreenState();
}

class _SelectedVideo {
  final File file;
  final TextEditingController descController;
  _SelectedVideo(this.file) : descController = TextEditingController();
}

class _LessonUploadScreenState extends ConsumerState<LessonUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  final List<_SelectedVideo> _selectedVideos = [];
  bool _isUploading = false;
  int _uploadProgress = 0;

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
        allowMultiple: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var platformFile in result.files) {
            if (platformFile.path != null) {
              _selectedVideos.add(_SelectedVideo(File(platformFile.path!)));
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error selecting video: $e')));
      }
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select at least one video')));
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final repo = ref.read(lessonRepositoryProvider);
      int order = int.tryParse(_orderController.text) ?? 1;

      for (int i = 0; i < _selectedVideos.length; i++) {
        final video = _selectedVideos[i];
        final formData = FormData.fromMap({
          'batchId': '00000000-0000-0000-0000-000000000000',
          'title': _selectedVideos.length > 1 ? '${_titleController.text.trim()} - Part ${i + 1}' : _titleController.text.trim(),
          'description': video.descController.text.trim(),
          'orderSequence': order + i,
          'videoFile': await MultipartFile.fromFile(video.file.path, filename: 'lesson_$i.mp4'),
        });

        await repo.uploadLesson(formData);
        if (mounted) {
          setState(() {
            _uploadProgress = i + 1;
          });
        }
      }

      await ref.read(lessonsProvider.notifier).loadLessons(); // Refresh list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lessons uploaded successfully!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('Upload Lesson'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Uploading video $_uploadProgress of ${_selectedVideos.length}...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Lesson Title (Applied to all parts)', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(labelText: 'Starting Order Sequence (e.g. 1)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Selected Videos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        TextButton.icon(
                          onPressed: _pickVideo,
                          icon: const Icon(Icons.add_circle, color: AppColors.primaryNavy),
                          label: const Text('Add Videos', style: TextStyle(color: AppColors.primaryNavy)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedVideos.isEmpty)
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.mutedText.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('No videos selected.', style: TextStyle(color: AppColors.mutedText))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedVideos.length,
                        itemBuilder: (ctx, i) {
                          final video = _selectedVideos[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Video ${i + 1}: ${video.file.path.split('/').last}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.error),
                                        onPressed: () {
                                          setState(() => _selectedVideos.removeAt(i));
                                        },
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: video.descController,
                                    decoration: InputDecoration(
                                      labelText: 'Description for Video ${i + 1}',
                                      border: const OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy),
                        onPressed: _upload,
                        child: const Text('Upload Lessons', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
