import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import '../config/api_config.dart';
import 'api_exception.dart';

class SettingsApi {
  static String get _baseUrl => "${ApiConfig.baseUrl}/api/settings";
  static String get _authBaseUrl => "${ApiConfig.baseUrl}/auth";

  // 🔹 GET settings (KHÔNG cần userId)
  static Future<Map<String, dynamic>> getSettings() async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw ApiException("Chưa đăng nhập");
    }

    final res = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    ).timeout(const Duration(seconds: 20));

    print("GET SETTINGS STATUS: ${res.statusCode}");
    print("GET SETTINGS BODY: ${res.body}");

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data["volume"] != null) {
        data["volume"] = (data["volume"] as num).toDouble();
      }

      return data["data"];
    }

    throw ApiException("Không load được settings (${res.statusCode})");
  }

  // 🔹 UPDATE setting
  static Future<void> updateSetting(String key, dynamic value) async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw ApiException("Chưa đăng nhập");
    }

    final res = await http
        .put(
          Uri.parse(_baseUrl),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "key": key,
            "value": value,
          }),
        )
        .timeout(const Duration(seconds: 20));
    print("UPDATE SETTING STATUS: ${res.statusCode}");
    print("UPDATE SETTING BODY: ${res.body}");

    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data["success"] != true) {
      throw ApiException("Không load được settings");
    }

    return data["data"];
  }

  // 🔹 UPDATE FCM TOKEN (KHÔNG cần userId)
  static Future<void> updateFcmToken(String fcmToken) async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw ApiException("Chưa đăng nhập");
    }

    final res = await http
        .post(
          Uri.parse("$_authBaseUrl/save-fcm-token"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: jsonEncode({
            "fcmToken": fcmToken,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw ApiException("Lưu FCM token thất bại (${res.statusCode})");
    }
  }
}
