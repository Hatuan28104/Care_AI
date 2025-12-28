import 'dart:math';
import 'package:flutter/material.dart';

enum MetricRange { h, d, w, m, m6, y }

class MetricDetailScreen extends StatefulWidget {
  const MetricDetailScreen({
    super.key,
    required this.title,
    required this.unit,
    required this.minDisplay,
    required this.maxDisplay,
    this.accent = const Color(0xFF00BCD4), // màu cột giống hình
  });

  final String title; // "Heart rate"
  final String unit; // "BPM"
  final String minDisplay; // "72"
  final String maxDisplay; // "74"
  final Color accent;

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  static const _bg = Color(0xFFF3F5F9);

  MetricRange _range = MetricRange.h;

  // demo data (sau này thay bằng data backend)
  late List<double> _values;

  @override
  void initState() {
    super.initState();
    _values = _mockValues();
  }

  List<double> _mockValues() {
    final r = Random();
    // 12 điểm theo giờ (demo)
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
            _header(context),
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
              child: Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  // ===== TABS H D W M 6M Y =====
  Widget _rangeTabs() {
    Widget tab(String t, MetricRange r) {
      final active = _range == r;
      return GestureDetector(
        onTap: () {
          setState(() {
            _range = r;
            _values = _mockValues(); // demo: đổi range -> đổi data
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Colors.white : const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(8),
            border: active ? Border.all(color: Colors.black12) : null,
          ),
          child: Text(
            t,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: active ? Colors.black : Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tab('H', MetricRange.h),
          tab('D', MetricRange.d),
          tab('W', MetricRange.w),
          tab('M', MetricRange.m),
          tab('6M', MetricRange.m6),
          tab('Y', MetricRange.y),
        ],
      ),
    );
  }

  // ===== RANGE + SUBTITLE =====
  Widget _rangeInfo() {
    // demo text theo hình
    final subtitle = _range == MetricRange.h
        ? 'Today, 16 - 17'
        : _range == MetricRange.d
            ? 'Today'
            : _range == MetricRange.w
                ? 'This week'
                : _range == MetricRange.m
                    ? 'This month'
                    : _range == MetricRange.m6
                        ? 'Last 6 months'
                        : 'This year';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RANGE',
              style: TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${widget.minDisplay} – ${widget.maxDisplay}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    widget.unit,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 170,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
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
            const SizedBox(height: 8),
            // x-axis labels demo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('16:00',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w700)),
                Text('16:15',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w700)),
                Text('16:30',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w700)),
                Text('16:45',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black45,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===== LATEST ROW =====
  Widget _latestRow(double latest) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black54,
              ),
            ),
            const Spacer(),
            Text(
              '${latest.toStringAsFixed(0)} ${widget.unit}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CUSTOM PAINTER (mini bar chart giống hình) =====
class _MiniBarChartPainter extends CustomPainter {
  _MiniBarChartPainter({required this.values, required this.accent});

  final List<double> values;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0x11000000)
      ..strokeWidth = 1;

    // grid dọc 4 cột
    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
    // grid ngang 2 dòng
    for (int i = 1; i < 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    if (values.isEmpty) return;

    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final range = (maxV - minV).abs() < 0.0001 ? 1.0 : (maxV - minV);

    final barPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final n = values.length;
    final gap = 6.0;
    final barW = (size.width - gap * (n - 1)) / n;
    for (int i = 0; i < n; i++) {
      final v = values[i];
      final norm = (v - minV) / range;
      final barH = 10 + norm * (size.height - 18); // giống kiểu cột ngắn
      final left = i * (barW + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, size.height - barH, barW, barH),
        const Radius.circular(3),
      );
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBarChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.accent != accent;
  }
}
