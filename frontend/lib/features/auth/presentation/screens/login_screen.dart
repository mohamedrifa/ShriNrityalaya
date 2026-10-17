import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/api_client.dart';
import '../../../fees/presentation/providers/fee_obligations_providers.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Color _navyBgTop = AppColors.navyBgTop;
  static const Color _navyBgBottom = AppColors.navyBgBottom;
  static const Color _cardCream = AppColors.creamCardSurface;
  static const Color _darkNavy = AppColors.navyHeader;
  static const Color _fieldBorderNavy = AppColors.navyFieldBorder;
  static const Color _goldPrimary = AppColors.goldBorder;
  static const Color _goldIcon = AppColors.goldIconTint;
  static const Color _goldButtonText = AppColors.goldTitle;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'];
        final List<dynamic> roles = data['roles'] ?? [];

        final storage = ref.read(secureStorageProvider);
        await storage.write(key: 'jwt_token', value: token);

        // Clear cached data from any previous sessions
        ref.invalidate(feeObligationsProvider);
        ref.invalidate(profileProvider);

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
        final shortMsg = AppErrorHandler.toShortMessage(e);
        if (shortMsg == 'No Internet' || shortMsg == 'Internal Server Error') {
          _errorMessage = shortMsg;
        } else {
          final data = e.response?.data;
          if (data is Map && data.containsKey('message') && data['message'] is String && (data['message'] as String).isNotEmpty) {
            _errorMessage = data['message'];
          } else {
            _errorMessage = 'Login failed. Please check credentials.';
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppErrorHandler.toShortMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _buildFieldDecoration({
    required String label,
    required String hint,
    required Widget prefixIcon,
    Widget? suffixIcon,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _fieldBorderNavy, width: 1.35),
    );
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: _fieldBorderNavy,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
      ),
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.grayMedium646d7a,
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: _cardCream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkNavy, width: 1.7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_navyBgTop, _navyBgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cardCream,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _goldPrimary, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.38),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 4 Corner Lotus Ornaments
                      const Positioned(
                        top: 10,
                        left: 10,
                        child: _LoginCornerLotusOrnament(
                          angle: -math.pi / 4,
                        ),
                      ),
                      const Positioned(
                        top: 10,
                        right: 10,
                        child: _LoginCornerLotusOrnament(
                          angle: math.pi / 4,
                        ),
                      ),
                      const Positioned(
                        bottom: 10,
                        left: 10,
                        child: _LoginCornerLotusOrnament(
                          angle: -3 * math.pi / 4,
                        ),
                      ),
                      const Positioned(
                        bottom: 10,
                        right: 10,
                        child: _LoginCornerLotusOrnament(
                          angle: 3 * math.pi / 4,
                        ),
                      ),

                      // Foreground Form Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 34, 24, 38),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ornate Golden Mandala Medallion with Dancer Logo
                            SizedBox(
                              width: 108,
                              height: 108,
                              child: CustomPaint(
                                painter: const _LoginMandalaMedallionPainter(),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.crimsonAlertD6ae50,
                                              AppColors.crimsonDeep9b7120,
                                            ],
                                          ).createShader(bounds),
                                      blendMode: BlendMode.srcIn,
                                      child: Image.asset(
                                        'assets/logo/academy_logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Title: ShriNrityalaya
                            const Text(
                              'ShriNrityalaya',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                                color: _darkNavy,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // Subtitle: Academy Management System
                            const Text(
                              'Academy Management System',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grayDark555e6c,
                              ),
                            ),

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.crimsonErrorBannerBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.crimsonAlertD97777,
                                  ),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.crimsonDarkText,
                                    fontSize: 12.8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 28),

                            // Email Field
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: _darkNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _buildFieldDecoration(
                                label: 'Email',
                                hint: 'e.g., kiran.parent@gmail.com',
                                prefixIcon: const Icon(
                                  Icons.email_rounded,
                                  color: _goldIcon,
                                  size: 21,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(
                                color: _darkNavy,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: _buildFieldDecoration(
                                label: 'Password',
                                hint: '•••••••••',
                                prefixIcon: const Icon(
                                  Icons.lock_rounded,
                                  color: _goldIcon,
                                  size: 21,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _goldIcon,
                                    size: 21,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              onSubmitted: (_) {
                                if (!_isLoading) _login();
                              },
                            ),
                            const SizedBox(height: 26),

                            // Pill Navy & Gold Login Button
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: _goldPrimary,
                                  width: 1.4,
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.navyRoyal172c54,
                                    AppColors.navyHeader,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _darkNavy.withValues(alpha: 0.28),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isLoading ? null : _login,
                                  borderRadius: BorderRadius.circular(28),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.3,
                                              color: _goldButtonText,
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w700,
                                              color: _goldButtonText,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

class _LoginMandalaMedallionPainter extends CustomPainter {
  const _LoginMandalaMedallionPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    final strokeGold = Paint()
      ..color = AppColors.crimsonAlertB88e35
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..isAntiAlias = true;

    final fillSoftGold = Paint()
      ..color = AppColors.goldWarmBorder.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Outer 16 lotus petals
    const int petalCount = 16;
    final double baseR = outerRadius * 0.74;
    final double tipR = outerRadius * 0.97;
    final double dAngle = (2 * math.pi) / petalCount;

    for (int i = 0; i < petalCount; i++) {
      final double a = i * dAngle;
      final double aLeft = a - dAngle * 0.45;
      final double aRight = a + dAngle * 0.45;

      final pStart = Offset(
        center.dx + baseR * math.cos(aLeft),
        center.dy + baseR * math.sin(aLeft),
      );
      final pEnd = Offset(
        center.dx + baseR * math.cos(aRight),
        center.dy + baseR * math.sin(aRight),
      );
      final pTip = Offset(
        center.dx + tipR * math.cos(a),
        center.dy + tipR * math.sin(a),
      );
      final ctrlLeft = Offset(
        center.dx + (tipR * 0.96) * math.cos(a - dAngle * 0.22),
        center.dy + (tipR * 0.96) * math.sin(a - dAngle * 0.22),
      );
      final ctrlRight = Offset(
        center.dx + (tipR * 0.96) * math.cos(a + dAngle * 0.22),
        center.dy + (tipR * 0.96) * math.sin(a + dAngle * 0.22),
      );

      final path = Path()
        ..moveTo(pStart.dx, pStart.dy)
        ..quadraticBezierTo(ctrlLeft.dx, ctrlLeft.dy, pTip.dx, pTip.dy)
        ..quadraticBezierTo(ctrlRight.dx, ctrlRight.dy, pEnd.dx, pEnd.dy)
        ..close();

      canvas.drawPath(path, fillSoftGold);
      canvas.drawPath(path, strokeGold);
    }

    // 2. Concentric gold rings
    canvas.drawCircle(center, outerRadius * 0.75, strokeGold);
    canvas.drawCircle(
      center,
      outerRadius * 0.65,
      Paint()
        ..color = AppColors.creamWarmLightFdf8eb
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      outerRadius * 0.65,
      Paint()
        ..color = AppColors.goldIconTint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // 3. Beaded ring between 0.65 and 0.75
    final beadPaint = Paint()
      ..color = AppColors.crimsonAlertB88e35
      ..style = PaintingStyle.fill;
    const int beadCount = 24;
    final double beadOrbit = outerRadius * 0.70;
    for (int i = 0; i < beadCount; i++) {
      final double a = (i * 2 * math.pi) / beadCount;
      canvas.drawCircle(
        Offset(
          center.dx + beadOrbit * math.cos(a),
          center.dy + beadOrbit * math.sin(a),
        ),
        1.4,
        beadPaint,
      );
    }

    // 4. Inner fine ring
    canvas.drawCircle(
      center,
      outerRadius * 0.59,
      Paint()
        ..color = AppColors.goldBorder.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginCornerLotusOrnament extends StatelessWidget {
  final double angle;

  const _LoginCornerLotusOrnament({required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: const Size(24, 24),
        painter: const _CornerLotusPainter(),
      ),
    );
  }
}

class _CornerLotusPainter extends CustomPainter {
  const _CornerLotusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.crimsonAlertCfa84e.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = AppColors.goldWarmBorder.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final cx = size.width / 2;
    final base = Offset(cx, size.height * 0.78);

    // Center petal
    final centerPetal = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(cx - 5, size.height * 0.42, cx, size.height * 0.14)
      ..quadraticBezierTo(cx + 5, size.height * 0.42, base.dx, base.dy);
    canvas.drawPath(centerPetal, fill);
    canvas.drawPath(centerPetal, stroke);

    // Left petal
    final leftPetal = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        cx - 9,
        size.height * 0.58,
        cx - 8,
        size.height * 0.30,
      )
      ..quadraticBezierTo(
        cx - 3,
        size.height * 0.48,
        base.dx,
        base.dy,
      );
    canvas.drawPath(leftPetal, fill);
    canvas.drawPath(leftPetal, stroke);

    // Right petal
    final rightPetal = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        cx + 9,
        size.height * 0.58,
        cx + 8,
        size.height * 0.30,
      )
      ..quadraticBezierTo(
        cx + 3,
        size.height * 0.48,
        base.dx,
        base.dy,
      );
    canvas.drawPath(rightPetal, fill);
    canvas.drawPath(rightPetal, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
