import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/decive/device_syncing.dart';

class AllowDeviceScreen extends StatelessWidget {
  const AllowDeviceScreen({super.key});

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

            const SizedBox(height: 14),

            // ===== TITLE =====
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  Text(
                    'Get Notifications\nAbout Your Health',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F6BFF),
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Receive a notification when there's\nsomething you need to know.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ===== CARD (ĐẨY XUỐNG) =====
            Transform.translate(
              offset: const Offset(0, 60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health Alerts',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your smartwatch can warn you if unusual\n'
                              'patterns are detected in your heart rate,\n'
                              'blood pressure, or other vital signs. These\n'
                              'notifications can help you take timely action\n'
                              'or inform caregivers when needed.',
                              style: TextStyle(
                                fontSize: 12.3,
                                color: Colors.black54,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 26),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeviceSyncingScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Not now',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DeviceSyncingScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Allow',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
