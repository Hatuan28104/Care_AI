import 'package:flutter/material.dart';
import 'package:Care_AI/models/health_icon_mapper.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'package:Care_AI/api/health_api.dart';
import 'metric_item.dart';
import 'metric_detail.dart';
import 'dart:async';

class ActivityDataScreen extends StatefulWidget {
  const ActivityDataScreen({super.key});

  @override
  State<ActivityDataScreen> createState() => _ActivityDataScreenState();
}

class _ActivityDataScreenState extends State<ActivityDataScreen> {
  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(18, 2, 18, 18);
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(10));

  final TextEditingController _searchCtrl = TextEditingController();
  String _keyword = '';

  List<MetricItem> _items = [];
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _initData();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      await _loadLatestActivityData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initData() async {
    await _loadMetrics();
    await _loadLatestActivityData();
  }

  /// =========================
  /// LOAD METRICS
  /// =========================
  Future<void> _loadMetrics() async {
    try {
      final data = await HealthApi.getMetrics();

      final items = data.where((e) => e['loai'] == 'activity').map<MetricItem>((
        e,
      ) {
        final iconData = getHealthIcon(e['tenchiso']);

        return MetricItem(
          metricId: (e['loaichiso_id'] ?? '').toString(),
          code: (e['code'] ?? '').toString(),
          icon: iconData.icon,
          iconColor: iconData.color,
          title: e['tenchiso'],
          value: '--',
          unit: e['donvido'],
          time: '--:--',
        );
      }).toList();

      setState(() {
        _items = items;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// =========================
  /// LOAD LATEST DATA
  /// =========================
  Future<void> _loadLatestActivityData() async {
    try {
      final data = await HealthApi.getLatestHealthDataByUser();

      // Sort newest first
      data.sort((a, b) {
        try {
          final timeA = DateTime.parse((a['thoigiancapnhat'] ?? '').toString());
          final timeB = DateTime.parse((b['thoigiancapnhat'] ?? '').toString());
          return timeB.compareTo(timeA);
        } catch (_) {
          return 0;
        }
      });

      if (!mounted) return;

      setState(() {
        /// 🔥 Map lấy giá trị mới nhất (O(n))
        final latestMap = <String, dynamic>{};

        for (var d in data) {
          final id = d['loaichiso_id']?.toString() ?? '';
          if (id.isEmpty) continue;

          if (!latestMap.containsKey(id)) {
            latestMap[id] = d;
          }
        }

        /// 🔥 Gán vào UI
        for (var item in _items) {
          final m = latestMap[item.metricId];

          if (m != null) {
            final raw = m['giatri'];

            /// 👉 FIX crash + format đẹp
            final numValue = double.tryParse(raw.toString());

            if (numValue != null) {
              item.value = numValue
                  .toStringAsFixed(5)
                  .replaceAll(RegExp(r'0+$'), '')
                  .replaceAll(RegExp(r'\.$'), '');
            } else {
              item.value = '--';
            }

            /// 👉 time
            try {
              final t = DateTime.parse(m['thoigiancapnhat']).toLocal();
              item.time =
                  "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
            } catch (_) {
              item.time = '--:--';
            }
          } else {
            item.value = '--';
            item.time = '--:--';
          }
        }
      });
    } catch (e) {
      debugPrint("[Activity] Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((e) {
      return e.title.toLowerCase().contains(_keyword.toLowerCase());
    }).toList()
      ..sort((a, b) {
        final aHasValue = a.value != '--';
        final bHasValue = b.value != '--';

        if (aHasValue && !bHasValue) return -1;
        if (!aHasValue && bHasValue) return 1;
        return 0;
      });

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.activityData),
            _searchBox(),
            Expanded(
              child: filteredItems.isEmpty
                  ? const SizedBox()
                  : ListView.separated(
                      padding: _listPadding,
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _tile(context, filteredItems[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// SEARCH
  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) {
          setState(() => _keyword = v);
        },
        decoration: InputDecoration(
          hintText: context.tr.searchData,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// TILE
  Widget _tile(BuildContext context, MetricItem m) {
    return InkWell(
      borderRadius: _cardRadius,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MetricDetailScreen(
              title: m.title,
              deviceId: "",
              metricId: m.metricId,
              accent: m.iconColor,
              unit: m.unit,
            ),
          ),
        ).then((_) {
          _loadLatestActivityData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _cardRadius,
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            _iconBox(m),
            const SizedBox(width: 10),
            _content(m),
            const SizedBox(width: 10),
            _time(m.time),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(MetricItem m) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: m.iconColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(m.icon, color: m.iconColor, size: 20),
    );
  }

  Widget _content(MetricItem m) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            m.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          Row(
            children: [
              Text(
                m.value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                m.unit,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _time(String t) {
    return Text(
      t,
      style: const TextStyle(
        color: Colors.black45,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
