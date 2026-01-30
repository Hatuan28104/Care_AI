import 'package:flutter/material.dart';

class DependentProfileScreen extends StatelessWidget {
  const DependentProfileScreen({super.key});

  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1877F2);
  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _itemBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _profileHeader(context),
            const SizedBox(height: 16),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================
  Widget _profileHeader(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 52,
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1527980965255-d3b416303d12',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Rober Joshon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        _infoItem('Họ và tên', 'Rober Joshon'),
        _infoItem('Ngày sinh', '20/01/1978'),
        _infoItem('Giới tính', 'Male'),
        _infoItem('Ngày tham gia', '23/09/2025'),
        const SizedBox(height: 8),
        const Text(
          'Báo cáo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _reportItem('Ngày')),
            const SizedBox(width: 12),
            Expanded(child: _reportItem('Tuần')),
            const SizedBox(width: 12),
            Expanded(child: _reportItem('Tháng')),
          ],
        ),
      ],
    );
  }

  // ================= INFO ITEM =================
  Widget _infoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _itemBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= REPORT ITEM =================
  static Widget _reportItem(String label) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.bar_chart, size: 18, color: Colors.grey),
              SizedBox(width: 4),
              Icon(Icons.bar_chart, size: 18, color: _blue),
              SizedBox(width: 4),
              Icon(Icons.bar_chart, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
