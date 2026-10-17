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
}
