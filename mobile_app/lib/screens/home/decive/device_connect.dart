import 'dart:async';
import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/decive/device_pair.dart';
import 'package:Care_AI/models/tr.dart';

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  State<ConnectDeviceScreen> createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  static const blue = Color(0xFF1877F2);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _showPairDialog();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showPairDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 14),
                Text(
                  context.tr.bluetoothPairRequest,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.tr.bluetoothPairDesc,
                    style: TextStyle(fontSize: 12.5, height: 1.3),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '000000',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: const Color(0xFFE6E6E6)),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(18),
                          ),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            Navigator.of(context).pop();
                          },
                          child: Center(
                            child: Text(
                              context.tr.cancel,
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, color: const Color(0xFFE6E6E6)),
                      Expanded(
                        child: InkWell(
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(18),
                          ),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DevicePairScreen(),
                              ),
                            );
                          },
                          child: Center(
                            child: Text(
                              context.tr.pair,
                              style: TextStyle(
                                fontSize: 20,
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // ❌ HEADER ĐÃ BỎ
            Transform.translate(
              offset: const Offset(0, -12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 6),
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
                    Text(
                      context.tr.device,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Text(
              context.tr.connectDevice,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: blue,
              ),
            ),

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

            const SizedBox(height: 50),
            Text(
              context.tr.demoWatch,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              context.tr.connecting,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
