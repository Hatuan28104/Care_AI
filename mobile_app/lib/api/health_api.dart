import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'api_exception.dart';

class HealthApi {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Map<String, dynamic> _normalizeMetric(Map<String, dynamic> raw) {
    return {
      "loaichiso_id": (raw["loaichiso_id"] ?? "").toString(),
      "tenchiso": (raw["tenchiso"] ?? "").toString(),
      "donvido": (raw["donvido"] ?? "").toString(),
      "loai": (raw["loai"] ?? "").toString(),
    };
  }

  static Map<String, dynamic> _normalizeHealthData(Map<String, dynamic> raw) {
    final metricRaw = raw["loaichisosuckhoe"];
    final metric = metricRaw is Map<String, dynamic>
        ? metricRaw
        : (metricRaw is Map ? Map<String, dynamic>.from(metricRaw) : {});
    return {
      "giatri": raw["giatri"],
      "thoigiancapnhat": (raw["thoigiancapnhat"] ?? "").toString(),
      "tenchiso": (metric["tenchiso"] ?? raw["tenchiso"] ?? "").toString(),
      "donvido": (metric["donvido"] ?? raw["donvido"] ?? "").toString(),
      "loaichiso_id":
          (metric["loaichiso_id"] ?? raw["loaichiso_id"] ?? "").toString(),
    };
  }

  /* =========================
     DANH SÁCH CHỈ SỐ SỨC KHỎE
  ========================= */
  static Future<List<dynamic>> getMetrics() async {
    final url = Uri.parse('$_baseUrl/health/metrics');

    final response = await http.get(url).timeout(const Duration(seconds: 20));

    final data = _decodeBody(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(
        (data['message'] ?? 'Không lấy được danh sách chỉ số').toString(),
        statusCode: response.statusCode,
      );
    }

    final list = data['data'] is List ? data['data'] as List : <dynamic>[];
    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeMetric(e);
      if (e is Map) return _normalizeMetric(Map<String, dynamic>.from(e));
      return <String, dynamic>{};
    }).toList();
  }

  /* =========================
     THÊM CHỈ SỐ SỨC KHỎE
  ========================= */
  static Future<void> createMetric({
    required String loaiChiSoId,
    required String tenChiSo,
    required String donViDo,
    required String category,
  }) async {
    final url = Uri.parse('$_baseUrl/health/metrics');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'loaichiso_id': loaiChiSoId,
            'tenchiso': tenChiSo,
            'donvido': donViDo,
            'loai': category,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final data = _decodeBody(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(
        (data['message'] ?? 'Không thêm được chỉ số').toString(),
        statusCode: response.statusCode,
      );
    }
  }

  /* =========================
     LƯU DỮ LIỆU SỨC KHỎE
  ========================= */
  static Future<void> saveHealthData({
    required double giaTri,
    required String thietBiId,
    required String loaiChiSoId,
  }) async {
    final url = Uri.parse('$_baseUrl/health/data');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'giatri': giaTri,
            'thietbi_id': thietBiId,
            'loaichiso_id': loaiChiSoId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    final data = _decodeBody(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(
        (data['message'] ?? 'Không lưu được dữ liệu').toString(),
        statusCode: response.statusCode,
      );
    }
  }

  /* =========================
     DỮ LIỆU MỚI NHẤT
  ========================= */
  static Future<List<dynamic>> getLatestHealthData(String deviceId) async {
    final url = Uri.parse('$_baseUrl/health/data/latest/$deviceId');

    final response = await http.get(url).timeout(const Duration(seconds: 20));

    final data = _decodeBody(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(
        (data['message'] ?? 'Không lấy được dữ liệu mới nhất').toString(),
        statusCode: response.statusCode,
      );
    }

    final list = data['data'] is List ? data['data'] as List : <dynamic>[];
    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeHealthData(e);
      if (e is Map) return _normalizeHealthData(Map<String, dynamic>.from(e));
      return <String, dynamic>{};
    }).toList();
  }

  /* =========================
     LỊCH SỬ CHỈ SỐ
  ========================= */
  static Future<List<dynamic>> getHealthHistory(
    String deviceId,
    String metricId,
    String range,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/health/history/$deviceId/$metricId?range=$range',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 20));
    final data = _decodeBody(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(
        (data['message'] ?? 'Không lấy được lịch sử dữ liệu').toString(),
        statusCode: response.statusCode,
      );
    }

    final list = data['data'] is List ? data['data'] as List : <dynamic>[];
    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeHealthData(e);
      if (e is Map) return _normalizeHealthData(Map<String, dynamic>.from(e));
      return <String, dynamic>{};
    }).toList();
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
