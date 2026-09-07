import 'package:dio/dio.dart';
import '../domain/models/skill_assessment.dart';

class SkillAssessmentRepository {
  final Dio _dio;

  SkillAssessmentRepository(this._dio);

  Future<List<SkillAssessment>> getAssessmentsForStudent(String studentId) async {
    final response = await _dio.get('/SkillAssessments/student/$studentId');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => SkillAssessment.fromJson(e)).toList();
    }
    throw Exception('Failed to load assessments');
  }

  Future<SkillAssessment> createAssessment(SkillAssessment assessment) async {
    final response = await _dio.post('/SkillAssessments', data: assessment.toJson());
    if (response.statusCode == 200 && response.data['success'] == true) {
      return SkillAssessment.fromJson(response.data['data']);
    }
    throw Exception('Failed to create assessment');
  }
}
