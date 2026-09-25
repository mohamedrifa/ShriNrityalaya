import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:shri_nrityalaya_app/core/network/api_client.dart' as shri_nrityalaya_app_dio;
import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:shri_nrityalaya_app/features/learning/domain/models/lesson.dart';

class LessonPlayerScreen extends ConsumerStatefulWidget {
  final Lesson lesson;
  const LessonPlayerScreen({Key? key, required this.lesson}) : super(key: key);

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.lesson.videoUrl == null) {
        setState(() => _hasError = true);
        return;
      }
      
      final baseUrl = ref.read(shri_nrityalaya_app_dio.dioProvider).options.baseUrl.replaceAll('/api/v1', '');
      final fullUrl = baseUrl + widget.lesson.videoUrl!;

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
      await _videoPlayerController.initialize();
      
      if (mounted) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            aspectRatio: _videoPlayerController.value.aspectRatio,
            autoPlay: true,
            looping: false,
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error playing video: $errorMessage', style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          );
        });

        // Record progress every 5 seconds
        _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          if (_videoPlayerController.value.isPlaying) {
            _recordProgress();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  Future<void> _recordProgress() async {
    final pos = _videoPlayerController.value.position.inSeconds;
    final duration = _videoPlayerController.value.duration.inSeconds;
    final isFullyWatched = pos >= duration - 2; // close enough to the end

    try {
      await ref.read(shri_nrityalaya_app_dio.dioProvider).post(
        '/lessons/${widget.lesson.id}/progress',
        data: {
          'isFullyWatched': isFullyWatched,
          'watchDurationSeconds': pos,
        },
      );
    } catch (e) {
      // Ignore background progress errors
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _recordProgress(); // Final record on close
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            color: Colors.black,
            child: _hasError
                ? const Center(child: Text('Failed to load video', style: TextStyle(color: Colors.white)))
                : _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(height: 16),
                  const Text('Teacher\'s Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      widget.lesson.description?.isNotEmpty == true ? widget.lesson.description! : 'No description provided.',
                      style: const TextStyle(fontSize: 16, color: AppColors.primaryNavy, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
