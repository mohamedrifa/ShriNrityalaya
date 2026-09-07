import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/login', data: {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      });

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final List<dynamic> roles = data['roles'] ?? [];
        
        final storage = ref.read(secureStorageProvider);
        await storage.write(key: 'jwt_token', value: token);
        
        if (mounted) {
          if (roles.contains('Teacher') || roles.contains('SystemAdmin')) {
            ref.read(authProvider.notifier).setRole('Teacher');
            context.go('/dashboard/teacher');
          } else if (roles.contains('Student')) {
            ref.read(authProvider.notifier).setRole('Student');
            context.go('/dashboard/student');
          } else if (roles.contains('Parent')) {
            ref.read(authProvider.notifier).setRole('Parent');
            context.go('/dashboard/parent');
          } else {
            // Default fallback
            ref.read(authProvider.notifier).setRole('Teacher');
            context.go('/dashboard/teacher');
          }
        }
      }
    } on DioException catch (e) {
      setState(() {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          _errorMessage = data['message'];
        } else if (data is String && data.isNotEmpty) {
          _errorMessage = data;
        } else {
          _errorMessage = 'Login failed. Please check credentials.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientNavy,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Using a placeholder icon since image might need pubspec config
                      const Icon(Icons.school, size: 80, color: AppColors.primaryGold),
                      const SizedBox(height: 16),
                      Text(
                        'Shri Nrityalaya',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Academy Management System', style: TextStyle(color: AppColors.mutedText)),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                      ],
                      const SizedBox(height: 32),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: AppColors.deepNavy)
                            : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
