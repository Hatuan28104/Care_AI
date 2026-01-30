import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/decive/device_complete.dart';

class DeviceSyncingScreen extends StatelessWidget {
  const DeviceSyncingScreen({super.key});

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

            const SizedBox(height: 8),

            Transform.translate(
              offset: const Offset(0, 6),
              child: const Column(
                children: [
                  Text(
                    'Đang đồng bộ thiết bị',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Chúng tôi đang chuẩn bị dữ liệu sức khỏe để mang lại '
                      'trải nghiệm tốt nhất cho bạn. Quá trình này có thể '
                      'mất một chút thời gian.\n\n'
                      'Hãy giữ đồng hồ ở gần điện thoại để đảm bảo việc '
                      'đồng bộ diễn ra suôn sẻ. Bạn sẽ nhận được thông báo '
                      'khi quá trình hoàn tất.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -80),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.smartphone,
                        size: 142,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.arrow_back,
                            size: 36,
                            color: Colors.black26,
                          ),
                          SizedBox(height: 0),
                          Icon(
                            Icons.arrow_forward,
                            size: 36,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.watch,
                        size: 132,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeviceCompleteScreen(),
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
                      'Tiếp tục',
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
