import 'package:flutter/material.dart';

class TempleBackground extends StatelessWidget {
  final Widget child;

  const TempleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left Temple
        Positioned(
          left: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.35,
          child: Opacity(
            opacity: 0.6,
            child: Image.asset(
              'assets/images/temple_left.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomLeft,
            ),
          ),
        ),
        // Right Temple
        Positioned(
          right: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.35,
          child: Opacity(
            opacity: 0.6,
            child: Image.asset(
              'assets/images/temple_right.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomRight,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
