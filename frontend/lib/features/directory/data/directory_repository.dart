import 'package:dio/dio.dart';
import '../domain/models/directory_entry.dart';

class DirectoryRepository {
  final Dio _dio;

  DirectoryRepository(this._dio);

  Future<List<DirectoryEntry>> getDirectoryEntries() async {
    final response = await _dio.get('/directory');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> list = response.data['data'] ?? [];
      return list.map((e) => DirectoryEntry.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
