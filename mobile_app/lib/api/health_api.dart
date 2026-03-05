import 'dart:convert';
import 'package:http/http.dart' as http;

class HealthApi {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  /* =========================
     DANH SÁCH CHỈ SỐ SỨC KHỎE
  ========================= */
  static Future<List<dynamic>> getMetrics() async {
    final url = Uri.parse('$_baseUrl/health/metrics');

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception('Không lấy được danh sách chỉ số');
    }

    return data['data'];
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

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'LoaiChiSo_ID': loaiChiSoId,
        'TenChiSo': tenChiSo,
        'DonViDo': donViDo,
        'Category': category,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Không thêm được chỉ số');
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

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'GiaTri': giaTri,
        'ThietBi_ID': thietBiId,
        'LoaiChiSo_ID': loaiChiSoId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Không lưu được dữ liệu');
    }
  }

  /* =========================
     DỮ LIỆU MỚI NHẤT
  ========================= */
  static Future<List<dynamic>> getLatestHealthData(String deviceId) async {
    final url = Uri.parse('$_baseUrl/health/data/latest/$deviceId');

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception('Không lấy được dữ liệu mới nhất');
    }

    return data['data'];
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

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception('Không lấy được lịch sử dữ liệu');
    }

    return data['data'];
  }
}
