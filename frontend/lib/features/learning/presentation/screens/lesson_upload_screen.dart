import '../../../../core/utils/app_error_handler.dart';
import 'dart:io';
import 'package:shri_nrityalaya_app/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import '../providers/lesson_providers.dart';

class LessonUploadScreen extends ConsumerStatefulWidget {
  const LessonUploadScreen({super.key});

  @override
  ConsumerState<LessonUploadScreen> createState() => _LessonUploadScreenState();
}

class _SelectedVideo {
  final File file;
  final TextEditingController descController;
  _SelectedVideo(this.file) : descController = TextEditingController();
}

class _LessonUploadScreenState extends ConsumerState<LessonUploadScreen> {
  static const Color _navyHeader = AppColors.navyHeader;
  static const Color _goldBright = AppColors.goldBright;
  static const Color _goldPrimary = AppColors.goldBadgeBorder;
  static const Color _darkNavyText = AppColors.darkNavyText;
  static const Color _cardBorderNavy = AppColors.navyCardBorder;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  final List<_SelectedVideo> _selectedVideos = [];
  bool _isUploading = false;
  int _uploadProgress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    for (final v in _selectedVideos) {
      v.descController.dispose();
    }
    super.dispose();
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate() || _selectedVideos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select at least one video'),
        ),
      );
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
          'title': _selectedVideos.length > 1
              ? '${_titleController.text.trim()} - Part ${i + 1}'
              : _titleController.text.trim(),
          'description': video.descController.text.trim(),
          'orderSequence': order + i,
          'videoFile': await MultipartFile.fromFile(
            video.file.path,
            filename: 'lesson_$i.mp4',
          ),
        });

        await repo.uploadLesson(formData);
        if (mounted) {
          setState(() {
            _uploadProgress = i + 1;
          });
        }
      }

      await ref.read(lessonsProvider.notifier).loadLessons();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lessons uploaded successfully!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppErrorHandler.toShortMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: _navyHeader,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Upload Lesson',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: _goldBright,
          ),
        ),
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: _navyHeader),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading video $_uploadProgress of ${_selectedVideos.length}...',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _darkNavyText,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _cardBorderNavy, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: _navyHeader.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lesson Details',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: _darkNavyText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _titleController,
                            decoration: _inputDecoration(
                              'Lesson Title (Applied to all parts)',
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _orderController,
                            decoration: _inputDecoration(
                              'Starting Order Sequence (e.g. 1)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Selected Videos',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: _darkNavyText,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _pickVideo,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _navyHeader,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: _goldPrimary,
                                width: 1.2,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 16,
                                  color: _goldBright,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Add Videos',
                                  style: TextStyle(
                                    color: _goldBright,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedVideos.isEmpty)
                      Container(
                        height: 115,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _cardBorderNavy.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_call_outlined,
                              size: 34,
                              color: AppColors.mutedText,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'No videos selected.',
                              style: TextStyle(color: AppColors.mutedText),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedVideos.length,
                        itemBuilder: (ctx, i) {
                          final video = _selectedVideos[i];
                          final fileName =
                              video.file.path.split(RegExp(r'[/\\]')).last;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _cardBorderNavy,
                                width: 1.3,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: _navyHeader,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.play_circle_outline,
                                        color: _goldBright,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Video ${i + 1}: $fileName',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: _darkNavyText,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: AppColors.error,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _selectedVideos[i]
                                              .descController
                                              .dispose();
                                          _selectedVideos.removeAt(i);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: video.descController,
                                  decoration: _inputDecoration(
                                    'Description for Video ${i + 1}',
                                  ).copyWith(isDense: true),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _goldPrimary,
                          foregroundColor: _darkNavyText,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                            side: const BorderSide(
                              color: _darkNavyText,
                              width: 1.3,
                            ),
                          ),
                        ),
                        onPressed: _upload,
                        child: const Text(
                          'Upload Lessons',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: _darkNavyText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
