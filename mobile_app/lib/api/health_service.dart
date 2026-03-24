import 'package:flutter/services.dart';

class HealthService {
  static const platform = MethodChannel('health_connect');

  static Future<bool> requestPermission() async {
    print("🔥 [HealthService] CALL requestPermission");

    try {
      final result = await platform.invokeMethod('requestHealthPermission');
      print("🔥 [HealthService] requestPermission result=$result");
      return result == true;
    } catch (e) {
      print("🔥 [HealthService] ERROR requestPermission: $e");
      return false;
    }
  }

  static Future<bool> checkPermission() async {
    print("🔥 [HealthService] CALL checkPermission");

    try {
      final result = await platform.invokeMethod('checkPermission');
      print("🔥 [HealthService] checkPermission result=$result");
      return result == true;
    } catch (e) {
      print("🔥 [HealthService] ERROR checkPermission: $e");
      return false;
    }
  }

  static Future<int> getSteps() async {
    print("🔥 [HealthService] CALL getSteps");

    try {
      final result = await platform.invokeMethod('getSteps');
      print("🔥 [HealthService] getSteps result=$result");
      return result ?? 0;
    } catch (e) {
      print("🔥 [HealthService] ERROR getSteps: $e");
      return 0;
    }
  }

  static Future<Map<String, dynamic>> getStepsDebug() async {
    print("🔥 [HealthService] CALL getStepsDebug");

    try {
      final result = await platform.invokeMethod('getStepsDebug');
      if (result == null) return {"steps": 0, "debug": "null result"};
      print("🔥 [HealthService] getStepsDebug result=$result");
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      print("🔥 [HealthService] ERROR getStepsDebug: $e");
      return {"steps": 0, "debug": "exception: $e"};
    }
  }

  static Future<List<Map<String, dynamic>>> getInstalledHealthApps() async {
    try {
      final result = await platform.invokeMethod('getInstalledHealthApps');
      if (result == null) return [];

      final rawList = List<dynamic>.from(result as List);
      return rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    } catch (e) {
      print("🔥 [HealthService] ERROR getInstalledHealthApps: $e");
      return [];
    }
  }

  static Future<Map<String, dynamic>> getHealthSummary() async {
    try {
      final result = await platform.invokeMethod('getHealthSummary');
      if (result == null) return {};
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      print("🔥 [HealthService] ERROR getHealthSummary: $e");
      return {};
    }
  }

  static Future<void> scheduleHealthSyncWork() async {
    try {
      await platform.invokeMethod('scheduleHealthSyncWork');
    } catch (e) {
      print("🔥 [HealthService] scheduleHealthSyncWork error: $e");
    }
  }
}
