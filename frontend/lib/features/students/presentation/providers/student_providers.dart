import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../data/student_repository.dart';
import '../../domain/models/student.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository(ref.watch(dioProvider));
});

final studentsProvider = StateNotifierProvider<StudentsNotifier, AsyncValue<List<Student>>>((ref) {
  return StudentsNotifier(ref.watch(studentRepositoryProvider));
});

class StudentsNotifier extends StateNotifier<AsyncValue<List<Student>>> {
  final StudentRepository _repository;

  StudentsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    state = const AsyncValue.loading();
    try {
      final students = await _repository.getStudents();
      state = AsyncValue.data(students);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addStudent(Map<String, dynamic> payload) async {
    try {
      final newStudent = await _repository.createStudent(payload);
      if (state.value != null) {
        state = AsyncValue.data([...state.value!, newStudent]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      final updatedStudent = await _repository.updateStudent(student);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.map((e) => e.id == updatedStudent.id ? updatedStudent : e).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _repository.deleteStudent(id);
      if (state.hasValue) {
        state = AsyncValue.data(
          state.value!.where((e) => e.id != id).toList(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
