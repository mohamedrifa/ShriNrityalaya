import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'environment.dart';

class AppConfig {
  static const String appName = 'Shri Nrityalaya';
  static const String appSubtitle = 'Academy Management System';
  static const String appVersion = '1.0.0+1';

  static String get apiBaseUrl {
    return dotenv.env['API_BASE_URL'] ??
        Environment.current.defaultBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);
}
