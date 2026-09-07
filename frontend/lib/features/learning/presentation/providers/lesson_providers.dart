import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../data/lesson_repository.dart';
import '../../domain/models/lesson.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository(ref.watch(dioProvider));
});

final lessonsProvider = StateNotifierProvider<LessonsNotifier, AsyncValue<List<Lesson>>>((ref) {
  return LessonsNotifier(ref.watch(lessonRepositoryProvider));
});

class LessonsNotifier extends StateNotifier<AsyncValue<List<Lesson>>> {
  final LessonRepository _repository;

  LessonsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadLessons();
  }

  Future<void> loadLessons() async {
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAllLessons();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
