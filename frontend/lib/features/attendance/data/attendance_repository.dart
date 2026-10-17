import 'package:dio/dio.dart';
import '../domain/models/attendance_record.dart';

class AttendanceRepository {
  final Dio _dio;

  AttendanceRepository(this._dio);

  Future<void> submitBulkAttendance(List<AttendanceRecord> records) async {
    await _dio.post(
      '/attendance/bulk',
      data: records.map((r) => r.toJson()).toList(),
    );
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(String studentId) async {
    final response = await _dio.get('/attendance/student/$studentId');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'] as List;
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
