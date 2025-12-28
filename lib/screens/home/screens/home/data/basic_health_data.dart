import 'package:flutter/material.dart';
import 'metric_item.dart';
import 'metric_detail.dart';

class BasicHealthDataScreen extends StatelessWidget {
  const BasicHealthDataScreen({
    super.key,
    required this.items,
    this.isLoading = false,
  });

  final List<MetricItem> items;
  final bool isLoading;

  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context, 'Basic health data'),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(child: Text('No data yet'))
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _tile(context, items[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _blue.withOpacity(.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Today',
              style: TextStyle(color: _blue, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Helpers: lấy min/max demo từ value =====
  String _extractFirstNumber(String s) {
    // lấy số đầu tiên trong chuỗi (72, 36.8, "120 / 80" -> 120)
    final m = RegExp(r'(\d+(\.\d+)?)').firstMatch(s);
    return m?.group(1) ?? '--';
  }

  // ===== Tile clickable -> mở màn chi tiết =====
  Widget _tile(BuildContext context, MetricItem m) {
    final minD = _extractFirstNumber(m.value);
    // demo: max = min + 2 nếu parse được, còn không thì "--"
    String maxD = '--';
    final parsed = double.tryParse(minD);
    if (parsed != null) {
      maxD = (parsed + 2).toStringAsFixed(parsed % 1 == 0 ? 0 : 1);
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MetricDetailScreen(
              title: m.title,
              unit: m.unit,
              minDisplay: minD,
              maxDisplay: maxD,
              accent: m.iconColor, // lấy màu theo item
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: m.iconColor.withOpacity(.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(m.icon, color: m.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
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
            ),
            const SizedBox(width: 10),
            Text(
              m.time,
              style: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
