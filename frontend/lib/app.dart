import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

class ShriNrityalayaApp extends StatelessWidget {
  const ShriNrityalayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shri Nrityalaya',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
