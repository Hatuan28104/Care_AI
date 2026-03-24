import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/api/health_service.dart';
import 'package:Care_AI/services/health_backend_sync.dart';

class DeviceSyncScreen extends StatefulWidget {
  final String appName;

  const DeviceSyncScreen({super.key, required this.appName});

  @override
  State<DeviceSyncScreen> createState() => _DeviceSyncScreenState();
}

class _DeviceSyncScreenState extends State<DeviceSyncScreen>
    with SingleTickerProviderStateMixin {
  static const blue = Color(0xFF1877F2);

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();

    _startSync();
  }

  Future<void> _startSync() async {
    print("🔥 [DeviceSyncScreen] start app=${widget.appName}");
    // Chờ 3-5 giây để đồng bộ (hiệu ứng xoay đang diễn ra)
    await Future.delayed(const Duration(seconds: 3));
    print("🔥 [DeviceSyncScreen] waiting 3s before requesting permission");

    final requested = await HealthService.requestPermission();
    print("🔥 [DeviceSyncScreen] requested=$requested");

    if (!mounted) return;
    if (!requested) {
      print("🔥 [DeviceSyncScreen] pop false because requested=false");
      Navigator.pop(context, false);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 700));
    // Ưu tiên kết quả request trực tiếp từ Health Connect.
    // Một số máy/ROM có thể trả lỗi khi gọi check ngay sau request dù người dùng đã cho phép.
    bool granted = true;
    try {
      final checked = await HealthService.checkPermission();
      granted = checked || requested;
      print("🔥 [DeviceSyncScreen] checked=$checked finalGranted=$granted");
    } catch (_) {
      granted = requested;
      print(
          "🔥 [DeviceSyncScreen] check exception fallback finalGranted=$granted");
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 500));

    if (granted) {
      await HealthService.scheduleHealthSyncWork();
      try {
        final saved = await HealthBackendSync.syncToBackend();
        print("🔥 [DeviceSyncScreen] syncedToBackend=$saved records");
      } catch (e) {
        print("🔥 [DeviceSyncScreen] sync error: $e");
      }
    }

    print("🔥 [DeviceSyncScreen] pop result=$granted");
    Navigator.pop(context, granted); // 🔥 TRẢ RESULT
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Đang đồng bộ dữ liệu",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Đang lấy dữ liệu từ ${widget.appName}",
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              RotationTransition(
                turns: _controller,
                child: const Icon(Icons.sync, size: 60, color: blue),
              ),
              const SizedBox(height: 30),
              const Text(
                "Đang đồng bộ, vui lòng chờ...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
