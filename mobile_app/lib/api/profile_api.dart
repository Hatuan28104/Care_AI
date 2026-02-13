import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class ProfileApi {
  static const _baseUrl = 'http://10.0.2.2:3000';

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
    final req = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl/profile/update'),
    );

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

    if (body.isEmpty) {
      throw Exception(jsonEncode({
        "message": "Server không phản hồi",
      }));
    }

    final data = jsonDecode(body);

    // 🔥 QUAN TRỌNG: throw full message + errors
    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(jsonEncode({
        "message": data['message'] ?? "Cập nhật thất bại",
        "errors": data['errors']
      }));
    }
    print("STATUS: ${res.statusCode}");
    print("BODY: $body");
  }

  /* =========================
     GET PROFILE
  ========================= */
  static Future<Map<String, dynamic>?> getProfile(String nguoiDungId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/profile/$nguoiDungId'),
      );

      if (res.statusCode == 404) return null;
      if (res.body.isEmpty) return null;

      final body = jsonDecode(res.body);

      if (res.statusCode != 200 || body['success'] != true) {
        return null;
      }

      final raw = body['data'];

      return {
        'nguoiDungId': raw['NguoiDung_ID'],
        'tenND': raw['TenND'],
        'ngaySinh': raw['NgaySinh'],
        'gioiTinh': raw['GioiTinh'] == 1 || raw['GioiTinh'] == true ? 1 : 0,
        'chieuCao': (raw['ChieuCao'] as num?)?.toDouble(),
        'canNang': (raw['CanNang'] as num?)?.toDouble(),
        'email': raw['Email'],
        'diaChi': raw['DiaChi'],
        'avatarUrl': raw['AvatarUrl'],
      };
    } catch (e) {
      return null;
    }
  }
}
