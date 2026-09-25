import 'package:dio/dio.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/profile');
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('Failed to load profile');
  }

  Future<void> updateProfile(String firstName, String lastName) async {
    final response = await _dio.put('/profile', data: {
      'firstName': firstName,
      'lastName': lastName,
    });
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to update profile');
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final response = await _dio.put('/profile/change-password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to change password');
    }
  }

  Future<String> uploadProfileImage(String filePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post('/profile/upload-image', data: formData);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['profilePictureUrl'];
    }
    throw Exception('Failed to upload image');
  }
}
