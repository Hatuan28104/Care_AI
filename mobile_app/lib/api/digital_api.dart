import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';

class DigitalApi {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/digital-human";

  static Map<String, dynamic> _normalizeDigital(Map<String, dynamic> raw) {
    return {
      ...raw,
      "digitalhuman_id":
          (raw["digitalhuman_id"] ?? raw["DigitalHuman_ID"] ?? "").toString(),
      "tendigitalhuman":
          (raw["tendigitalhuman"] ?? raw["TenDigitalHuman"] ?? "").toString(),
      "imageurl": (raw["imageurl"] ?? raw["ImageUrl"] ?? "").toString(),
    };
  }

  static Future<List<dynamic>> getAll() async {
    try {
      final res = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 20));

      if (res.body.isEmpty) {
        throw ApiException("Server không phản hồi");
      }

      Map<String, dynamic> json;
      try {
        json = jsonDecode(res.body);
      } catch (_) {
        throw ApiException("Dữ liệu trả về không hợp lệ");
      }

      if (res.statusCode != 200 || json["success"] != true) {
        throw ApiException(
          (json["message"] ?? "Không tải được Digital Humans").toString(),
          statusCode: res.statusCode,
        );
      }

      final list = json["data"] is List ? json["data"] as List : <dynamic>[];

      return list.map((e) {
        if (e is Map<String, dynamic>) return _normalizeDigital(e);
        if (e is Map) return _normalizeDigital(Map<String, dynamic>.from(e));
        return {
          "digitalhuman_id": "",
          "tendigitalhuman": "",
          "imageurl": "",
        };
      }).toList();
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Không thể kết nối máy chủ");
    }
  }
}
