import 'package:flutter/material.dart';
import 'package:demo_app/api/health_api.dart';
import 'package:demo_app/models/metric_config.dart';
import 'package:demo_app/widgets/app_header.dart';
import 'package:demo_app/models/tr.dart';

const TextStyle _axisTextStyle = TextStyle(
  fontSize: 11,
  color: Colors.black45,
  fontWeight: FontWeight.w600,
);

enum MetricRange { h, d, w, m, m6, y }

class MetricDetailScreen extends StatefulWidget {
  const MetricDetailScreen({
    super.key,
    required this.title,
    required this.deviceId,
    required this.metricId,
    this.accent = const Color(0xFF00BCD4),
  });

  final String title;
  final String deviceId;
  final String metricId;
  final Color accent;

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  static const _bg = Color(0xFFF6F6F6);

  MetricRange _range = MetricRange.h;

  List<double> _values = [];
  List<String> _labels = [];

  MetricConfig get _config =>
      metricConfigs[widget.metricId.trim()] ??
      const MetricConfig(
        min: 0,
        max: 100,
        unit: "",
        divisions: 4,
      );

  double get _minY => _config.min;
  double get _maxY => _config.max;
  double get _rangeY => _maxY - _minY;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /* =========================
     LOAD DATA
  ========================= */

  Future<void> _loadData() async {
    try {
      final data = await HealthApi.getHealthHistory(
        widget.deviceId,
        widget.metricId,
        _range.name,
      );

      final values =
          data
              .map<double>((e) => ((e['giatri'] ?? 0) as num).toDouble())
              .toList();

      final labels = data.map<String>((e) {
        final raw = (e['thoigiancapnhat'] ?? '').toString();
        if (raw.isEmpty) return '--:--';
        final t = DateTime.parse(raw);
        return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
      }).toList();

      setState(() {
        _values = values;
        _labels = labels;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _values.isNotEmpty;
    final latest = hasData ? _values.last : null;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: widget.title,
            ),
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  _rangeTabs(),
                  const SizedBox(height: 10),
                  _valueSection(latest),
                  const SizedBox(height: 12),
                  _chartCard(),
                  const SizedBox(height: 10),
                  _latestRow(latest),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* =========================
        RANGE TABS
  ========================= */

  Widget _rangeTabs() {
    Widget tab(String t, MetricRange r) {
      final active = _range == r;

      return GestureDetector(
        onTap: () {
          setState(() => _range = r);
          _loadData();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
      ),
    );
  }

  /* =========================
        VALUE
  ========================= */

  Widget _valueSection(double? latest) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr.value,
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
                  latest != null
                      ? latest.toStringAsFixed(_config.decimals)
                      : "--",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    _config.unit,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* =========================
        CHART
  ========================= */

  Widget _chartCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 260,
        padding: const EdgeInsets.all(12),
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
                      painter: _MetricBarPainter(
                        values: _values,
                        accent: widget.accent,
                        minY: _minY,
                        maxY: _maxY,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _config.divisions + 1,
                      (i) {
                        final value =
                            _maxY - (i * (_rangeY / _config.divisions));

                        return Text(
                          value.toStringAsFixed(_config.decimals),
                          style: _axisTextStyle,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _labels
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(e, style: _axisTextStyle),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* =========================
        LATEST
  ========================= */

  Widget _latestRow(double? latest) {
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
            Text(context.tr.latest),
            const Spacer(),
            Text(
              latest != null
                  ? '${latest.toStringAsFixed(_config.decimals)} ${_config.unit}'
                  : "--",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/* =========================
      CHART PAINTER
========================= */

class _MetricBarPainter extends CustomPainter {
  _MetricBarPainter({
    required this.values,
    required this.accent,
    required this.minY,
    required this.maxY,
  });

  final List<double> values;
  final Color accent;
  final double minY;
  final double maxY;

  double get rangeY => (maxY - minY) == 0 ? 1 : (maxY - minY);
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()..color = accent;

    final n = values.length;
    const gap = 8.0;
    final barW = (size.width - gap * (n - 1)) / n;
    for (int i = 0; i < n; i++) {
      final v = values[i].clamp(minY, maxY);

      final norm = (v - minY) / rangeY;
      final barH = norm * size.height;

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
  bool shouldRepaint(covariant _MetricBarPainter old) =>
      old.values != values ||
      old.accent != accent ||
      old.minY != minY ||
      old.maxY != maxY;
}
