import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'device_connect.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  static const Color blue = Color(0xFF1877F2);
  static const Color background = Color(0xFFF6F6F6);

  List<ScanResult> scanResults = [];
  bool isScanning = false;
  StreamSubscription? scanSubscription;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  Future<void> requestPermission() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    startScan();
  }

  void startScan() async {
    setState(() => isScanning = true);

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      setState(() {
        scanResults = results;
      });
    });

    await Future.delayed(const Duration(seconds: 5));

    await FlutterBluePlus.stopScan();

    if (!mounted) return;
    setState(() => isScanning = false);
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (_) {}

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConnectDeviceScreen(),
      ),
    );
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // ===== TITLE BAR =====
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: Colors.black87,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Thiết bị',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ===== TITLE =====
                  const Text(
                    'Đang quét Bluetooth',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy đảm bảo thiết bị của bạn ở gần',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'và đang bật chế độ hiển thị',
                    style: TextStyle(
                      fontSize: 14,
                      color: blue,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // ===== LOADING (chỉ hiện khi quét) =====
                  if (isScanning)
                    const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey,
                    ),

                  const SizedBox(height: 32),

                  // ===== DEVICE LIST =====
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: scanResults.isEmpty ? 1 : scanResults.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (scanResults.isEmpty) {
                          return _deviceCard(
                            name: 'Không tìm thấy thiết bị',
                            mac: '',
                            battery: 0,
                          );
                        }

                        final result = scanResults[index];
                        final device = result.device;

                        return _deviceCard(
                          name: device.name.isNotEmpty
                              ? device.name
                              : "Thiết bị không tên",
                          mac: device.id.id,
                          battery: 100,
                          onTap: () => connectDevice(device),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== DEVICE CARD (GIỮ NGUYÊN UI) =====
  static Widget _deviceCard({
    required String name,
    required String mac,
    required int battery,
    VoidCallback? onTap,
  }) {
    final bool batteryOk = battery > 20;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.watch,
              size: 32,
              color: Colors.black54,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mac,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: batteryOk ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$battery%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: batteryOk ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
