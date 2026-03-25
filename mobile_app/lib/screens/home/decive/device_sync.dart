import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/decive/decive_allow.dart';
import 'package:Care_AI/screens/home/decive/device_complete.dart';
import 'package:Care_AI/models/tr.dart';

class AllowDeviceScreen extends StatelessWidget {
  final String appName;

  const AllowDeviceScreen({super.key, required this.appName});

  static const blue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              context.tr.allowAccess,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: blue,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                context.tr.useDataFrom(appName),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.tr.later),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        print(
                            "🔥 [AllowDeviceScreen] tap Cho phep app=$appName");
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeviceSyncScreen(appName: appName),
                          ),
                        );
                        print("🔥 [AllowDeviceScreen] sync result=$result");

                        // Chỉ chuyển sang DeviceComplete khi người dùng đã cấp permission thành công.
                        if (result == true) {
                          print(
                              "🔥 [AllowDeviceScreen] navigate DeviceComplete");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeviceCompleteScreen(
                                appName: appName,
                              ),
                            ),
                          );
                        } else {
                          print(
                              "🔥 [AllowDeviceScreen] permission denied or failed (result=$result)");
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(context.tr.syncFailed),
                              content: Text(
                                context.tr.tryAgain,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(context.tr.allow),
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
}
