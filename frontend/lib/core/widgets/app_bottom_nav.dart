import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AppBottomNav extends ConsumerWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  static const Color _selectedText = AppColors.darkNavyText;
  static const Color _unselectedIcon = AppColors.slateUnselectedIcon;
  static const Color _unselectedText = AppColors.textMutedSlate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(2.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.crimsonDeepB38e46,
              AppColors.accentToneE0c480,
              AppColors.crimsonAlertC5a054,
              AppColors.accentToneDec17b,
              AppColors.crimsonDeepAd873e,
            ],
            stops: [0.0, 0.28, 0.52, 0.78, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.crimsonDeep8c6b28.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(36),
          ),
          child: Row(
            children: [
              _buildNavItem(
                context: context,
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_rounded,
                label: 'Home',
                onTap: () {
                  if (currentIndex == 0) return;

                  final userRole = authState.userRole;

                  if (userRole == 'Teacher' || userRole == 'SystemAdmin') {
                    context.go('/dashboard/teacher');
                  } else if (userRole == 'Student') {
                    context.go('/dashboard/student');
                  } else if (userRole == 'Parent') {
                    context.go('/dashboard/parent');
                  } else {
                    context.go('/dashboard/teacher');
                  }
                },
              ),
              _buildNavItem(
                context: context,
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.chrome_reader_mode_rounded,
                customIconBuilder: (color) => _OpenBookIcon(color: color),
                label: 'Lessons',
                onTap: () {
                  if (currentIndex != 1) {
                    context.go('/learning');
                  }
                },
              ),
              _buildNavItem(
                context: context,
                index: 2,
                currentIndex: currentIndex,
                icon: Icons.event_rounded,
                label: 'Events',
                onTap: () {
                  if (currentIndex != 2) {
                    context.go('/events');
                  }
                },
              ),
              _buildNavItem(
                context: context,
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () {
                  if (currentIndex != 3) {
                    context.go('/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    Widget Function(Color color)? customIconBuilder,
    required String label,
    required VoidCallback onTap,
  }) {
    final bool isSelected = currentIndex == index;

    final Widget rawIcon = customIconBuilder != null
        ? customIconBuilder(isSelected ? Colors.white : _unselectedIcon)
        : Icon(
            icon,
            size: 27,
            color: isSelected ? Colors.white : _unselectedIcon,
          );

    final Widget styledIcon = isSelected
        ? ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.navySlate1f2b3d,
                AppColors.navyRoyal3a4352,
                AppColors.crimsonDeep9c7b38,
              ],
              stops: [0.0, 0.48, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: rawIcon,
          )
        : rawIcon;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 28,
              child: Center(child: styledIcon),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w400,
                color: isSelected ? _selectedText : _unselectedText,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom open-book icon with a solid left page and outlined right page,
/// matching the Lessons icon in the reference template.
class _OpenBookIcon extends StatelessWidget {
  final Color color;
  const _OpenBookIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(25, 22),
      painter: _OpenBookPainter(color: color),
    );
  }
}

class _OpenBookPainter extends CustomPainter {
  final Color color;
  _OpenBookPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    final midX = size.width / 2;
    final topY = 2.0;
    final bottomY = size.height - 2.0;

    // Left filled page
    final leftPage = Path()
      ..moveTo(midX, topY + 1.5)
      ..quadraticBezierTo(midX * 0.5, topY - 1.0, 1.5, topY + 1.0)
      ..lineTo(1.5, bottomY - 1.0)
      ..quadraticBezierTo(midX * 0.5, bottomY - 2.5, midX, bottomY)
      ..close();
    canvas.drawPath(leftPage, fillPaint);
    canvas.drawPath(leftPage, strokePaint);

    // Right outlined page
    final rightPage = Path()
      ..moveTo(midX, topY + 1.5)
      ..quadraticBezierTo(
        midX + midX * 0.5,
        topY - 1.0,
        size.width - 1.5,
        topY + 1.0,
      )
      ..lineTo(size.width - 1.5, bottomY - 1.0)
      ..quadraticBezierTo(
        midX + midX * 0.5,
        bottomY - 2.5,
        midX,
        bottomY,
      )
      ..close();
    canvas.drawPath(rightPage, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _OpenBookPainter oldDelegate) =>
      oldDelegate.color != color;
}