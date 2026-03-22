import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kDebugMode) {
      return "https://careai-production.up.railway.app";
    } else {
      return "https://careai-production.up.railway.app";
    }
  }
}
