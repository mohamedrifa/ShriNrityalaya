import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'jwt_token');

      if (token == null || token.isEmpty) {
        if (mounted) context.go('/login');
        return;
      }

      final dio = ref.read(dioProvider);
      final response = await dio.get('/profile');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final role = response.data['data']['role'] ?? 'Teacher';
        ref.read(authProvider.notifier).setRole(role);
        
        if (mounted) {
          if (role == 'Teacher' || role == 'SystemAdmin') {
            context.go('/dashboard/teacher');
          } else if (role == 'Student') {
            context.go('/dashboard/student');
          } else if (role == 'Parent') {
            context.go('/dashboard/parent');
          } else {
            context.go('/dashboard/teacher'); // Fallback
          }
        }
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGold),
      ),
    );
  }
}
