import 'dart:math';
import 'package:flutter/material.dart';

// ===== CONSTANTS =====
const TextStyle _axisTextStyle = TextStyle(
  fontSize: 11,
  color: Colors.black45,
  fontWeight: FontWeight.w600,
);

enum MetricRange { h, d, w, m, m6, y }

// ===== SCREEN =====
class BasicHealthDetailScreen extends StatefulWidget {
  const BasicHealthDetailScreen({
    super.key,
    required this.title,
    required this.unit,
    required this.minDisplay,
    required this.maxDisplay,
    this.accent = const Color(0xFF00BCD4),
  });

  final String title;
  final String unit;
  final String minDisplay;
  final String maxDisplay;
  final Color accent;

  @override
  State<BasicHealthDetailScreen> createState() =>
      _BasicHealthDetailScreenState();
}

class _BasicHealthDetailScreenState extends State<BasicHealthDetailScreen> {
  static const _bg = Color(0xFFF3F5F9);

  MetricRange _range = MetricRange.h;
  late List<double> _values;

  @override
  void initState() {
    super.initState();
    _values = _mockValues();
  }

  List<String> _xLabels() {
    switch (_range) {
      case MetricRange.h:
        return ['16:00', '16:15', '16:30', '16:45'];

      case MetricRange.d:
        return ['00:00', '06:00', '12:00', '18:00'];

      case MetricRange.w:
        return ['Mon', 'Tue', 'Wed', 'Thu'];

      case MetricRange.m:
        return ['1', '8', '15', '22'];

      case MetricRange.m6:
        return ['Jan', 'Mar', 'May', 'Jul'];

      case MetricRange.y:
        return ['2021', '2022', '2023', '2024'];
    }
  }

  List<double> _mockValues() {
    final r = Random();
    return List.generate(12, (_) => 60 + r.nextInt(25) + r.nextDouble());
  }

  @override
  Widget build(BuildContext context) {
    final latest = _values.isNotEmpty ? _values.last : 0.0;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 10),
            _rangeTabs(),
            const SizedBox(height: 10),
            _rangeInfo(),
            const SizedBox(height: 12),
            _chartCard(),
            const SizedBox(height: 10),
            _latestRow(latest),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
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
    Widget tab(String label, MetricRange r) {
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
            label,
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
            tab('H', MetricRange.h),
            tab('D', MetricRange.d),
            tab('W', MetricRange.w),
            tab('M', MetricRange.m),
            tab('6M', MetricRange.m6),
            tab('Y', MetricRange.y),
          ],
        ),
      ),
    );
  }

  // ===== RANGE INFO =====
  Widget _rangeInfo() {
    const subtitles = {
      MetricRange.h: 'Today, 16 - 17',
      MetricRange.d: 'Today',
      MetricRange.w: 'This week',
      MetricRange.m: 'This month',
      MetricRange.m6: 'Last 6 months',
      MetricRange.y: 'This year',
    };

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
                  '${widget.minDisplay} – ${widget.maxDisplay}',
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
            Text(
              subtitles[_range]!,
              style: const TextStyle(
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

  // ===== CHART CARD =====
  Widget _chartCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 240,
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
                      painter: _MiniBarChartPainter(
                        values: _values,
                        accent: widget.accent,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('100', style: _axisTextStyle),
                      Text('50', style: _axisTextStyle),
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
  Widget _latestRow(double latest) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Text(
              'Latest: 16:30',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '${latest.toStringAsFixed(0)} ${widget.unit}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CHART PAINTER (GIỮ NGUYÊN LOGIC CŨ) =====
class _MiniBarChartPainter extends CustomPainter {
  _MiniBarChartPainter({required this.values, required this.accent});

  final List<double> values;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = const Color(0x11000000)
      ..strokeWidth = 1;

    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (values.isEmpty) return;

    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);

    final paint = Paint()..color = accent;
    final n = values.length;
    const gap = 6.0;
    final barW = (size.width - gap * (n - 1)) / n;

    for (int i = 0; i < n; i++) {
      final norm = (values[i] - minV) / range;
      final barH = 10 + norm * (size.height - 18);
      final left = i * (barW + gap);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, size.height - barH, barW, barH),
          const Radius.circular(3),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBarChartPainter old) =>
      old.values != values || old.accent != accent;
}
