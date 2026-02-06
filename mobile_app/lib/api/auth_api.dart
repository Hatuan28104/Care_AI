import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_storage.dart';

class AuthApi {
  static const String baseUrl = 'http://10.0.2.2:3000';

  /* =========================
     REGISTER – GỬI OTP
  ========================= */
  static Future<void> requestRegisterOtp(String phone) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Không thể gửi OTP đăng ký');
    }
  }

  /* =========================
     LOGIN – GỬI OTP
  ========================= */
  static Future<void> requestLoginOtp(String phone) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login/request-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Không thể gửi OTP đăng nhập');
    }
  }

  /* =========================
     VERIFY OTP (CHUNG)
  ========================= */
  static Future<User> verifyOtp(String phone, String otp) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'otp': otp,
      }),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 && data['success'] == true) {
      final token = data['token']; // 🔥 LẤY TOKEN
      if (token == null || token.isEmpty) {
        throw Exception('Không nhận được token');
      }

      // 🔥🔥🔥 LƯU TOKEN
      await AuthStorage.saveToken(token);

      print('🔥 TOKEN FROM API = $token');
      await AuthStorage.saveToken(token);
      print('🔥 TOKEN SAVED = ${AuthStorage.token}');

      return User.fromJson(data['user']);
    } else {
      throw Exception(data['message'] ?? 'OTP không hợp lệ');
    }
  }
}
