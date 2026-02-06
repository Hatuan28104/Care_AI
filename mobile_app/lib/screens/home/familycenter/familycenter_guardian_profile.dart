import 'package:flutter/material.dart';

import 'familycenter_configure_permissions.dart';

class GuardianProfile extends StatelessWidget {
  final String quanHeId;

  const GuardianProfile({
    super.key,
    required this.quanHeId,
  });

  static const Color blue = Color(0xFF1877F2);
  static const Color textDark = Color(0xFF0D459F);
  static const Color bg = Color(0xFFF6F6F6);
  static const Color itemBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
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
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Edsel Smith',
          style: TextStyle(
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
          _infoItem('Họ và tên', 'Edsel Smith'),
          _infoItem('Ngày sinh', '20/09/2000'),
          _infoItem('Giới tính', 'Nữ'),
          _infoItem('Ngày tham gia', '23/09/2025'),
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
        color: itemBg,
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

  // ================= PERMISSION ITEM =================
  Widget _permissionItem(BuildContext context) {
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
          color: itemBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: const [
            Text(
              'Chia sẽ dữ liệu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
