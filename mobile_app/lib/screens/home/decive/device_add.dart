import 'package:flutter/material.dart';
import 'device_connect.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({super.key});

  static const Color blue = Color(0xFF1877F2);
  static const Color background = Color(0xFFF6F6F6);

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

                  // ===== LOADING =====
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 32),

                  // ===== DEVICE LIST =====
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _deviceCard(
                          name: 'Apple Watch (Demo)',
                          mac: '23:12:D1:E3:12:18',
                          battery: 100,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ConnectDeviceScreen(),
                              ),
                            );
                          },
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

  // ===== DEVICE CARD =====
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
