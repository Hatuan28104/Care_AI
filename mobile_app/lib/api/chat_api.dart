import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ChatApi {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/chat";

  static const headers = {
    "Content-Type": "application/json",
  };

  /* =========================
      SEND MESSAGE
  ========================= */

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String userId,
    required String digitalId,
    String? hoiThoaiId,
  }) async {
    try {
      final Map<String, dynamic> body = {
        "message": message.trim(),
        "userId": userId,
        "digitalId": digitalId,
      };

      /// chỉ gửi hoiThoaiId khi có giá trị
      if (hoiThoaiId != null && hoiThoaiId.isNotEmpty) {
        body["hoiThoaiId"] = hoiThoaiId;
      }

      final res = await http
          .post(
            Uri.parse(baseUrl),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        return {"success": false, "message": "Server error ${res.statusCode}"};
      }

      final data = jsonDecode(res.body);
      data["mucDo"] ??= 0;
      data["canhBao"] ??= false;
      return data;
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  /* =========================
      GET HISTORY
  ========================= */

  static Future<List<dynamic>> getHistory(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/history/$userId"))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        return data["data"];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /* =========================
      GET MESSAGES
  ========================= */

  static Future<List<dynamic>> getMessages(String hoiThoaiId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/messages/$hoiThoaiId"))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(res.body);

      if (data["success"] == true) {
        return data["data"];
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /* =========================
      DELETE CONVERSATION
  ========================= */

  static Future<bool> deleteConversation(String hoiThoaiId) async {
    try {
      final res = await http
          .delete(
            Uri.parse("$baseUrl/conversation/$hoiThoaiId"),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(res.body);

      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }
}
