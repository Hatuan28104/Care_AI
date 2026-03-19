import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_storage.dart';
import '../models/login_history_item.dart';
import '../app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/api_config.dart';

class AuthApi {
  static String get baseUrl => ApiConfig.baseUrl;

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
      final token = data['token'];
      if (token == null || token.isEmpty) {
        throw Exception('Không nhận được token');
      }

      await AuthStorage.saveToken(token);

      final user = User.fromJson(data['user']);

      AppSettings.phoneNumber.value = user.soDienThoai ?? '';

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? fcmToken = await messaging.getToken();

      if (fcmToken != null) {
        await _sendFcmTokenToServer(fcmToken);
      }

      return user;
    } else {
      throw Exception(data['message'] ?? 'OTP không hợp lệ');
    }
  }

  static Future<void> _sendFcmTokenToServer(String fcmToken) async {
    final headers = await _authHeaders();

    final res = await http.post(
      Uri.parse('$baseUrl/auth/save-fcm-token'),
      headers: headers,
      body: jsonEncode({
        'fcmToken': fcmToken,
      }),
    );

    if (res.statusCode != 200) {
      print("⚠ Không lưu được FCM token");
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
    return 'Việt Nam';
  }

  static Future<void> logout() async {
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      final headers = await _authHeaders();

      if (fcmToken != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/remove-fcm-token'),
          headers: headers,
          body: jsonEncode({'fcmToken': fcmToken}),
        );
      }
    } catch (e) {
    }

    await AuthStorage.clear();
  }
}
