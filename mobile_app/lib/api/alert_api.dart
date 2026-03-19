import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AlertApi {
  static String get baseUrl => "${ApiConfig.baseUrl}/notification";

  /* ================= GET ALERT ================= */

  static Future<List<dynamic>> getAlerts(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/user/$userId"))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);

      if (data is List) {
        return data;
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> markAsRead(String id, String userId) async {
    await http.post(
      Uri.parse('$baseUrl/read/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );
  }

  static Future<void> deleteAlert(String id, String userId) async {
    await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId}),
    );
  }
}
