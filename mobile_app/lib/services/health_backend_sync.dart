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

      final metrics = await HealthApi.getMetrics();
      final idSet = metrics
          .map((m) => (m['LoaiChiSo_ID'] ?? '').toString().trim())
          .toSet();
      var saved = 0;

      // Sync steps (chỉ nếu tăng so với lần cuối)
      if (steps >= 0 && idSet.contains('CS004')) {
        final lastSteps = _lastSyncedValues['steps'] as int? ?? 0;
        if (steps > lastSteps) {
          await HealthApi.saveHealthData(
              giaTri: steps.toDouble(),
              thietBiId: deviceId,
              loaiChiSoId: 'CS004');
          _lastSyncedValues['steps'] = steps;
          saved++;
        }
      }

      // Sync các metric khác (chỉ nếu giá trị khác lần cuối)
      for (final e in hcToLoaiChiSo.entries) {
        if (e.key == 'steps') continue;
        final v = summary[e.key];
        double? numVal;
        if (v is num) numVal = v.toDouble();
        if (numVal == null || numVal < 0 || !idSet.contains(e.value)) continue;

        double val = numVal;
        if (e.key == 'sleepMinutes') val = numVal / 60; // CS037 đơn vị giờ

        final lastVal = _lastSyncedValues[e.key] as double?;
        if (lastVal == null || (val - lastVal).abs() > 0.01) {
          // threshold nhỏ để tránh floating point
          await HealthApi.saveHealthData(
              giaTri: val, thietBiId: deviceId, loaiChiSoId: e.value);
          _lastSyncedValues[e.key] = val;
          saved++;
        }
      }

      // Sync blood pressure (chỉ nếu khác lần cuối)
      final bp = summary['bloodPressure'];
      if (bp is String && bp.isNotEmpty && idSet.contains('CS003')) {
        final lastBp = _lastSyncedValues['bloodPressure'] as String?;
        if (lastBp == null || bp != lastBp) {
          final parts = bp.split('/');
          if (parts.isNotEmpty) {
            final sys = double.tryParse(parts[0].trim());
            if (sys != null) {
              await HealthApi.saveHealthData(
                  giaTri: sys, thietBiId: deviceId, loaiChiSoId: 'CS003');
              _lastSyncedValues['bloodPressure'] = bp;
              saved++;
            }
          }
        }
      }

      // Save last synced values để persist
      if (saved > 0) {
        await _saveLastSyncedValues();
      }

      return saved;
    } catch (e) {
      print("🔥 [HealthBackendSync] error: $e");
      rethrow;
    }
  }
}
