import 'dart:convert';
import 'package:Care_AI/api/auth_storage.dart';
import 'package:Care_AI/api/health_api.dart';
import 'package:Care_AI/api/health_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Đồng bộ dữ liệu Health Connect lên backend (DuLieuSucKhoe).
/// Dùng LoaiChiSo_ID có sẵn trong LoaiChiSoSucKhoe (CS001, CS002, ...).
/// Chỉ gửi dữ liệu khi có thay đổi để tránh quá tải (giống app sức khỏe lớn).
class HealthBackendSync {
  /// Map Health Connect key → LoaiChiSo_ID (theo LoaiChiSoSucKhoe)
  static const hcToLoaiChiSo = {
    'steps': 'CS004', // Số bước chân
    'distanceKm': 'CS023', // Quãng đường
    'caloriesKcal': 'CS005', // Calo tiêu thụ
    'heartRateBpm': 'CS001', // Nhịp tim
    'bloodPressure': 'CS003', // Huyết áp
    'spo2Percent': 'CS018', // Độ bão hòa oxy
    'respiratoryRate': 'CS006', // Nhịp thở
    'bodyTempC': 'CS021', // Nhiệt độ cơ thể
    'sleepMinutes': 'CS037', // Thời gian ngủ
    'restingHeartRateBpm': 'CS007', // Tần số tim nghỉ
    'heightCm': 'CS002', // Chiều cao
    'weightKg': 'CS007', // Cân nặng
    'heartRateVariabilityRmssd': 'CS008', // Biến thiên nhịp tim (HRV)
  };

  /// Lưu giá trị cuối cùng đã sync để tránh gửi duplicate (delta sync).
  static final Map<String, dynamic> _lastSyncedValues = {};

  /// Load last synced values từ SharedPreferences (persist qua sessions).
  static Future<void> loadLastSyncedValues() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('health_last_synced');
    if (jsonStr != null) {
      try {
        _lastSyncedValues.clear();
        _lastSyncedValues
            .addAll(Map<String, dynamic>.from(jsonDecode(jsonStr)));
      } catch (_) {}
    }
  }

  /// Save last synced values vào SharedPreferences.
  static Future<void> _saveLastSyncedValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('health_last_synced', jsonEncode(_lastSyncedValues));
  }

  /// Trả về số bản ghi đã lưu. 0 nếu chưa đăng nhập.
  /// Chỉ gửi dữ liệu khi có thay đổi (delta sync) để tránh quá tải.
  static Future<int> syncToBackend() async {
    try {
      final userId = await AuthStorage.getUserId();
      if (userId == null || userId.isEmpty) return 0;

      final deviceId = await HealthApi.getOrCreateDevice();
      final steps = await HealthService.getSteps();
      final summary = await HealthService.getHealthSummary();

      final payload = {
        "steps": steps,
        "hr": summary['heartRateBpm'],
        "spo2": summary['spo2Percent'],
        "sleep": summary['sleepMinutes'],
        "distance": summary['distanceKm'],
        "hrv": summary['heartRateVariabilityRmssd'],
      };

      // ❌ nếu không có data thì bỏ
      payload.removeWhere((key, value) => value == null);

      // 🔥 CHECK DELTA (QUAN TRỌNG)
      bool hasChange = false;

      payload.forEach((key, value) {
        final last = _lastSyncedValues[key];

        if (last == null || (value is num && (value - last).abs() > 0.1)) {
          hasChange = true;
        }
      });

      if (!hasChange) return 0;

// 🔥 SAVE
      await HealthApi.saveMultipleHealthData({
        "thietbi_id": deviceId,
        ...payload,
      });

// 🔥 UPDATE CACHE
      _lastSyncedValues.addAll(payload);
      await _saveLastSyncedValues();

      return 1;
    } catch (e) {
      print("🔥 [HealthBackendSync] error: $e");
      rethrow;
    }
  }
}
