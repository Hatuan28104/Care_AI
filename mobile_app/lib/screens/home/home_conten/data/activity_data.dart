import 'package:flutter/material.dart';
import 'package:Care_AI/models/health_icon_mapper.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'package:Care_AI/api/health_api.dart';
import 'metric_item.dart';
import 'metric_detail.dart';

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

  @override
  void initState() {
    super.initState();
    _initData();
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
      debugPrint("[Activity] Raw data length: ${data.length}");
      for (var d in data) {
        debugPrint(
            "[Activity] Data: ${d['loaichiso_id']} = ${d['giatri']} @ ${d['thoigiancapnhat']}");
      }

      data.sort((a, b) {
        try {
          final timeA = DateTime.parse((a['thoigiancapnhat'] ?? '').toString());
          final timeB = DateTime.parse((b['thoigiancapnhat'] ?? '').toString());
          return timeB.compareTo(timeA);
        } catch (_) {
          return 0;
        }
      });

      setState(() {
        for (var item in _items) {
          final match = data.where((e) => e['loaichiso_id'] == item.metricId);
          debugPrint(
              "[Activity] Item ${item.metricId}: match count = ${match.length}");

          if (match.isNotEmpty) {
            final m = match.first;

            item.value = (m['giatri'] ?? '--').toString();

            final timeRaw = (m['thoigiancapnhat'] ?? '').toString();
            try {
              if (timeRaw.isNotEmpty) {
                final t = DateTime.parse(timeRaw);
                item.time =
                    "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
              } else {
                item.time = '--:--';
              }
            } catch (_) {
              item.time = '--:--';
            }
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
    }).toList();

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
            ),
          ),
        );
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
