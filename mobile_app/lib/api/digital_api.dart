import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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
    final response = await http.get(Uri.parse(baseUrl));

    print("===== DIGITAL API RESPONSE =====");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = json["data"] is List ? json["data"] as List : <dynamic>[];
      return list.map((e) {
        if (e is Map<String, dynamic>) return _normalizeDigital(e);
        if (e is Map) return _normalizeDigital(Map<String, dynamic>.from(e));
        return <String, dynamic>{
          "digitalhuman_id": "",
          "tendigitalhuman": "",
          "imageurl": "",
        };
      }).toList();
    } else {
      throw Exception("Không tải được Digital Humans");
    }
  }
}
