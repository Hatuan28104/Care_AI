import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';

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
    final Map<String, dynamic> body = {
      "message": message.trim(),
      "userId": userId,
      "digitalId": digitalId,
    };

    if (hoiThoaiId != null && hoiThoaiId.isNotEmpty) {
      body["hoiThoaiId"] = hoiThoaiId;
    }

    try {
      final res = await http
          .post(
            Uri.parse(baseUrl),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
      final decoded = _decodeBody(res.body);
      if (res.statusCode != 200 || decoded["success"] != true) {
        throw ApiException(
          (decoded["message"] ?? "Gửi tin nhắn thất bại").toString(),
          statusCode: res.statusCode,
        );
      }

      return {
        "reply": (decoded["reply"] ?? "").toString(),
        "hoi_thoai_id": (decoded["hoiThoaiId"] ?? "").toString(),
        "muc_do": decoded["mucDo"] ?? 0,
        "canh_bao": decoded["canhBao"] == true,
      };
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Không thể kết nối máy chủ");
    }
  }

  /* =========================
      GET HISTORY
  ========================= */

  static Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/history/$userId"))
          .timeout(const Duration(seconds: 15));
      final decoded = _decodeBody(res.body);
      if (res.statusCode != 200 || decoded["success"] != true) {
        throw ApiException(
          (decoded["message"] ?? "Không lấy được lịch sử chat").toString(),
          statusCode: res.statusCode,
        );
      }

      final list =
          decoded["data"] is List ? decoded["data"] as List : <dynamic>[];
      return list.map((item) {
        final row = item is Map<String, dynamic>
            ? item
            : (item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{});
        final digital = row["digitalhuman"] is Map<String, dynamic>
            ? row["digitalhuman"] as Map<String, dynamic>
            : <String, dynamic>{};
        final job = digital["nghenghiep"] is Map<String, dynamic>
            ? digital["nghenghiep"] as Map<String, dynamic>
            : <String, dynamic>{};

        return <String, dynamic>{
          "hoithoai_id": row["hoithoai_id"]?.toString() ?? "",
          "lancuoituongtac": row["lancuoituongtac"]?.toString() ?? "",
          "digitalhuman_id": digital["digitalhuman_id"]?.toString() ?? "",
          "tendigitalhuman": digital["tendigitalhuman"]?.toString() ?? "",
          "imageurl": digital["imageurl"]?.toString() ?? "",
          "tennghenghiep": job["tennghenghiep"]?.toString() ?? "",
        };
      }).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Không thể kết nối máy chủ");
    }
  }

  /* =========================
      GET MESSAGES
  ========================= */

  static Future<List<Map<String, dynamic>>> getMessages(
      String hoiThoaiId) async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/messages/$hoiThoaiId"))
          .timeout(const Duration(seconds: 15));
      final decoded = _decodeBody(res.body);
      if (res.statusCode != 200 || decoded["success"] != true) {
        throw ApiException(
          (decoded["message"] ?? "Không lấy được tin nhắn").toString(),
          statusCode: res.statusCode,
        );
      }

      final list =
          decoded["data"] is List ? decoded["data"] as List : <dynamic>[];
      return list.map((item) {
        final row = item is Map<String, dynamic>
            ? item
            : (item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{});
        return <String, dynamic>{
          "noidung": row["noidung"]?.toString() ?? "",
          "ladigital": row["ladigital"] == true,
          "thoigiangui": row["thoigiangui"]?.toString() ?? "",
        };
      }).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Không thể kết nối máy chủ");
    }
  }

  /* =========================
      DELETE CONVERSATION
  ========================= */

  static Future<void> deleteConversation(String hoiThoaiId) async {
    try {
      final res = await http
          .delete(
            Uri.parse("$baseUrl/conversation/$hoiThoaiId"),
          )
          .timeout(const Duration(seconds: 15));
      final decoded = _decodeBody(res.body);
      if (res.statusCode != 200 || decoded["success"] != true) {
        throw ApiException(
          (decoded["message"] ?? "Xóa hội thoại thất bại").toString(),
          statusCode: res.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Không thể kết nối máy chủ");
    }
  }

  static Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{"message": "Dữ liệu trả về không hợp lệ"};
    } catch (_) {
      return {"success": false, "message": "Dữ liệu trả về không hợp lệ"};
    }
  }
}
