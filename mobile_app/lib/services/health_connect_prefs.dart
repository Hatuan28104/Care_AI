import 'package:shared_preferences/shared_preferences.dart';

/// Lưu trạng thái đã hoàn tất kết nối Health Connect (để lần sau vào thẳng màn chi tiết).
class HealthConnectPrefs {
  static const _kLinked = 'health_connect_linked';
  static const _kAppName = 'health_connect_app_name';

  static Future<void> setLinked(String appName) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLinked, true);
    await p.setString(_kAppName, appName);
  }

  static Future<void> clearLinked() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kLinked, false);
    await p.remove(_kAppName);
  }

  static Future<bool> isLinked() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kLinked) ?? false;
  }

  static Future<String?> getLinkedAppName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kAppName);
  }
}
