import 'dart:math';
import 'package:flutter/material.dart';

// ===== CONSTANTS =====
const TextStyle _axisTextStyle = TextStyle(
  fontSize: 11,
  color: Colors.black45,
  fontWeight: FontWeight.w600,
);

enum ActivityRange { h, d, w, m, m6, y }

// ===== SCREEN =====
class ActivityDetailScreen extends StatefulWidget {
  const ActivityDetailScreen({
    super.key,
    required this.title,
    required this.unit,
    required this.value,
    this.accent = const Color(0xFFFF3B30),
  });

  final String title;
  final String unit;
  final int value;
  final Color accent;

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  static const _bg = Color(0xFFF3F5F9);

  ActivityRange _range = ActivityRange.h;
  late List<double> _values;

  @override
  void initState() {
    super.initState();
    _values = _mockValues();
  }

  // ===== MOCK DATA (ACTIVITY SCALE) =====
  List<double> _mockValues() {
    final r = Random();
    return List.generate(12, (_) => 500 + r.nextInt(3000).toDouble());
  }

  List<String> _xLabels() {
    switch (_range) {
      case ActivityRange.h:
        return ['16:00', '16:15', '16:30', '16:45'];
      case ActivityRange.d:
        return ['00', '06', '12', '18'];
      case ActivityRange.w:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case ActivityRange.m:
        return ['1', '8', '15', '22'];
      case ActivityRange.m6:
        return ['Jan', 'Mar', 'May', 'Jul'];
      case ActivityRange.y:
        return ['2021', '2022', '2023', '2024'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final latest = _values.isNotEmpty ? _values.last : 0.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            const SizedBox(height: 10),
            _rangeTabs(),
            const SizedBox(height: 10),
            _rangeInfo(),
            const SizedBox(height: 12),
            _chartCard(),
            const SizedBox(height: 10),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  // ===== RANGE TABS =====
  Widget _rangeTabs() {
    Widget tab(String t, ActivityRange r) {
      final active = _range == r;
      return GestureDetector(
        onTap: () => setState(() {
          _range = r;
          _values = _mockValues();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            boxShadow: active
                ? const [
                    BoxShadow(
                      blurRadius: 6,
                      color: Color(0x22000000),
                      offset: Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            t,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: active ? Colors.black : Colors.black54,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tab('H', ActivityRange.h),
            tab('D', ActivityRange.d),
            tab('W', ActivityRange.w),
            tab('M', ActivityRange.m),
            tab('6M', ActivityRange.m6),
            tab('Y', ActivityRange.y),
          ],
        ),
      ),
    );
  }

  // ===== RANGE INFO =====
  Widget _rangeInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RANGE',
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.value.toString(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    widget.unit,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Last 7 days',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CHART =====
  Widget _chartCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 260,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      painter: _ActivityBarPainter(
                        values: _values,
                        accent: widget.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('4000', style: _axisTextStyle),
                      Text('3000', style: _axisTextStyle),
                      Text('2000', style: _axisTextStyle),
                      Text('1000', style: _axisTextStyle),
                      Text('0', style: _axisTextStyle),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _xLabels()
                  .map((e) => Text(e, style: _axisTextStyle))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ===== LATEST =====
}

// ===== ACTIVITY BAR PAINTER =====
class _ActivityBarPainter extends CustomPainter {
  _ActivityBarPainter({required this.values, required this.accent});

  final List<double> values;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final maxV = 4000.0;
    final paint = Paint()..color = accent;

    final n = values.length;
    const gap = 8.0;
    final barW = (size.width - gap * (n - 1)) / n;

    for (int i = 0; i < n; i++) {
      final v = values[i].clamp(0, maxV);
      final barH = (v / maxV) * size.height;
      final left = i * (barW + gap);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - barH, barW, barH),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityBarPainter old) =>
      old.values != values || old.accent != accent;
}
