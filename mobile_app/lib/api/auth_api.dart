import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:Care_AI/models/user.dart';
import 'auth_storage.dart';
import 'package:Care_AI/models/login_history_item.dart';
import 'package:Care_AI/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Care_AI/config/api_config.dart';
import 'api_exception.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:Care_AI/services/time_service.dart';
import 'dart:async';
import 'dart:io';

class AuthApi {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    } else {
      return 'web-device';
    }
  }

  static Future<String> getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final brand = androidInfo.brand.trim();
        final model = androidInfo.model.trim();
        return "$brand $model".trim();
      }
      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final name = iosInfo.name.trim();
        final model = iosInfo.model.trim();
        return "$name $model".trim();
      }
      return "Unknown device";
    } catch (_) {
      return "Unknown device";
    }
  }

  static String getLoginTime() {
    return TimeService.nowLocalIso();
  }
  static Future<String> sendFirebaseOtp(String phone) async {
    final completer = Completer<String>();

    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 90),
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
        await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        if (!completer.isCompleted) {
          completer.completeError(
            ApiException(e.message ?? 'Không thể gửi OTP'),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
    );

    return completer.future;
  }

static Future<User> firebaseLoginWithOtp({
  required String verificationId,
  required String otp,
}) async {
  final credential = firebase_auth.PhoneAuthProvider.credential(
    verificationId: verificationId,
    smsCode: otp,
  );

  final userCredential =
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

  final idToken = await userCredential.user?.getIdToken();

  if (idToken == null || idToken.isEmpty) {
    throw ApiException('Không nhận được Firebase ID token');
  }

  final deviceId = await getDeviceId();
  final deviceName = await getDeviceName();
  final loginTime = getLoginTime();
  final fcmToken = await FirebaseMessaging.instance.getToken();

  final res = await http
      .post(
        Uri.parse('$baseUrl/auth/firebase-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'deviceId': deviceId,
          'device': deviceName,
          'login_time': loginTime,
          'fcmToken': fcmToken,
        }),
      )
      .timeout(const Duration(seconds: 10));

  Map<String, dynamic> data;
  try {
    data = jsonDecode(res.body);
  } catch (_) {
    throw ApiException("Server trả dữ liệu lỗi");
  }

  if (res.statusCode != 200 || data['success'] != true) {
    throw ApiException(data['message'] ?? 'Đăng nhập Firebase thất bại');
  }

  final token = data['token'];
  if (token == null || token.isEmpty) {
    throw ApiException('Không nhận được token');
  }

  await AuthStorage.saveToken(token);

  final userRaw = data['user'] is Map<String, dynamic>
      ? data['user'] as Map<String, dynamic>
      : <String, dynamic>{};

  final user = User.fromJson({
    ...userRaw,
    'token': token,
    'profileCompleted': data['profileCompleted'] == true,
  });

  if (user.nguoiDungId.isEmpty) {
    throw ApiException('Không nhận được nguoiDungId');
  }

  await AuthStorage.saveUserId(user.nguoiDungId);
  await AuthStorage.saveAccountId(userRaw['taikhoan_id'] ?? '');
  await AuthStorage.saveDeviceId(deviceId);

  AppSettings.phoneNumber.value =
      userRaw['sodienthoai']?.toString() ??
      userRaw['SoDienThoai']?.toString() ??
      '';

  return user;
}
static Future<Map<String, String>> _authHeaders() async {
  final token = await AuthStorage.getToken();

  if (token == null || token.isEmpty) {
    throw ApiException('Chưa đăng nhập');
  }

  return {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
  static Future<void> changePhone(String phone) async {
    final headers = await _authHeaders();

    final res = await http
        .post(
          Uri.parse('$baseUrl/auth/change-phone'),
          headers: headers,
          body: jsonEncode({'phone': phone}),
        )
        .timeout(const Duration(seconds: 5));

    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Không thể đổi số điện thoại');
    }
  }

  static Future<List<LoginHistoryItem>> getLoginHistory() async {
    final headers = await _authHeaders();

    final res = await http
        .get(
          Uri.parse('$baseUrl/auth/login-history'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 5));

    print("LOGIN HISTORY STATUS: ${res.statusCode}");
    print("LOGIN HISTORY BODY: ${res.body}");

    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body);
    } catch (_) {
      throw ApiException("Server trả dữ liệu lỗi");
    }
    if (res.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message'] ?? 'Không lấy được lịch sử đăng nhập');
    }

    final List list = data['data'] is List ? data['data'] : [];

    return list.map((e) {
      final rawTime = (e['thoigian'] ?? '').toString();
      String timeText = 'Không xác định';
      if (rawTime.isNotEmpty) {
        try {
          timeText = rawTime; 
        } catch (_) {}
      }
      return LoginHistoryItem(
        device: e['thietbi'] ?? 'Unknown device',
        location: _mapIpToLocation(e['ip']),
        time: timeText,
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
        await http
            .post(
              Uri.parse('$baseUrl/auth/remove-fcm-token'),
              headers: headers,
              body: jsonEncode({'fcmToken': fcmToken}),
            )
            .timeout(const Duration(seconds: 5));
      }
    } catch (e) {}

    await AuthStorage.clear();
  }
}
