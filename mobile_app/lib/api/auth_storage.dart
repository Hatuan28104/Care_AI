import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static String? token;
  static String? userId;
  static String? deviceId;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    token = _prefs?.getString('token');
    userId = _prefs?.getString('userId');
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

  static Future<void> clear() async {
    token = null;
    userId = null;
    deviceId = null;
    await _prefs?.remove('token');
    await _prefs?.remove('userId');
    await _prefs?.remove('deviceId');
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
}
