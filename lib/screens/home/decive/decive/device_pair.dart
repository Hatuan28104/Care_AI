import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/decive/device_allow.dart';

class DevicePairScreen extends StatelessWidget {
  const DevicePairScreen({super.key});

  static const blue = Color(0xFF1F6BFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Row(
                children: [
                  const Text(
                    'Care AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 13, 69, 159),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: blue.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:
                        const Icon(Icons.auto_awesome, color: blue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.notifications_none, size: 22),
                  const SizedBox(width: 12),
                  const Icon(Icons.settings_outlined, size: 22),
                ],
              ),
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black.withOpacity(0.08),
            ),

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
                    'Device Paired!',
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
                      'The device is now connected.\n'
                      'You can continue with the initial setup.',
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

            // ===== SET UP BUTTON (ĐẨY LÊN 30px) =====
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
                      'Set up',
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
