import 'package:workmanager/workmanager.dart';
import 'health_backend_sync.dart';

/// Background sync cho Health Connect data.
/// Chạy ngầm mỗi 15 phút để sync delta data lên BE.
class BackgroundSync {
  static const String _taskName = 'healthBackgroundSync';

  /// Callback function cho WorkManager.
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      try {
        print('🔥 [BackgroundSync] Starting background sync...');
        final saved = await HealthBackendSync.syncToBackend();
        print('🔥 [BackgroundSync] Synced $saved records');
        return true; // Success
      } catch (e) {
        print('🔥 [BackgroundSync] Error: $e');
        return false; // Retry
      }
    });
  }

  /// Khởi tạo WorkManager.
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set true để debug
    );
  }

  /// Schedule background sync mỗi 15 phút.
  static Future<void> scheduleSync() async {
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected, // Chỉ khi có network
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  /// Dừng background sync.
  static Future<void> cancelSync() async {
    await Workmanager().cancelByUniqueName(_taskName);
  }
}
