import 'package:flutter/material.dart';
import 'package:Care_AI/api/health_api.dart';
import 'package:Care_AI/models/metric_config.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/services/time_service.dart';

const TextStyle _axisTextStyle = TextStyle(
  fontSize: 11,
  color: Colors.black45,
  fontWeight: FontWeight.w600,
);

enum MetricRange { d, w, m, y }

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
  int _loadVersion = 0;

  MetricConfig get _config =>
      metricConfigs[widget.metricId.trim()] ??
      const MetricConfig(min: 0, max: 100, unit: "", divisions: 4);
  double? _latestValue;
  double get _minY {
    if (_values.isEmpty) return 0;
    final valid = _values.where((e) => e >= 0);
    if (valid.isEmpty) return 0;
    return (valid.reduce((a, b) => a < b ? a : b) - 2)
        .clamp(0, double.infinity);
  }

  double get _maxY {
    final valid = _values.where((e) => e >= 0);
    if (valid.isEmpty) return 100;
    final max = valid.reduce((a, b) => a > b ? a : b);
    return max + 2;
  }

  double get _rangeY => _maxY - _minY;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _getDateLabel() {
    final now = DateTime.now();

    if (_range == MetricRange.d) {
      return context.tr.today;
    }

    if (_range == MetricRange.w) {
      final start = now.subtract(const Duration(days: 6));
      return "${start.day}/${start.month}/${start.year} - ${now.day}/${now.month}/${now.year}";
    }

    if (_range == MetricRange.m) {
      return "${context.tr.month} ${now.month}/${now.year}";
    }

    if (_range == MetricRange.y) {
      final start = DateTime(now.year - 1, now.month, now.day);
      return "${start.month}/${start.year} - ${now.month}/${now.year}";
    }

    return "";
  }

  String _weekdayLabel(int weekday) {
    const days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    return days[weekday - 1];
  }

  /* =========================
     LOAD DATA
  ========================= */
  Future<void> _loadData() async {
    final targetRange = _range;
    final requestVersion = ++_loadVersion;

    setState(() {
      _values = [];
      _labels = [];
    });

    try {
      final data = await HealthApi.getHealthHistoryByUser(
        widget.metricId,
        targetRange.name,
      );

      double? latest;
      data.sort((a, b) {
        final t1 = TimeService.toLocal((a['thoigiancapnhat'] ?? '').toString());
        final t2 = TimeService.toLocal((b['thoigiancapnhat'] ?? '').toString());
        return t2.compareTo(t1);
      });

      for (final e in data) {
        final v = (e['giatri'] as num?)?.toDouble();
        if (v != null) {
          latest = v;
          break;
        }
      }

      final values = <double>[];
      final labels = <String>[];
      final now = DateTime.now();

      double avg(List<double> list) {
        if (list.isEmpty) return -1;
        return list.reduce((a, b) => a + b) / list.length;
      }

      if (targetRange == MetricRange.d) {
        final grouped = List.generate(4, (_) => <double>[]);

        for (final e in data) {
          final raw = e['thoigiancapnhat'];
          if (raw == null) continue;
          final t = TimeService.toLocal(raw.toString());
          final value = (e['giatri'] as num?)?.toDouble();
          if (value == null) continue;

          final diffHours = now.difference(t).inHours;
          if (diffHours < 0 || diffHours >= 24) continue;

          final slotFromNow = diffHours ~/ 6;
          final bucket = 3 - slotFromNow;
          if (bucket >= 0 && bucket < 4) {
            grouped[bucket].add(value);
          }
        }

        const dayLabels = ["0h", "6h", "12h", "18h"];
        for (int i = 0; i < 4; i++) {
          values.add(avg(grouped[i]));
          labels.add(dayLabels[i]);
        }
      } else if (targetRange == MetricRange.w) {
        final grouped = List.generate(7, (_) => <double>[]);
        final nowDay = DateTime(now.year, now.month, now.day);

        for (final e in data) {
          final raw = e['thoigiancapnhat'];
          if (raw == null) continue;
          final t = TimeService.toLocal(raw.toString());
          final day = DateTime(t.year, t.month, t.day);
          final value = (e['giatri'] as num?)?.toDouble();
          if (value == null) continue;

          final diff = nowDay.difference(day).inDays;
          if (diff < 0 || diff >= 7) continue;

          final bucket = 6 - diff;
          grouped[bucket].add(value);
        }

        for (int i = 6; i >= 0; i--) {
          final d = now.subtract(Duration(days: i));
          final bucket = 6 - i;
          values.add(avg(grouped[bucket]));
          labels.add(_weekdayLabel(d.weekday));
        }
      } else if (targetRange == MetricRange.m) {
        final grouped = List.generate(5, (_) => <double>[]);
        final nowDay = DateTime(now.year, now.month, now.day);

        for (final e in data) {
          final raw = e['thoigiancapnhat'];
          if (raw == null) continue;
          final t = TimeService.toLocal(raw.toString());
          final day = DateTime(t.year, t.month, t.day);
          final value = (e['giatri'] as num?)?.toDouble();
          if (value == null) continue;

          final diff = nowDay.difference(day).inDays;
          if (diff < 0 || diff >= 30) continue;

          final bucket = (29 - diff) ~/ 6;
          grouped[bucket].add(value);
        }

        const monthLabels = ["1", "8", "15", "22", "30"];
        for (int i = 0; i < 5; i++) {
          values.add(avg(grouped[i]));
          labels.add(monthLabels[i]);
        }
      } else {
        final grouped = <int, List<double>>{
          1: <double>[],
          3: <double>[],
          6: <double>[],
          9: <double>[],
          12: <double>[],
        };

        for (final e in data) {
          final raw = e['thoigiancapnhat'];
          if (raw == null) continue;
          final t = TimeService.toLocal(raw.toString());
          final value = (e['giatri'] as num?)?.toDouble();
          if (value == null) continue;

          if (t.year != now.year) continue;

          int bucket;
          if (t.month <= 1) {
            bucket = 1;
          } else if (t.month <= 3) {
            bucket = 3;
          } else if (t.month <= 6) {
            bucket = 6;
          } else if (t.month <= 9) {
            bucket = 9;
          } else {
            bucket = 12;
          }

          grouped[bucket]!.add(value);
        }

        const yearLabels = [1, 3, 6, 9, 12];
        for (final m in yearLabels) {
          values.add(avg(grouped[m] ?? <double>[]));
          labels.add("$m");
        }
      }

      if (!mounted || requestVersion != _loadVersion || targetRange != _range) {
        return;
      }

      setState(() {
        _values = values;
        _labels = labels;
        _latestValue = latest;
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
    double? latest;

    for (int i = _values.length - 1; i >= 0; i--) {
      if (_values[i] >= 0) {
        latest = _values[i];
        break;
      }
    }
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
                  _latestRow(_latestValue),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              t,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: active ? Colors.black : Colors.black54,
              ),
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
            Expanded(child: tab(context.tr.day, MetricRange.d)),
            Expanded(child: tab(context.tr.week, MetricRange.w)),
            Expanded(child: tab(context.tr.month, MetricRange.m)),
            Expanded(child: tab(context.tr.year, MetricRange.y)),
          ],
        ),
      ),
    );
  }

  /* =========================
        VALUE
  ========================= */

  Widget _valueSection(double? latest) {
    final dateText = _getDateLabel();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 2),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
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
                      child: Container(),
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
            SizedBox(
              width: double.infinity,
              child: Row(
                children: List.generate(_labels.length, (i) {
                  return Expanded(
                    child: Center(
                      child: Text(_labels[i], style: _axisTextStyle),
                    ),
                  );
                }),
              ),
            )
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

    final slotW = size.width / n;

    final barW = slotW * 0.4;

    for (int i = 0; i < n; i++) {
      final v = values[i] < 0 ? minY : values[i];

      final norm = rangeY == 0 ? 1.0 : (v - minY) / rangeY;
      final barH = norm * size.height;
      final slotW = size.width / n;
      final left = i * slotW + (slotW - barW) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            left,
            (size.height - barH).clamp(0.0, size.height),
            barW,
            barH,
          ),
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
