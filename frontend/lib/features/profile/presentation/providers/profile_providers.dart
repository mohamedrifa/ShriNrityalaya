import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});

class ProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(String firstName, String lastName) async {
    try {
      await _repository.updateProfile(firstName, lastName);
      await loadProfile(); // Reload to get fresh data
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _repository.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadProfileImage(String filePath) async {
    try {
      final newUrl = await _repository.uploadProfileImage(filePath);
      if (state.hasValue) {
        final currentData = Map<String, dynamic>.from(state.value!);
        currentData['profilePictureUrl'] = newUrl;
        state = AsyncValue.data(currentData);
      } else {
        await loadProfile();
      }
    } catch (e) {
      rethrow;
    }
  }
}
