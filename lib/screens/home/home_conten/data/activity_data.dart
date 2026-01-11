import 'package:flutter/material.dart';
import 'activity_item.dart';
import 'activity_detail.dart';

class ActivityDataScreen extends StatelessWidget {
  const ActivityDataScreen({super.key});

  static const Color _blue = Color(0xFF1F6BFF);
  static const Color _bg = Color(0xFFF3F5F9);

  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(18, 2, 18, 18);
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(10));

  // ===== DEMO DATA (TỰ QUẢN – KHÔNG DÍNH HOME) =====
  static final List<ActivityItem> _items = [
    ActivityItem(
      icon: Icons.directions_walk,
      iconColor: Colors.red,
      title: 'Steps',
      value: 600,
      unit: 'steps',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.route,
      iconColor: Colors.orange,
      title: 'Walking + Running Distance',
      value: 3,
      unit: 'km',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.bedtime,
      iconColor: Colors.indigo,
      title: 'Sleep duration',
      value: 7,
      unit: 'hours',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.auto_graph,
      iconColor: Colors.blue,
      title: 'Sleep quality',
      value: 85,
      unit: '%',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.local_fire_department,
      iconColor: Colors.purple,
      title: 'Exercise level',
      value: 50,
      unit: 'minutes',
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
                      padding: _listPadding,
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
                  'Activity data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 34),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Today',
            style: TextStyle(
              color: _blue,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ===== TILE =====
  Widget _tile(BuildContext context, ActivityItem m) {
    return InkWell(
      borderRadius: _cardRadius,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActivityDetailScreen(
              title: m.title,
              unit: m.unit,
              value: m.value,
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

  Widget _iconBox(ActivityItem m) {
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

  Widget _content(ActivityItem m) {
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
                m.value.toString(),
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
