import 'package:dio/dio.dart';
import '../domain/models/academy_event.dart';

class EventRepository {
  final Dio _dio;

  EventRepository(this._dio);

  Future<List<AcademyEvent>> getEvents() async {
    final response = await _dio.get('/AcademyEvents');
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List data = response.data['data'];
      return data.map((e) => AcademyEvent.fromJson(e)).toList();
    }
    throw Exception('Failed to load events');
  }

  Future<AcademyEvent> createEvent(AcademyEvent event) async {
    final response = await _dio.post('/AcademyEvents', data: event.toJson());
    if (response.statusCode == 200 && response.data['success'] == true) {
      return AcademyEvent.fromJson(response.data['data']);
    }
    throw Exception('Failed to create event');
  }

  Future<void> registerForEvent(String eventId, String studentId) async {
    final response = await _dio.post('/EventParticipants/register', data: {
      'academyEventId': eventId,
      'studentId': studentId,
      'hasPaidFee': false
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to register');
    }
  }

  Future<AcademyEvent> updateEvent(AcademyEvent event) async {
    final response = await _dio.put('/AcademyEvents/${event.id}', data: event.toJson());
    if (response.statusCode == 200 && response.data['success'] == true) {
      return AcademyEvent.fromJson(response.data['data']);
    }
    throw Exception('Failed to update event');
  }
}
