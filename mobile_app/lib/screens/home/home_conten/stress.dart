import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'package:Care_AI/api/health_api.dart';
import 'package:Care_AI/api/api_exception.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StressScreen(),
    );
  }
}

class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> with WidgetsBindingObserver {
  double stressValue = 42.0;
  bool _loading = false;
  String? _error;
  String? _lastDeviceId;
  Timer? _autoRefreshTimer;
  DateTime? _lastAnalyzeAt;

  static const Duration _resumeMinInterval = Duration(minutes: 5);
  static const Duration _manualMinInterval = Duration(seconds: 30);

  String getStatus(double v) {
    if (v < 40) return "TỐT";
    if (v < 70) return "ỔN ĐỊNH";
    return "CĂNG THẲNG";
  }

  Color getStatusColor(double v) {
    if (v < 40) return const Color(0xFF10B981); // Emerald
    if (v < 70) return const Color(0xFF3B82F6); // Blue
    return const Color(0xFFF43F5E); // Rose
  }

  Future<void> _analyzeStress() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final deviceId = await HealthApi.getOrCreateDevice();
      final result = await HealthApi.analyzeStressByDevice(deviceId);

      final scoreRaw = result['stress_score'] ?? 0;
      final score = scoreRaw is num ? scoreRaw.toDouble() : 0.0;

      setState(() {
        _lastDeviceId = deviceId;
        stressValue = score.clamp(0, 100);
        _lastAnalyzeAt = DateTime.now();
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi không xác định: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _canRefreshBy(Duration minInterval) {
    final lastAt = _lastAnalyzeAt;
    if (lastAt == null) return true;
    return DateTime.now().difference(lastAt) >= minInterval;
  }

  Future<void> _onManualRefresh() async {
    if (!_canRefreshBy(_manualMinInterval)) return;
    await _analyzeStress();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _analyzeStress();
    _autoRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) {
        _analyzeStress();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted && _canRefreshBy(_resumeMinInterval)) {
      _analyzeStress();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(stressValue);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: _LightBlob(color: statusColor.withOpacity(0.12), size: 400),
          ),
          Positioned(
            top: 200,
            left: -150,
            child: _LightBlob(color: const Color(0xFF818CF8).withOpacity(0.08), size: 500),
          ),
          SafeArea(
            child: Column(
              children: [
                AppHeader(title: "Dự đoán mực độ căng thẳng"),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onManualRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(48),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF334155).withOpacity(0.06),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                StressCircle(
                                  value: stressValue,
                                  color: statusColor,
                                  statusText: getStatus(stressValue),
                                ),
                                const SizedBox(height: 36),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    "Hệ thống CareAI đang theo dõi sát sao các chỉ số sinh học của bạn.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF64748B),
                                      fontSize: 14,
                                      height: 1.6,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (_loading) ...[
                            const SizedBox(height: 8),
                            const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          _MetricsGrid(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= PREMIUM ETHEREAL WIDGETS =================

class StressCircle extends StatelessWidget {
  final double value;
  final Color color;
  final String statusText;

  const StressCircle({
    super.key, 
    required this.value, 
    required this.color,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner background ring
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF1F5F9), width: 14),
            ),
          ),
          CustomPaint(
            size: const Size(200, 200),
            painter: _PurityPainter(value, color),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value.toInt().toString(),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -2,
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _PurityTile(
              title: "Nhịp tim",
              value: "68", unit: "bpm",
              icon: Icons.favorite_rounded, color: const Color(0xFFEF4444),
            )),
            const SizedBox(width: 16),
            Expanded(child: _PurityTile(
              title: "HRV",
              value: "42", unit: "ms",
              icon: Icons.waves_rounded, color: const Color(0xFF10B981),
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _PurityTile(
              title: "Giấc ngủ",
              value: "7.7", unit: "giờ",
              icon: Icons.nightlight_round, color: const Color(0xFF6366F1),
            )),
            const SizedBox(width: 16),
            Expanded(child: _PurityTile(
              title: "Bước chân",
              value: "12.4K", unit: "bước",
              icon: Icons.directions_walk_rounded, color: const Color(0xFFF59E0B),
            )),
          ],
        ),
      ],
    );
  }
}

class _PurityTile extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _PurityTile({
    required this.title, required this.value, required this.unit,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF334155).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              Text(unit, style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(),
            style: TextStyle(color: const Color(0xFF94A3B8).withOpacity(0.6), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  final Color color;

  const _PremiumButton({this.onPressed, required this.loading, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color, color.withBlue(230)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: loading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LightBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _LightBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }
}

class _PurityPainter extends CustomPainter {
  final double value;
  final Color color;

  _PurityPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final radius = (size.width / 2);
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * 3.1415926535 * (value / 100);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(rect, -3.1415926535 / 2, sweepAngle, false, glowPaint);
    canvas.drawArc(rect, -3.1415926535 / 2, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant _PurityPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
