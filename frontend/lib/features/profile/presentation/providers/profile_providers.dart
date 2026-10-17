import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final auth = ref.watch(authProvider);
  return ProfileNotifier(
    ref.watch(profileRepositoryProvider),
    isAuthenticated: auth.isAuthenticated,
  );
});

class ProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ProfileRepository _repository;
  final bool isAuthenticated;

  ProfileNotifier(this._repository, {this.isAuthenticated = true}) : super(const AsyncValue.loading()) {
    if (isAuthenticated) {
      loadProfile();
    } else {
      state = const AsyncValue.data({});
    }
  }

  Future<void> loadProfile() async {
    if (!mounted) return;
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      if (!mounted) return;
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      if (!mounted) return;
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
