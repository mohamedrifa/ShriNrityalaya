import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isNameUpdating = false;
  bool _isPasswordUpdating = false;
  bool _hasLoadedInitialData = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateName() async {
    if (!_nameFormKey.currentState!.validate()) return;
    setState(() => _isNameUpdating = true);
    try {
      await ref.read(profileProvider.notifier).updateProfile(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isNameUpdating = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isPasswordUpdating = true);
    try {
      await ref.read(profileProvider.notifier).changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully!')));
        _currentPasswordController.clear();
        _newPasswordController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isPasswordUpdating = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(secureStorageProvider).delete(key: 'jwt_token');
    ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.warmCream,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (!_hasLoadedInitialData) {
            _firstNameController.text = profile['firstName'] ?? '';
            _lastNameController.text = profile['lastName'] ?? '';
            _hasLoadedInitialData = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryGold,
                        child: Icon(Icons.person, size: 50, color: AppColors.deepNavy),
                      ),
                      const SizedBox(height: 16),
                      Text('${profile['firstName']} ${profile['lastName']}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                      Text(profile['role'] ?? 'User', style: const TextStyle(color: AppColors.mutedText, fontSize: 16)),
                      Text(profile['email'] ?? profile['userName'] ?? '', style: const TextStyle(color: AppColors.mutedText)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Update Name Form
                Form(
                  key: _nameFormKey,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                          const SizedBox(height: 16),
                          TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: AppColors.primaryNavy),
                              onPressed: _isNameUpdating ? null : _updateName,
                              child: _isNameUpdating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Change Password Form
                Form(
                  key: _passwordFormKey,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                          const SizedBox(height: 16),
                          TextFormField(controller: _currentPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          TextFormField(controller: _newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryNavy, foregroundColor: Colors.white),
                              onPressed: _isPasswordUpdating ? null : _changePassword,
                              child: _isPasswordUpdating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Text('Change Password'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: _logout,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
