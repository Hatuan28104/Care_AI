import 'package:flutter/material.dart';
import 'package:Care_AI/api/health_api.dart';
import 'package:Care_AI/models/metric_config.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'package:Care_AI/models/tr.dart';

const TextStyle _axisTextStyle = TextStyle(
  fontSize: 11,
  color: Colors.black45,
  fontWeight: FontWeight.w600,
);

enum MetricRange { d, w, m, m6 }

class MetricDetailScreen extends StatefulWidget {
  const MetricDetailScreen({
    super.key,
    required this.title,
    required this.deviceId,
    required this.metricId,
    required this.unit,
    this.accent = const Color(0xFF00BCD4),
  });
  final String unit;
  final String title;
  final String deviceId;
  final String metricId;
  final Color accent;

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen> {
  MetricRange _range = MetricRange.d;
  List<double> _values = [];
  List<String> _labels = [];

  MetricConfig get _config =>
      metricConfigs[widget.metricId.trim()] ??
      const MetricConfig(min: 0, max: 100, unit: "", divisions: 4);

  double get _minY =>
      _values.isEmpty ? 0 : _values.reduce((a, b) => a < b ? a : b);

  double get _maxY =>
      _values.isEmpty ? 100 : _values.reduce((a, b) => a > b ? a : b);
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
      final data = await HealthApi.getHealthHistoryByUser(
        widget.metricId,
        _range.name,
      );

      debugPrint("DETAIL KEY: ${widget.metricId}");
      debugPrint("DATA LENGTH: ${data.length}");

      if (data.isEmpty) {
        setState(() {
          _values = [];
          _labels = [];
        });
        return;
      }

      // 🔥 GROUP + FILTER
      Map<String, Map<String, dynamic>> grouped = {};

      for (var e in data) {
        final raw = e['thoigiancapnhat'];
        if (raw == null) continue;

        final t = DateTime.tryParse(raw.toString());
        if (t == null) continue;

        String key;

        if (_range == MetricRange.d) {
          key = "${t.hour}";
        } else {
          key = "${t.year}-${t.month}-${t.day}";
        }

        if (!grouped.containsKey(key) ||
            DateTime.parse(e['thoigiancapnhat']).isAfter(
              DateTime.parse(grouped[key]!['thoigiancapnhat']),
            )) {
          grouped[key] = e;
        }
      }

      if (grouped.isEmpty) {
        setState(() {
          _values = [];
          _labels = [];
        });
        return;
      }

      // 🔥 SORT
      final sorted = grouped.values.toList()
        ..sort((a, b) {
          final ta =
              DateTime.tryParse(a['thoigiancapnhat'] ?? '') ?? DateTime(0);
          final tb =
              DateTime.tryParse(b['thoigiancapnhat'] ?? '') ?? DateTime(0);
          return ta.compareTo(tb);
        });

      // 🔥 VALUES
      final values = sorted
          .map<double>((e) => ((e['giatri'] ?? 0) as num).toDouble())
          .toList();

      // 🔥 LABELS
      final labels = sorted.map<String>((e) {
        final t = DateTime.parse(e['thoigiancapnhat']);

        if (_range == MetricRange.d) {
          return "${t.hour}h";
        } else {
          return "${t.day}/${t.month}";
        }
      }).toList();

      setState(() {
        _values = values;
        _labels = labels;
      });
    } catch (e) {
      debugPrint("DETAIL ERROR: $e");
    }
  }

  void _openInputDialog() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${context.tr.enter} ${widget.title}"),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: context.tr.enterValue,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(ctrl.text);
              if (value == null) return;

              try {
                final payload = {
                  widget.metricId: value,
                };

                debugPrint("Save payload: $payload");

                await HealthApi.saveMultipleHealthData(payload);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr.saved)),
                );

                await _loadData();
              } catch (e) {
                debugPrint("Save error: $e");
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Lỗi: ${e.toString()}")),
                );
              }
            },
            child: Text(context.tr.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _values.isNotEmpty;
    final latest = hasData ? _values.last : null;
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: widget.title),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            tab('D', MetricRange.d),
            tab('W', MetricRange.w),
            tab('M', MetricRange.m),
            tab('6M', MetricRange.m6),
          ],
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
              // 🔥 ROW 1: "Giá trị" + "Thêm dữ liệu"
              Row(
                children: [
                  Text(
                    context.tr.value,
                    style: TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _openInputDialog,
                    child: Text(
                      context.tr.addData,
                      style: TextStyle(
                        color: const Color(0xFF1877F2),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // 🔥 ROW 2: VALUE
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    latest != null
                        ? latest % 1 == 0
                            ? latest.toStringAsFixed(0)
                            : latest.toStringAsFixed(1)
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
            ],
          )),
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
                    children: List.generate(_config.divisions + 1, (i) {
                      final value = _maxY - (i * (_rangeY / _config.divisions));

                      return Text(
                        value.toStringAsFixed(_config.decimals),
                        style: _axisTextStyle,
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _labels
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(e, style: _axisTextStyle),
                      ),
                    )
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
                  ? '${latest % 1 == 0 ? latest.toStringAsFixed(0) : latest.toStringAsFixed(1)} ${widget.unit}'
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
