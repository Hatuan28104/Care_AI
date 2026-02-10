import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'report_detail_screen.dart';

class DependentProfileScreen extends StatefulWidget {
  final String quanHeId;

  const DependentProfileScreen({
    super.key,
    required this.quanHeId,
  });

  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1877F2);
  static const Color _bg = Color(0xFFF6F6F6);

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
            Expanded(child: _ReportItem(label: 'Ngày', type: 'day')),
            SizedBox(width: 12),
            Expanded(child: _ReportItem(label: 'Tuần', type: 'week')),
            SizedBox(width: 12),
            Expanded(child: _ReportItem(label: 'Tháng', type: 'month')),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF1F41BB).withOpacity(0.5),
          width: 1,
        ),
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
  final String type;

  const _ReportItem({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(type: type),
          ),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF1F41BB).withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F41BB).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 18),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
