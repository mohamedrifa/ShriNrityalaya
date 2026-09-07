import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../data/skill_assessment_repository.dart';
import '../../domain/models/skill_assessment.dart';

final skillAssessmentRepositoryProvider = Provider<SkillAssessmentRepository>((ref) {
  return SkillAssessmentRepository(ref.watch(dioProvider));
});

final studentAssessmentsProvider = StateNotifierProvider.family<AssessmentsNotifier, AsyncValue<List<SkillAssessment>>, String>((ref, studentId) {
  return AssessmentsNotifier(ref.watch(skillAssessmentRepositoryProvider), studentId);
});

class AssessmentsNotifier extends StateNotifier<AsyncValue<List<SkillAssessment>>> {
  final SkillAssessmentRepository _repository;
  final String _studentId;

  AssessmentsNotifier(this._repository, this._studentId) : super(const AsyncValue.loading()) {
    loadAssessments();
  }

  Future<void> loadAssessments() async {
    if (_studentId.isEmpty) return;
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAssessmentsForStudent(_studentId);
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addAssessment(SkillAssessment assessment) async {
    try {
      final newOne = await _repository.createAssessment(assessment);
      if (state.hasValue) {
        state = AsyncValue.data([newOne, ...state.value!]);
      }
    } catch (e) {
      rethrow;
    }
  }
}
