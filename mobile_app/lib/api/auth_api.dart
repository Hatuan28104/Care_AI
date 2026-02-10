import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_storage.dart';
import '../models/login_history_item.dart';
import '../app_settings.dart';

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

      final user = User.fromJson(data['user']);

      AppSettings.phoneNumber.value = user.soDienThoai ?? '';

      return user;
    } else {
      throw Exception(data['message'] ?? 'OTP không hợp lệ');
    }
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Chưa đăng nhập');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<void> changePhone(String phone) async {
    final headers = await _authHeaders();

    final res = await http.post(
      Uri.parse('$baseUrl/auth/change-phone'),
      headers: headers,
      body: jsonEncode({'phone': phone}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Không thể đổi số điện thoại');
    }
  }

  // 🔥 THÊM DƯỚI changePhone()
  static Future<List<LoginHistoryItem>> getLoginHistory() async {
    final headers = await _authHeaders();

    final res = await http.get(
      Uri.parse('$baseUrl/auth/login-history'),
      headers: headers,
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Không lấy được lịch sử đăng nhập');
    }

    final List list = data['data'] is List ? data['data'] : [];

    return list.map((e) {
      return LoginHistoryItem(
        device: e['ThietBi'] ?? 'Unknown device',
        location: _mapIpToLocation(e['IP']),
        time:
            DateTime.parse(e['ThoiGian']).toLocal().toString().substring(0, 16),
      );
    }).toList();
  }

  static String _mapIpToLocation(String? ip) {
    if (ip == null || ip.isEmpty) return 'Không xác định';
    return 'Việt Nam'; // demo, sau map tỉnh
  }
}
