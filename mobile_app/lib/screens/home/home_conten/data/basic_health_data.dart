import 'package:flutter/material.dart';
import 'basic_health_item.dart';
import 'basic_health_detail.dart';

class BasicHealthDataScreen extends StatelessWidget {
  const BasicHealthDataScreen({super.key});

  static const Color _bg = Color(0xFFF6F6F6);

  static const EdgeInsets _pagePadding = EdgeInsets.fromLTRB(18, 2, 18, 18);
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(10));

  // ===== DEMO DATA (TỰ QUẢN – KHÔNG DÍNH HOME) =====
  static final List<BasicHealthItem> _items = [
    BasicHealthItem(
      icon: Icons.favorite,
      iconColor: Colors.red,
      title: 'Heart rate',
      value: '72',
      unit: 'BPM',
      time: '18:30',
    ),
    BasicHealthItem(
      icon: Icons.bloodtype,
      iconColor: Colors.blue,
      title: 'Blood pressure',
      value: '120 / 80',
      unit: 'mmHg',
      time: '18:30',
    ),
    BasicHealthItem(
      icon: Icons.monitor_heart,
      iconColor: Colors.indigo,
      title: 'Blood oxygen - SpO₂',
      value: '98',
      unit: '%',
      time: '18:30',
    ),
    BasicHealthItem(
      icon: Icons.thermostat,
      iconColor: Colors.orange,
      title: 'Body temperature',
      value: '36.8',
      unit: '°C',
      time: '18:30',
    ),
    BasicHealthItem(
      icon: Icons.fitness_center,
      iconColor: Colors.purple,
      title: 'BMI',
      value: '21.5',
      unit: 'kg/m²',
      time: '18:30',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No data yet'))
                  : ListView.separated(
                      padding: _pagePadding,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _tile(context, items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const Expanded(
                child: Text(
                  'Dữ liệu hoạt động',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 34),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ===== TILE =====
  Widget _tile(BuildContext context, BasicHealthItem m) {
    final minD = _firstNumber(m.value);
    final maxD = _calcMax(minD);

    return InkWell(
      borderRadius: _cardRadius,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BasicHealthDetailScreen(
              title: m.title,
              unit: m.unit,
              minDisplay: minD,
              maxDisplay: maxD,
              accent: m.iconColor,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
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

  Widget _iconBox(BasicHealthItem m) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: m.iconColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(m.icon, color: m.iconColor, size: 20),
    );
  }

  Widget _content(BasicHealthItem m) {
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

  // ===== HELPERS =====
  static String _firstNumber(String s) {
    final m = RegExp(r'(\d+(\.\d+)?)').firstMatch(s);
    return m?.group(1) ?? '--';
  }

  static String _calcMax(String minD) {
    final v = double.tryParse(minD);
    if (v == null) return '--';
    return (v + 2).toStringAsFixed(v % 1 == 0 ? 0 : 1);
  }
}
