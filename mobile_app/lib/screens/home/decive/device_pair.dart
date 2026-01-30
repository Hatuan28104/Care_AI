import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/decive/device_allow.dart';

class DevicePairScreen extends StatelessWidget {
  const DevicePairScreen({super.key});

  static const blue = Color(0xFF1877F2);
  static const bg = Color(0xFFF6F6F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ❌ HEADER ĐÃ BỎ

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 100, 12, 6),
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 220,
                      child: Image.asset(
                        'assets/images/smart watch.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đã ghép đôi thiết bị!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 34),
                    child: Text(
                      'Thiết bị đã được kết nối thành công.\n'
                      'Bạn có thể tiếp tục quá trình thiết lập ban đầu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ===== SET UP BUTTON (GIỮ NGUYÊN LAYOUT) =====
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AllowDeviceScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Thiết lập',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
