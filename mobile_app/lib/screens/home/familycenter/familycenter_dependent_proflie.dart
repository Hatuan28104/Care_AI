import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';

class DependentProfileScreen extends StatefulWidget {
  final String quanHeId;

  const DependentProfileScreen({
    super.key,
    required this.quanHeId,
  });

  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1877F2);
  static const Color _bg = Color(0xFFF6F6F6);
  static const Color _itemBg = Color(0xFFF6F7FB);

  @override
  State<DependentProfileScreen> createState() => _DependentProfileScreenState();
}

class _DependentProfileScreenState extends State<DependentProfileScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await FamilyApi.getRelationshipProfile(widget.quanHeId);

      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ================= FORMAT HELPERS =================
  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.parse(iso);
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  String _genderText(dynamic g) {
    if (g == true) return 'Nam';
    if (g == false) return 'Nữ';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DependentProfileScreen._bg,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Column(
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
    final avatar = FamilyApi.normalizeAvatar(data?['AvatarUrl']);

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
          backgroundImage: avatar != null && avatar.toString().isNotEmpty
              ? NetworkImage(avatar)
              : null,
          child: avatar == null ? const Icon(Icons.person, size: 42) : null,
        ),
        const SizedBox(height: 12),
        Text(
          data?['TenND'] ?? '',
          style: const TextStyle(
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
        _infoItem('Họ và tên', data?['TenND']),
        _infoItem(
          'Ngày sinh',
          _formatDate(data?['NgaySinh']),
        ),
        _infoItem(
          'Giới tính',
          _genderText(data?['GioiTinh']),
        ),
        _infoItem(
          'Ngày tham gia',
          _formatDate(data?['NgayBatDau']),
        ),
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
          children: const [
            Expanded(child: _ReportItem(label: 'Ngày')),
            SizedBox(width: 12),
            Expanded(child: _ReportItem(label: 'Tuần')),
            SizedBox(width: 12),
            Expanded(child: _ReportItem(label: 'Tháng')),
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
        color: DependentProfileScreen._itemBg,
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
}

// ================= REPORT ITEM =================
class _ReportItem extends StatelessWidget {
  final String label;
  const _ReportItem({required this.label});

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.bar_chart,
                  size: 18, color: DependentProfileScreen._blue),
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
