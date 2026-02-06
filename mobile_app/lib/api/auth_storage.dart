import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static String? token;

  static Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    token = newToken;
    await prefs.setString('token', newToken);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    token = null;
    await prefs.remove('token');
  }

  // 🔥🔥🔥 HÀM QUAN TRỌNG
  static Future<String?> getToken() async {
    if (token != null && token!.isNotEmpty) {
      return token;
    }

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    return token;
  }
}
