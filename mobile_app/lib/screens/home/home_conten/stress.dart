import 'dart:async';

import 'package:flutter/material.dart';
import 'package:Care_AI/l10n/app_localizations.dart';
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

class _StressScreenState extends State<StressScreen>
    with WidgetsBindingObserver {
  double stressValue = 0.0;
  double hrValue = 0.0;
  double hrvValue = 0.0;
  double sleepValue = 0.0;
  double stepsValue = 0.0;

  bool _loading = false;
  String? _error;
  Timer? _autoRefreshTimer;
  DateTime? _lastAnalyzeAt;
  bool _isDataToday = false;
  bool _isMissingEssentials = false;
  int _calibrationDays = 0;
  String _stressTimeLabel = "";

  bool _isToday(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();

      // Kiểm tra cùng ngày dương lịch
      final isSameDay = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      if (isSameDay) return true;

      // Nếu lệch múi giờ (ví dụ dữ liệu UTC bị hiểu nhầm sang ngày mai)
      // Chấp nhận nếu chênh lệch không quá 14 tiếng
      final diff = date.difference(now).abs();
      return diff.inHours < 14;
    } catch (e) {
      return false;
    }
  }

  static const Duration _resumeMinInterval = Duration(minutes: 5);
  static const Duration _manualMinInterval = Duration(seconds: 30);

  String getStatus(BuildContext context, double v) {
    if (v < 40) return context.tr.good;
    if (v < 70) return context.tr.stable;
    return context.tr.stress;
  }

  String getStressAdvice(BuildContext context, double v,
      {bool isToday = true, bool isMissingEssentials = false}) {
    if (isMissingEssentials) {
      return "Dữ liệu sức khỏe hôm nay chưa đầy đủ. Hãy đeo thiết bị thường xuyên để CareAI có thể phân tích chính xác nhất nhé!";
    }
    if (!isToday) {
      return "Hệ thống chưa nhận được dữ liệu mới nhất hôm nay. Hãy đeo thiết bị để CareAI có thể đưa ra lời khuyên chính xác nhất cho bạn nhé!";
    }
    if (v < 40) return context.tr.stressLowDesc;
    if (v < 70) return context.tr.stressMidDesc;
    return context.tr.stressHighDesc;
  }

  IconData getStressIcon(double v,
      {bool isToday = true, bool isMissingEssentials = false}) {
    if (isMissingEssentials || !isToday) return Icons.watch_rounded;
    if (v < 40) return Icons.spa_rounded;
    if (v < 70) return Icons.self_improvement_rounded;
    return Icons.error_outline_rounded;
  }

  Color getStatusColor(double v) {
    if (v < 40) return const Color(0xFF10B981);
    if (v < 70) return const Color(0xFF3B82F6);
    return const Color(0xFFF43F5E);
  }

  Future<void> _loadLatestMetrics() async {
    try {
      final deviceId = await HealthApi.getOrCreateDevice();
      final response = await HealthApi.getLatestHealthDataByUser();
      final List<dynamic> metrics = response['data'] ?? [];
      final int calibrationFromApi = response['calibration_days'] ?? 0;

      setState(() {
        _calibrationDays = calibrationFromApi;
        bool anyToday = false;
        bool hasSleepToday = false;
        bool hasHrvToday = false;
        String latestStressTime = "";

        for (var item in metrics) {
          final cid = item['loaichiso_id'];
          final val =
              item['giatri'] is num ? (item['giatri'] as num).toDouble() : 0.0;
          final time = item['thoigiancapnhat'] as String?;
          final isToday = _isToday(time);

          if (isToday) anyToday = true;

          if (cid == 'CS016') {
            stressValue = val;
            if (time != null) {
              final dt = DateTime.parse(time).toLocal();
              if (isToday) {
                latestStressTime =
                    "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}, Hôm nay";
              } else {
                latestStressTime =
                    "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}, ${dt.day} thg ${dt.month}";
              }
            }
          }
          if (cid == 'CS001') hrValue = isToday ? val : 0.0;
          if (cid == 'CS008') {
            hrvValue = isToday ? val : 0.0;
            if (isToday) hasHrvToday = true;
          }
          if (cid == 'CS037') {
            sleepValue = isToday ? val : 0.0;
            if (isToday) hasSleepToday = true;
          }
          if (cid == 'CS004') stepsValue = isToday ? val : 0.0;
        }
        _isDataToday = anyToday;
        _isMissingEssentials = !hasSleepToday || !hasHrvToday;
        _stressTimeLabel = latestStressTime;
      });
    } catch (e) {
      debugPrint("Error loading latest metrics: $e");
    }
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

      // Backend trả về: data: { stress: score, thoigian: ... }
      final scoreRaw = result['stress'] ?? 0;
      final score = scoreRaw is num ? scoreRaw.toDouble() : 0.0;

      setState(() {
        stressValue = score;
        _calibrationDays = result['calibration_days'] ?? 0;
        _lastAnalyzeAt = DateTime.now();
        _isDataToday = true;
        _stressTimeLabel = "Vừa xong";
      });

      // Sau khi AI tính xong và lưu vào DB, load lại toàn bộ để đồng bộ
      await _loadLatestMetrics();
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
    if (!_canRefreshBy(_manualMinInterval)) {
      await _loadLatestMetrics(); // Nếu chưa đến lúc gọi AI thì chỉ làm mới UI từ DB
      return;
    }
    await _analyzeStress();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLatestMetrics(); // Load data cũ ngay khi vào màn hình
    _autoRefreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) {
        _analyzeStress();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        mounted &&
        _canRefreshBy(_resumeMinInterval)) {
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
            child: _LightBlob(
                color: const Color(0xFF818CF8).withOpacity(0.08), size: 500),
          ),
          SafeArea(
            child: Column(
              children: [
                AppHeader(
                  title: context.tr.stressTitle,
                ),
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 40, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(48),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF334155).withOpacity(0.06),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    StressCircle(
                                      value: stressValue,
                                      color: statusColor,
                                      statusText:
                                          getStatus(context, stressValue),
                                    ),
                                    if (_loading)
                                      const CircularProgressIndicator(
                                        strokeWidth: 3,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFF3B82F6)),
                                      ),
                                  ],
                                ),
                                if (_stressTimeLabel.isNotEmpty ||
                                    _calibrationDays < 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Column(
                                      children: [
                                        if (_stressTimeLabel.isNotEmpty ||
                                            _calibrationDays < 3)
                                          Text(
                                            "Cập nhật: $_stressTimeLabel",
                                            style: TextStyle(
                                              color:
                                                  statusColor.withOpacity(0.6),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        if (_calibrationDays < 3) ...[
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  title: Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.info_outline,
                                                          color: Colors.orange),
                                                      const SizedBox(width: 10),
                                                      Text(
                                                          context.tr
                                                              .stressCalibrationTitle,
                                                          style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ],
                                                  ),
                                                  content: Text(
                                                    context.tr
                                                        .stressCalibrationContent,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        height: 1.5),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text(
                                                          context.tr
                                                              .stressCalibrationButton,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: Colors.orange
                                                        .withOpacity(0.2)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.info_outline,
                                                      size: 12,
                                                      color: Colors.orange),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    context.tr
                                                        .stressCalibrationBadge(
                                                      _calibrationDays
                                                          .toString(),
                                                    ),
                                                    style: const TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 36),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        getStressIcon(stressValue,
                                            isToday: _isDataToday,
                                            isMissingEssentials:
                                                _isMissingEssentials),
                                        color: (_isDataToday &&
                                                !_isMissingEssentials)
                                            ? statusColor.withOpacity(0.5)
                                            : Colors.orange.withOpacity(0.5),
                                        size: 28,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        getStressAdvice(context, stressValue,
                                            isToday: _isDataToday,
                                            isMissingEssentials:
                                                _isMissingEssentials),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF64748B),
                                          fontSize: 12.5,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          const SizedBox(height: 8),
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
                          _MetricsGrid(
                            hr: hrValue,
                            hrv: hrvValue,
                            sleep: sleepValue,
                            steps: stepsValue,
                          ),
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
  final double hr;
  final double hrv;
  final double sleep;
  final double steps;

  const _MetricsGrid({
    required this.hr,
    required this.hrv,
    required this.sleep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _PurityTile(
              title: "Nhịp tim",
              value: hr > 0 ? hr.toInt().toString() : "--",
              unit: "bpm",
              icon: Icons.favorite_rounded,
              color: const Color(0xFFEF4444),
            )),
            const SizedBox(width: 16),
            Expanded(
                child: _PurityTile(
              title: "HRV",
              value: hrv > 0 ? hrv.toInt().toString() : "--",
              unit: "ms",
              icon: Icons.waves_rounded,
              color: const Color(0xFF10B981),
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _PurityTile(
              title: "Giấc ngủ",
              value: sleep > 0 ? sleep.toStringAsFixed(1) : "--",
              unit: "giờ",
              icon: Icons.nightlight_round,
              color: const Color(0xFF6366F1),
            )),
            const SizedBox(width: 16),
            Expanded(
                child: _PurityTile(
              title: "Bước chân",
              value: steps > 0
                  ? (steps >= 1000
                      ? "${(steps / 1000).toStringAsFixed(1)}K"
                      : steps.toInt().toString())
                  : "--",
              unit: "bước",
              icon: Icons.directions_walk_rounded,
              color: const Color(0xFFF59E0B),
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
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
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
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontWeight: FontWeight.w900)),
              const SizedBox(width: 4),
              Text(unit,
                  style: TextStyle(
                      color: const Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title.toUpperCase(),
            style: TextStyle(
                color: const Color(0xFF94A3B8).withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5),
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

  const _PremiumButton(
      {this.onPressed,
      required this.loading,
      required this.label,
      required this.color});

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 3))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800),
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
