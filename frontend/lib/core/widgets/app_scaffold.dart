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
        color: Color(0xFFFDF5E6), // Light cream
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
        body: body,
        drawer: drawer,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}
