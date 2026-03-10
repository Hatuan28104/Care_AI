import 'package:flutter/material.dart';
import 'package:Care_AI/api/health_api.dart';
import 'package:Care_AI/models/health_icon_mapper.dart';
import 'metric_item.dart';
import 'metric_detail.dart';
import '../../../../models/tr.dart';

class BasicHealthDataScreen extends StatefulWidget {
  const BasicHealthDataScreen({super.key});

  @override
  State<BasicHealthDataScreen> createState() => _BasicHealthDataScreenState();
}

class _BasicHealthDataScreenState extends State<BasicHealthDataScreen> {
  static const Color _bg = Color(0xFFF6F6F6);
  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(18, 2, 18, 18);
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(10));

  final TextEditingController _searchCtrl = TextEditingController();
  String _keyword = '';

  String? _deviceId;

  List<MetricItem> _items = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  /// =========================
  /// INIT
  /// =========================
  Future<void> _initData() async {
    await _loadMetrics();
    await _loadDevice();
  }

  /// =========================
  /// LOAD DEVICE
  /// =========================
  Future<void> _loadDevice() async {
    try {
      _deviceId = "DEVICE001"; // test device

      if (_deviceId != null && _items.isNotEmpty) {
        await _loadLatestHealthData();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// =========================
  /// LOAD METRICS
  /// =========================
  Future<void> _loadMetrics() async {
    try {
      final data = await HealthApi.getMetrics();

      final items =
          data.where((e) => e['Category'] == 'health').map<MetricItem>((e) {
        final iconData = getHealthIcon(e['TenChiSo']);

        return MetricItem(
          icon: iconData.icon,
          iconColor: iconData.color,
          title: e['TenChiSo'],
          value: '--',
          unit: e['DonViDo'],
          time: '--:--',
        );
      }).toList();

      setState(() {
        _items = items;
      });
    } catch (e) {
      debugPrint('Load metrics error: $e');
    }
  }

  /// =========================
  /// LOAD LATEST DATA
  /// =========================
  Future<void> _loadLatestHealthData() async {
    try {
      final data = await HealthApi.getLatestHealthData(_deviceId!);

      setState(() {
        for (var item in _items) {
          final match = data.where((e) => e['TenChiSo'] == item.title);

          if (match.isNotEmpty) {
            final m = match.first;

            item.value = m['GiaTri'].toString();
            item.time = m['ThoiGian'] ?? '--:--';
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _items.where((e) {
      return e.title.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _searchBox(),
            Expanded(
              child: filteredItems.isEmpty
                  ? const SizedBox()
                  : ListView.separated(
                      padding: _listPadding,
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _tile(context, filteredItems[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// HEADER
  /// =========================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.tr.healthData,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 34),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  /// =========================
  /// SEARCH
  /// =========================
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
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// TILE
  /// =========================
  Widget _tile(BuildContext context, MetricItem m) {
    return InkWell(
      borderRadius: _cardRadius,
      onTap: () {
        if (_deviceId == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MetricDetailScreen(
              title: m.title,
              deviceId: _deviceId!,
              metricId: m.title,
              accent: m.iconColor,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _cardRadius,
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            _iconBox(m),
            const SizedBox(width: 12),
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
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                m.value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                m.unit,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
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
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
