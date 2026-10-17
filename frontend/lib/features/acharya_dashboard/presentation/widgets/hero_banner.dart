import 'package:flutter/material.dart';
import '../../theme/acharya_colors.dart';
import 'welcome_glass_card.dart';

class HeroBanner extends StatelessWidget {
  final String username;

  const HeroBanner({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 415,
      width: double.infinity,
      child: Stack(
        children: [
          // Layer 1: hero_floor_bg.png
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.12, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/hero_floor_bg.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Layer 2: Welcome Glass Card
          Positioned(
            left: 6,
            top: 20,
            width: 257, // ~66% of 390px
            height: 240,
            child: WelcomeGlassCard(username: username),
          ),

          // Layer 3: avatar_dancer_cutout.png
          Positioned(
            right: 0,
            bottom: 0,
            height: 415,
            child: Image.asset(
              'assets/images/avatar_dancer_cutout.png',
              fit: BoxFit.fitHeight,
              alignment: Alignment.bottomRight,
            ),
          ),

          // Bottom Gradient to blend into screenBackground
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AcharyaColors.screenBackground.withValues(alpha: 0.0),
                    AcharyaColors.screenBackground,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
