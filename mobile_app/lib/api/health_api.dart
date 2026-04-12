import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';
import 'package:Care_AI/config/api_config.dart';
import 'api_exception.dart';

class HealthApi {
  static String get _baseUrl => ApiConfig.baseUrl;

  static Map<String, dynamic> _normalizePhanTichAi(Map<String, dynamic> raw) {
    final fallbackTime = DateTime.now().toIso8601String();
    final sosanhRaw = raw["sosanh"];

    return {
      "trangthai": (raw["trangthai"] ?? "unknown").toString(),
      "thongdiep": (raw["thongdiep"] ?? "").toString(),
      "loikhuyen": (raw["loikhuyen"] ?? "").toString(),
      "sosanh": sosanhRaw is Map
          ? Map<String, dynamic>.from(sosanhRaw)
          : <String, dynamic>{},
      "thoigian": (raw["thoigian"] ?? fallbackTime).toString(),
    };
  }

  /* =========================
     AUTH HEADER
  ========================= */
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException("Chưa đăng nhập");
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /* =========================
     PARSE RESPONSE (ANTI HTML + SAFE JSON)
  ========================= */
  static Map<String, dynamic> _decodeBody(String body) {
    final text = body.trim();

    if (text.isEmpty) {
      throw ApiException("Server không phản hồi");
    }

    if (text.startsWith('<')) {
      throw ApiException("Server trả về HTML (sai URL hoặc backend lỗi)");
    }

    try {
      final decoded = jsonDecode(text);
      return decoded is Map<String, dynamic>
          ? decoded
          : {"success": false, "message": "Dữ liệu không hợp lệ"};
    } catch (_) {
      throw ApiException("Response không phải JSON");
    }
  }

  /* =========================
     NORMALIZE
  ========================= */
  static Map<String, dynamic> _normalizeMetric(Map<String, dynamic> raw) {
    return {
      "loaichiso_id": (raw["loaichiso_id"] ?? "").toString(),
      "tenchiso": (raw["tenchiso"] ?? "").toString(),
      "donvido": (raw["donvido"] ?? "").toString(),
      "loai": (raw["loai"] ?? "").toString(),
      "code": (raw["code"] ?? "").toString(),
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
      "nguondulieu_id": (raw["nguondulieu_id"] ?? "").toString(),
    };
  }

  /* =========================
     METRICS
  ========================= */
  static Future<List<dynamic>> getMetrics() async {
    final res = await http
        .get(Uri.parse('$_baseUrl/health/metrics'),
            headers: await _authHeaders())
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi lấy metrics",
          statusCode: res.statusCode);
    }

    final list = data['data'] as List? ?? [];

    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeMetric(e);
      if (e is Map) return _normalizeMetric(Map<String, dynamic>.from(e));
      return {};
    }).toList();
  }

  static Future<void> createMetric({
    required String loaiChiSoId,
    required String tenChiSo,
    required String donViDo,
    required String category,
  }) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/health/metrics'),
          headers: await _authHeaders(),
          body: jsonEncode({
            'loaichiso_id': loaiChiSoId,
            'tenchiso': tenChiSo,
            'donvido': donViDo,
            'category': category,
          }),
        )
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi tạo metric",
          statusCode: res.statusCode);
    }
  }

  /* =========================
     DEVICE
  ========================= */
  static Future<String> getOrCreateDevice() async {
    final res = await http
        .post(Uri.parse('$_baseUrl/health/device/ensure'),
            headers: await _authHeaders())
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi device",
          statusCode: res.statusCode);
    }

    return data['data']['nguondulieu_id'].toString();
  }

  /* =========================
     SAVE DATA
  ========================= */
  static Future<void> saveHealthData({
    required double giaTri,
    String? nguondulieuId,
    required String loaiChiSoId,
  }) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/health/data'),
          headers: await _authHeaders(),
          body: jsonEncode({
            'giatri': giaTri,
            'loaichiso_id': loaiChiSoId,
            if (nguondulieuId != null && nguondulieuId.isNotEmpty)
              'nguondulieu_id': nguondulieuId,
          }),
        )
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi lưu data",
          statusCode: res.statusCode);
    }
  }

/* =========================
   SAVE MULTIPLE DATA (NEW)
========================= */
  static Future<void> saveMultipleHealthData(
    Map<String, dynamic> payload,
  ) async {
    final headers = await _authHeaders();

    final res = await http
        .post(
          Uri.parse('$_baseUrl/health/data'),
          headers: headers,
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(
        data['message'] ?? "Lỗi lưu multi data",
        statusCode: res.statusCode,
      );
    }
  }

  /* =========================
     LATEST
  ========================= */
  static Future<List<dynamic>> getLatestHealthDataByDevice(
      String deviceId) async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl/health/data/latest/device/$deviceId'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi latest device",
          statusCode: res.statusCode);
    }

    final list = data['data'] as List? ?? [];

    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeHealthData(e);
      if (e is Map) return _normalizeHealthData(Map<String, dynamic>.from(e));
      return {};
    }).toList();
  }

  static Future<List<dynamic>> getLatestHealthDataByUser() async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl/health/data/latest/user'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi latest user",
          statusCode: res.statusCode);
    }

    final list = data['data'] as List? ?? [];

    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeHealthData(e);
      if (e is Map) return _normalizeHealthData(Map<String, dynamic>.from(e));
      return {};
    }).toList();
  }

  /* =========================
     HISTORY
  ========================= */
  static Future<List<dynamic>> getHealthHistory(
    String deviceId,
    String metricId,
    String range,
  ) async {
    final res = await http
        .get(
          Uri.parse(
              '$_baseUrl/health/history/$deviceId/$metricId?range=$range'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi history",
          statusCode: res.statusCode);
    }

    final list = data['data'] as List? ?? [];

    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeHealthData(e);
      if (e is Map) return _normalizeHealthData(Map<String, dynamic>.from(e));
      return {};
    }).toList();
  }

  static Future<List<dynamic>> getHealthHistoryByUser(String metricId,
      [String range = 'd']) async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl/health/history/user/$metricId?range=$range'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 8));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi history user",
          statusCode: res.statusCode);
    }

    final list = data['data'] as List? ?? [];

    return list.map((e) {
      if (e is Map<String, dynamic>) return _normalizeHealthData(e);
      if (e is Map) return _normalizeHealthData(Map<String, dynamic>.from(e));
      return {};
    }).toList();
  }

  static Future<Map<String, dynamic>> getLatestPhanTichAi() async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl/health/ai-insight/latest'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 8));

    final decoded = _decodeBody(res.body);

    if (res.statusCode != 200 || decoded['success'] != true) {
      throw ApiException(decoded['message'] ?? "Lỗi lấy phân tích AI",
          statusCode: res.statusCode);
    }

    final rawData = decoded['data'];
    if (rawData is Map<String, dynamic>) {
      return _normalizePhanTichAi(rawData);
    }
    if (rawData is Map) {
      return _normalizePhanTichAi(Map<String, dynamic>.from(rawData));
    }

    return _normalizePhanTichAi(const <String, dynamic>{});
  }

  static Future<Map<String, dynamic>> analyzeStressByDevice(String deviceId) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/health/analyze-stress/$deviceId'),
          headers: await _authHeaders(),
        )
        .timeout(const Duration(seconds: 15));

    final data = _decodeBody(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? "Lỗi phân tích stress",
          statusCode: res.statusCode);
    }

    final raw = data['data'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }
}
