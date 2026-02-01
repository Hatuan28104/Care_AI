import 'package:flutter/material.dart';
import 'activity_item.dart';
import 'activity_detail.dart';

class ActivityDataScreen extends StatefulWidget {
  const ActivityDataScreen({super.key});

  @override
  State<ActivityDataScreen> createState() => _ActivityDataScreenState();
}

class _ActivityDataScreenState extends State<ActivityDataScreen> {
  static const Color _bg = Color(0xFFF6F6F6);
  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(18, 2, 18, 18);
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(10));

  final TextEditingController _searchCtrl = TextEditingController();
  String _keyword = '';

  // ===== DEMO DATA =====
  final List<ActivityItem> _items = [
    ActivityItem(
      icon: Icons.directions_walk,
      iconColor: Colors.red,
      title: 'Số bước',
      value: 600,
      unit: 'bước',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.route,
      iconColor: Colors.orange,
      title: 'Quãng đường đi bộ + chạy',
      value: 3,
      unit: 'km',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.bedtime,
      iconColor: Colors.indigo,
      title: 'Thời gian ngủ',
      value: 7,
      unit: 'giờ',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.auto_graph,
      iconColor: Colors.blue,
      title: 'Chất lượng giấc ngủ',
      value: 85,
      unit: '%',
      time: '18:30',
    ),
    ActivityItem(
      icon: Icons.local_fire_department,
      iconColor: Colors.purple,
      title: 'Thời gian vận động',
      value: 50,
      unit: 'phút',
      time: '18:30',
    ),
  ];

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
                  ? const Center(child: Text('Không có dữ liệu'))
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

  // ===== HEADER =====
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
          const Expanded(
            child: Text(
              'Dữ liệu sức khỏe',
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

  // ===== SEARCH =====
  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) {
          setState(() => _keyword = v);
        },
        decoration: InputDecoration(
          hintText: 'Tìm kiếm dữ liệu...',
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

  Widget _iconBox(ActivityItem m) {
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
