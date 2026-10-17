import 'package:dio/dio.dart';
import '../domain/models/announcement.dart';

class MessagingRepository {
  final Dio _dio;

  MessagingRepository(this._dio);

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _dio.get('/announcements');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> list = response.data['data'] ?? [];
      return list.map((a) => Announcement.fromJson(a as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Announcement> createAnnouncement(String title, String content) async {
    final response = await _dio.post(
      '/announcements',
      data: {'title': title, 'content': content},
    );
    return Announcement.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
