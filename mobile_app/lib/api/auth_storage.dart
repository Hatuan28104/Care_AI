import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static String? token;
  static String? userId; // 🔥 thêm

  static Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    token = newToken;
    await prefs.setString('token', newToken);
  }

  // 🔥 thêm hàm lưu userId
  static Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    userId = id;
    await prefs.setString('userId', id);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userId = prefs.getString('userId'); // 🔥 load thêm
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    token = null;
    userId = null;
    await prefs.remove('token');
    await prefs.remove('userId');
  }

  static Future<String?> getToken() async {
    if (token != null && token!.isNotEmpty) return token;

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    return token;
  }

  // 🔥 THÊM HÀM NÀY
  static Future<String?> getUserId() async {
    if (userId != null && userId!.isNotEmpty) return userId;

    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    return userId;
  }
}
