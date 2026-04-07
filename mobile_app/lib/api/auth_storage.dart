import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static String? token;
  static String? userId;
  static String? deviceId;
  static SharedPreferences? _prefs;
static String? accountId;
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    token = _prefs?.getString('token');
    userId = _prefs?.getString('userId');
    accountId = _prefs?.getString('taikhoan_id');
    deviceId = _prefs?.getString('deviceId');
  }

  static Future<void> saveToken(String newToken) async {
    token = newToken;
    await _prefs?.setString('token', newToken);
  }

  static Future<void> saveUserId(String id) async {
    userId = id;
    await _prefs?.setString('userId', id);
  }

  static Future<void> saveDeviceId(String id) async {
    deviceId = id;
    await _prefs?.setString('deviceId', id);
  }

  static String? getToken() {
    return token;
  }

  static String? getUserId() {
    return userId;
  }

  static String? getDeviceId() {
    return deviceId;
  }

  static Future<void> saveAccountId(String id) async {
    accountId = id;
    await _prefs?.setString('taikhoan_id', id);
  }

  static String? getAccountId() {
    return accountId;
  }
  static Future<void> clear() async {
  token = null;
  userId = null;
  deviceId = null;
  accountId = null;

  await _prefs?.remove('token');
  await _prefs?.remove('userId');
  await _prefs?.remove('deviceId');
  await _prefs?.remove('taikhoan_id');
  }
}
