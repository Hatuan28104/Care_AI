import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileApi {
  static const _baseUrl = 'http://10.0.2.2:3000';

  static Future<void> updateProfile({
    required String nguoiDungId,
    required String tenND,
    required String ngaySinh,
    int? gioiTinh,
    required double chieuCao,
    required double canNang,
    String? email,
    String? diaChi,
  }) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/profile/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nguoiDungId': nguoiDungId,
        'tenND': tenND,
        'ngaySinh': ngaySinh,
        'gioiTinh': gioiTinh,
        'chieuCao': chieuCao,
        'canNang': canNang,
        'email': email,
        'diaChi': diaChi,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      // ❗ PHẢI THROW CẢ JSON
      throw Exception(jsonEncode(data));
    }
  }
}
