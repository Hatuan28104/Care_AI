import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'familycenter_configure_permissions.dart';

class GuardianProfile extends StatefulWidget {
  final String quanHeId;

  const GuardianProfile({
    super.key,
    required this.quanHeId,
  });

  @override
  State<GuardianProfile> createState() => _GuardianProfileState();
}

class _GuardianProfileState extends State<GuardianProfile> {
  static const Color blue = Color(0xFF1877F2);
  static const Color bg = Color(0xFFF6F6F6);
  static const Color itemBg = Color(0xFFF6F7FB);

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
      backgroundColor: bg,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Column(
                    children: [
                      _profileHeader(context),
                      const SizedBox(height: 18),
                      _infoSection(context),
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
        const SizedBox(height: 6),
        CircleAvatar(
          radius: 44,
          backgroundImage: avatar != null && avatar.toString().isNotEmpty
              ? NetworkImage(avatar)
              : null,
          child: avatar == null ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(height: 14),
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

  // ================= INFO SECTION =================
  Widget _infoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          _infoItem('Họ và tên', data?['TenND']),
          _infoItem('Ngày sinh', _formatDate(data?['NgaySinh'])),
          _infoItem('Giới tính', _genderText(data?['GioiTinh'])),
          _infoItem('Ngày tham gia', _formatDate(data?['NgayBatDau'])),
          _permissionItem(context),
        ],
      ),
    );
  }

  // ================= INFO ITEM =================
  Widget _infoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

  // ================= PERMISSION ITEM =================
  Widget _permissionItem(BuildContext context) {
    // chỉ cho cấu hình quyền khi user là NGƯỜI GIÁM HỘ
    if (data?['VaiTro'] != 'GUARDIAN') {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ConfigurePermissionsScreen(),
          ),
        );
      },
      child: Container(
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
          children: const [
            Text(
              'Chia sẻ dữ liệu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
