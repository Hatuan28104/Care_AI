import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Care_AI/config/api_config.dart';
import 'auth_storage.dart';
import 'api_exception.dart';

class AlertApi {
  static String get baseUrl => "${ApiConfig.baseUrl}/notification";

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Chưa đăng nhập', statusCode: 401);
    }
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  /* ================= GET ALERT ================= */

  static Future<List<Map<String, dynamic>>> getAlerts() async {
    try {
      final uri =
          Uri.parse("$baseUrl/user?t=${DateTime.now().millisecondsSinceEpoch}");
      final res = await http.get(
        uri,
        headers: {
          ...(await _authHeaders()),
          "Cache-Control": "no-cache",
          "Pragma": "no-cache",
        },
      ).timeout(const Duration(seconds: 8));
      final decoded = _decodeBody(res.body);
      if (res.statusCode != 200 || decoded["success"] != true) {
        throw ApiException(
          (decoded["message"] ?? "Không lấy được thông báo").toString(),
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
          "notification_id": row["notification_id"]?.toString() ?? "",
          "tieude": row["tieude"]?.toString() ?? "",
          "noidung": row["noidung"]?.toString() ?? "",
          "thoigian": row["thoigian"]?.toString() ?? "",
          "dadoc": row["dadoc"] == true,
          "type": row["type"]?.toString() ?? "ALERT",
        };
      }).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Không thể kết nối máy chủ");
    }
  }

  static Future<void> markAsRead(String id) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/read/$id'),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 8));
      final decoded = _decodeBody(res.body);
      if (res.statusCode != 200 || decoded["success"] != true) {
        throw ApiException(
          (decoded["message"] ?? "Đánh dấu đã đọc thất bại").toString(),
          statusCode: res.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Không thể kết nối máy chủ");
    }
  }

  static Future<void> deleteAlert(String id) async {
    try {
      final res = await http
          .delete(
            Uri.parse('$baseUrl/$id'),
            headers: await _authHeaders(),
          )
          .timeout(const Duration(seconds: 8));
      final decoded = _decodeBody(res.body);
      if (res.statusCode != 200 || decoded["success"] != true) {
        throw ApiException(
          (decoded["message"] ?? "Xóa thông báo thất bại").toString(),
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
