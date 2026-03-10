import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApi {
  static const String baseUrl = "http://10.0.2.2:3000/api/chat";

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
      final body = {
        "message": message.trim(),
        "userId": userId,
        "digitalId": digitalId,
        if (hoiThoaiId != null) "hoiThoaiId": hoiThoaiId,
      };

      final res = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        return {"success": false, "message": "Server error ${res.statusCode}"};
      }

      final data = jsonDecode(res.body);

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
      final res = await http.get(
        Uri.parse("$baseUrl/history/$userId"),
      );

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
      final res = await http.get(
        Uri.parse("$baseUrl/messages/$hoiThoaiId"),
      );

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
      final res = await http.delete(
        Uri.parse("$baseUrl/conversation/$hoiThoaiId"),
      );

      if (res.statusCode != 200) {
        return false;
      }

      final data = jsonDecode(res.body);

      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }

  /* =========================
   RENAME CONVERSATION
========================= */

  static Future<bool> renameConversation(
      String hoiThoaiId, String title) async {
    try {
      final res = await http.put(
        Uri.parse("$baseUrl/conversation/rename"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "hoiThoaiId": hoiThoaiId,
          "title": title,
        }),
      );

      if (res.statusCode != 200) return false;

      final data = jsonDecode(res.body);

      return data["success"] == true;
    } catch (e) {
      return false;
    }
  }
}
