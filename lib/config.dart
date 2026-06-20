import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    // APK / release → siempre Render
    if (kReleaseMode) return 'https://fundecodes-api.onrender.com';
    // Dev en Chrome
    if (kIsWeb) return 'http://localhost:3000';
    // Dev en emulador Android
    return 'http://10.0.2.2:3000';
  }
}
