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

    if (_range == MetricRange.m6) {
      final start = DateTime(now.year, now.month - 5);
      return "${start.month}/${start.year} - ${now.month}/${now.year}";
    }

    return "";
  }

  String _weekdayLabel(int weekday) {
    const days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    return days[weekday - 1];
  }

  double _v(e) => (e != null && e.isNotEmpty)
      ? (e['giatri'] as num?)?.toDouble() ?? -1
      : -1;
  /* =========================
     LOAD DATA
  ========================= */
  Future<void> _loadData() async {
    try {
      final data = await HealthApi.getHealthHistoryByUser(
        widget.metricId,
        _range.name,
      );
      double? latest;

      data.sort((a, b) {
        final t1 = DateTime.parse(a['thoigiancapnhat']);
        final t2 = DateTime.parse(b['thoigiancapnhat']);
        return t2.compareTo(t1);
      });

      for (var e in data) {
        final v = (e['giatri'] as num?)?.toDouble();
        if (v != null) {
          latest = v;
          break;
        }
      }
      debugPrint("DETAIL KEY: ${widget.metricId}");
      debugPrint("DATA LENGTH: ${data.length}");

      if (data.isEmpty) {
        setState(() {
          _values = [];
          _labels = [];
        });
        return;
      }

      Map<String, List<double>> grouped = {};
      if (_range == MetricRange.d) {
        grouped = {"0": [], "6": [], "12": [], "18": []};
      } else if (_range == MetricRange.w) {
        grouped = {
          "1": [],
          "2": [],
          "3": [],
          "4": [],
          "5": [],
          "6": [],
          "7": []
        };
      } else if (_range == MetricRange.m) {
        grouped = {"0": [], "1": [], "2": [], "3": [], "4": []};
      } else if (_range == MetricRange.m6) {
        grouped = {
          "1": [],
          "2": [],
          "3": [],
          "4": [],
          "5": [],
          "6": [],
          "7": [],
          "8": [],
          "9": [],
          "10": [],
          "11": [],
          "12": []
        };
      }
      for (var e in data) {
        final raw = e['thoigiancapnhat'];
        if (raw == null) continue;

        final t = DateTime.tryParse(raw.toString())?.toLocal();
        if (t == null) continue;

        String key;

        if (_range == MetricRange.d) {
          int block = (t.hour ~/ 6) * 6;
          key = "$block";
        } else if (_range == MetricRange.w) {
          key = "${t.weekday}";
        } else if (_range == MetricRange.m) {
          int week = ((t.day - 1) ~/ 7);
          key = "$week";
        } else {
          key = "${t.month}";
        }

        final value = (e['giatri'] as num?)?.toDouble();
        if (value == null) continue;

        grouped.putIfAbsent(key, () => []);
        grouped[key]!.add(value);
      }

      if (grouped.isEmpty) {
        setState(() {
          _values = [];
          _labels = [];
        });
        return;
      }
      final values = <double>[];
      final labels = <String>[];
      double avg(List<double>? list) {
        if (list == null || list.isEmpty) return -1;
        return list.reduce((a, b) => a + b) / list.length;
      }

      if (_range == MetricRange.d) {
        for (var s in ["0", "6", "12", "18"]) {
          values.add(avg(grouped[s]));
          labels.add("${s}h");
        }
      } else if (_range == MetricRange.w) {
        final now = DateTime.now();
        for (int i = 6; i >= 0; i--) {
          final d = now.subtract(Duration(days: i));
          values.add(_v(grouped["${d.weekday}"]));
          labels.add(_weekdayLabel(d.weekday));
        }
      } else if (_range == MetricRange.m) {
        for (int i = 0; i < 5; i++) {
          values.add(_v(grouped["$i"]));
          labels.add("W${i + 1}");
        }
      } else {
        final now = DateTime.now();
        for (int i = 5; i >= 0; i--) {
          final m = DateTime(now.year, now.month - i).month;
          values.add(_v(grouped["$m"]));
          labels.add("$m");
        }
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
