import 'package:dio/dio.dart';
import '../domain/models/lesson.dart';

class LessonRepository {
  final Dio _dio;

  LessonRepository(this._dio);

  Future<List<Lesson>> getAllLessons() async {
    final response = await _dio.get('/Lessons');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => Lesson.fromJson(e)).toList();
    }
    throw Exception('Failed to load lessons');
  }

  Future<Lesson> uploadLesson(FormData formData) async {
    final response = await _dio.post('/Lessons/upload', data: formData);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return Lesson.fromJson(response.data['data']);
    }
    throw Exception('Failed to upload lesson');
  }
}
