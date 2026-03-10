import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class SettingsApi {
  static const String _baseUrl = 'http://10.0.2.2:3000/api/settings';
  static const String _authBaseUrl = 'http://10.0.2.2:3000/auth';

  // 🔹 GET settings (KHÔNG cần userId)
  static Future<Map<String, dynamic>> getSettings() async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw Exception("Chưa đăng nhập");
    }

    final res = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    ).timeout(const Duration(seconds: 8));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data["volume"] != null) {
        data["volume"] = (data["volume"] as num).toDouble();
      }

      return data;
    }

    throw Exception("Không load được settings (${res.statusCode})");
  }

  // 🔹 UPDATE setting
  static Future<void> updateSetting(String key, dynamic value) async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw Exception("Chưa đăng nhập");
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
        .timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) {
      throw Exception("Update setting thất bại (${res.statusCode})");
    }
  }

  // 🔹 UPDATE FCM TOKEN (KHÔNG cần userId)
  static Future<void> updateFcmToken(String fcmToken) async {
    final token = await AuthStorage.getToken();

    if (token == null) {
      throw Exception("Chưa đăng nhập");
    }

    final res = await http.post(
      Uri.parse("$_authBaseUrl/save-fcm-token"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fcmToken": fcmToken,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Lưu FCM token thất bại (${res.statusCode})");
    }
  }
}
