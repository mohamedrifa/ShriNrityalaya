import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../data/skill_assessment_repository.dart';
import '../../domain/models/skill_assessment.dart';

import '../../../auth/presentation/providers/auth_providers.dart';

final skillAssessmentRepositoryProvider = Provider<SkillAssessmentRepository>((ref) {
  return SkillAssessmentRepository(ref.watch(dioProvider));
});

final studentAssessmentsProvider = StateNotifierProvider.autoDispose.family<AssessmentsNotifier, AsyncValue<List<SkillAssessment>>, String>((ref, studentId) {
  final auth = ref.watch(authProvider);
  return AssessmentsNotifier(
    ref.watch(skillAssessmentRepositoryProvider),
    studentId,
    isAuthenticated: auth.isAuthenticated,
  );
});

class AssessmentsNotifier extends StateNotifier<AsyncValue<List<SkillAssessment>>> {
  final SkillAssessmentRepository _repository;
  final String _studentId;
  final bool isAuthenticated;

  AssessmentsNotifier(this._repository, this._studentId, {this.isAuthenticated = true}) : super(const AsyncValue.loading()) {
    if (isAuthenticated) {
      loadAssessments();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadAssessments() async {
    if (_studentId.isEmpty || !mounted) return;
    state = const AsyncValue.loading();
    try {
      final data = await _repository.getAssessmentsForStudent(_studentId);
      if (!mounted) return;
      state = AsyncValue.data(data);
    } catch (e, stack) {
      if (!mounted) return;
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
