import 'package:shri_nrityalaya_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;
  final Key? scaffoldKey;

  const AppScaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.creamWarmLightFdf5e6,
        image: DecorationImage(
          image: AssetImage('assets/images/temple_bg.jpg'),
          fit: BoxFit.fitHeight,
          opacity: 0.9,
        ),
      ),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: Column(
          children: [
            Expanded(
              child: body ?? const SizedBox.shrink(),
            ),
            if (bottomNavigationBar != null)
              const SizedBox(height: 80), // Add spacing only when bottom nav is present
          ],
        ),
        drawer: drawer,
        floatingActionButton: floatingActionButton,
        extendBodyBehindAppBar: extendBodyBehindAppBar,

        // Keep the temple background visible behind the bottom navigation.
        extendBody: true,

        bottomNavigationBar: bottomNavigationBar == null
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: bottomNavigationBar,
                ),
              ),
      ),
    );
  }
}