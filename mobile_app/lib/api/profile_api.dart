import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:Care_AI/config/api_config.dart';
import 'auth_storage.dart';
import 'api_exception.dart';

class ProfileApi {
  static String get _baseUrl => ApiConfig.baseUrl;

  /* =========================
     HEADER AUTH
  ========================= */
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Chưa đăng nhập');
    }
    return {
      "Authorization": "Bearer $token",
    };
  }

  /* =========================
     UPDATE PROFILE
  ========================= */
  static Future<void> updateProfile({
    required String nguoiDungId,
    required String tenND,
    required String ngaySinh,
    required int gioiTinh,
    required double chieuCao,
    required double canNang,
    String? email,
    String? diaChi,
    File? avatarFile,
  }) async {
    final headers = await _authHeaders();
    final req = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl/profile/$nguoiDungId'),
    );

    req.headers.addAll(headers);

    // ===== fields =====
    req.fields.addAll({
      'nguoiDungId': nguoiDungId,
      'tenND': tenND,
      'ngaySinh': ngaySinh,
      'gioiTinh': gioiTinh.toString(),
      'chieuCao': chieuCao.toString(),
      'canNang': canNang.toString(),
      if (email != null) 'email': email,
      if (diaChi != null) 'diaChi': diaChi,
    });

    // ===== avatar =====
    if (avatarFile != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          avatarFile.path,
        ),
      );
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();

    print("UPDATE STATUS: ${res.statusCode}");
    print("UPDATE BODY: $body");

    if (body.isEmpty) {
      throw ApiException("Server không phản hồi");
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(jsonEncode({
        "message": data['message'] ?? "Cập nhật thất bại",
        "errors": data['errors']
      }));
    }
  }

  /* =========================
     GET PROFILE
  ========================= */
  static Future<Map<String, dynamic>?> getProfile(String nguoiDungId) async {
    try {
      final headers = await _authHeaders();
      final res = await http
          .get(
            Uri.parse('$_baseUrl/profile/$nguoiDungId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print("GET PROFILE STATUS: ${res.statusCode}");
      print("GET PROFILE BODY: ${res.body}");

      if (res.statusCode == 404) return null;
      if (res.body.isEmpty) return null;

      final body = jsonDecode(res.body);

      if (res.statusCode != 200 || body['success'] != true) {
        return null;
      }

      final raw = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : null;

      if (raw == null) return null;

      return {
        'nguoiDungId': raw['nguoiDungId'] ?? raw['nguoidung_id'],
        'tenND': raw['tenND'] ?? raw['tennd'],
        'ngaySinh': raw['ngaySinh'] ?? raw['ngaysinh'],
        'gioiTinh': (() {
          final gt = raw['gioiTinh'] ?? raw['gioitinh'];
          if (gt == null) return null;
          if (gt is bool) return gt ? 1 : 0;
          if (gt is num) return gt.toInt();
          final s = gt.toString().trim().toLowerCase();
          if (s == '1' || s == 'true') return 1;
          if (s == '0' || s == 'false') return 0;
          return null;
        })(),
        'chieuCao': ((raw['chieuCao'] ?? raw['chieucao']) as num?)?.toDouble(),
        'canNang': ((raw['canNang'] ?? raw['cannang']) as num?)?.toDouble(),
        'email': raw['email'],
        'diaChi': raw['diaChi'] ?? raw['diachi'],
        'avatarUrl': raw['avatarUrl'] ?? raw['avatarurl'],
        'soDienThoai': raw['soDienThoai'] ?? raw['sodienthoai'],
        'ngayTao': raw['ngayTao'] ?? raw['ngaytao'],
      };
    } catch (e) {
      print("GET PROFILE ERROR: $e");
      throw e;
    }
  }
}
