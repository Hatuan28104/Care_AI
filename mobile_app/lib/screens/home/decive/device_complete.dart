import 'package:flutter/material.dart';
import 'package:demo_app/screens/home/decive/device_detail.dart';
import 'package:demo_app/models/tr.dart';

class DeviceCompleteScreen extends StatelessWidget {
  const DeviceCompleteScreen({super.key});

  static const blue = Color(0xFF1877F2);
  static const green = Color(0xFF45C46D);
  static const bg = Color(0xFFF6F6F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            Transform.translate(
              offset: const Offset(0, -70),
              child: Column(
                children: [
                  Container(
                    width: 116,
                    height: 116,
                    decoration: const BoxDecoration(
                      color: green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr.setupComplete,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      context.tr.deviceReady,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ===== BUTTON DONE (GIỮ NGUYÊN LAYOUT) =====
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
                          builder: (_) => const DeviceDetailScreen(),
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
                    child: Text(
                      context.tr.done,
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
