import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../providers/lesson_providers.dart';

class LessonUploadScreen extends ConsumerStatefulWidget {
  const LessonUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LessonUploadScreen> createState() => _LessonUploadScreenState();
}

class _LessonUploadScreenState extends ConsumerState<LessonUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  File? _videoFile;
  bool _isUploading = false;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select a video')));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final repo = ref.read(lessonRepositoryProvider);
      final formData = FormData.fromMap({
        'batchId': '00000000-0000-0000-0000-000000000000', // Mock batch ID for now
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'orderSequence': int.tryParse(_orderController.text) ?? 1,
        'videoFile': await MultipartFile.fromFile(_videoFile!.path, filename: 'lesson.mp4'),
      });

      await repo.uploadLesson(formData);
      await ref.read(lessonsProvider.notifier).loadLessons(); // Refresh list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lesson uploaded successfully!')));
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
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Uploading video...')]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Lesson Title', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(labelText: 'Order Sequence (e.g. 1)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    const Text('Video File', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickVideo,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.primaryNavy),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: _videoFile == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.video_library, size: 40, color: AppColors.primaryGold),
                                    SizedBox(height: 8),
                                    Text('Tap to select video', style: TextStyle(color: AppColors.mutedText)),
                                  ],
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle, size: 40, color: AppColors.success),
                                    SizedBox(height: 8),
                                    Text('Video Selected', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy),
                        onPressed: _upload,
                        child: const Text('Upload Lesson', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
