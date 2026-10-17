import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.creamWarmLightFdf5e6, // Light cream
        image: DecorationImage(
          image: AssetImage('assets/images/temple_bg.jpg'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: child,
    );
  }
}
