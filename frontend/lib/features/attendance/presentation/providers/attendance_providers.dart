import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/attendance_repository.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(dioProvider));
});

final studentAttendanceProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, studentId) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return await repo.getStudentAttendance(studentId);
});
