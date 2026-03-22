import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      if (kIsWeb) {
        return "http://localhost:3000";
      } else if (Platform.isAndroid) {
        return "http://10.0.2.2:3000";
      } else {
        return "http://localhost:3000";
      }
    } else {
      return "https://care-ai-fb8q.onrender.com";
    }
  }
}
