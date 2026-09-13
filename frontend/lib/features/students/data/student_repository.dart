import 'package:dio/dio.dart';
import '../domain/models/student.dart';

class StudentRepository {
  final Dio _dio;

  StudentRepository(this._dio);

  Future<List<Student>> getStudents() async {
    final response = await _dio.get('/students');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => Student.fromJson(e)).toList();
    }
    throw Exception('Failed to load students');
  }

  Future<Student> createStudent(Map<String, dynamic> payload) async {
    final response = await _dio.post('/students', data: payload);
    if (response.statusCode == 201 && response.data['success'] == true) {
      return Student.fromJson(response.data['data']);
    }
    throw Exception('Failed to create student');
  }

  Future<Student> updateStudent(Student student) async {
    final response = await _dio.put('/students/${student.id}', data: student.toJson());
    if (response.statusCode == 200 && response.data['success'] == true) {
      return Student.fromJson(response.data['data']);
    }
    throw Exception('Failed to update student');
  }

  Future<void> deleteStudent(String id) async {
    final response = await _dio.delete('/students/$id');
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception('Failed to delete student');
    }
  }
}
