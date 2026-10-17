import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/version/app_update_service.dart';
import 'firebase_options.dart';

export 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Always start update listener regardless of whether Firebase was newly initialized or existed
  try {
    AppUpdateService.instance.initializeRealtimeListener();
  } catch (e) {
    debugPrint('AppUpdateService listener init notice: $e');
  }

  runApp(
    const ProviderScope(
      child: ShriNrityalayaApp(),
    ),
  );
}
