import 'package:flutter/material.dart';

import '../../../app_settings.dart';
import 'privacy_policy.dart';
import 'terms_of_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  static const blue = Color(0xFF1F6BFF);
  static const bg = Color(0xFFF3F5F9);
  bool _twoFA = false;
  bool _biometrics = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            _sectionTitle('Phone Number'),
            _phoneCard(),
            const SizedBox(height: 14),
            _sectionTitle('Verify'),
            _verifyCard(),
            const SizedBox(height: 14),
            _loginHeader(),
            const SizedBox(height: 2),
            _loginHistoryCard(),
            const SizedBox(height: 14),
            _sectionTitle('Privacy'),
            _privacyCard(context),
          ],
        ),
      ),
    );
  }

  // ===== HEADERS =====

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _loginHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text(
            'Login History',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.refresh, color: blue, size: 20),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ===== PHONE =====

  Widget _phoneCard() {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.phone_android, color: blue),
          const SizedBox(width: 10),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: AppSettings.phoneNumber,
              builder: (_, phone, __) {
                final show = _formatPhoneForUI(phone);
                return Text(
                  show,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: _changePhoneDialog, // ✅ BẤM ĐỔI SĐT
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFF1877F2)),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePhoneDialog() async {
    final current = AppSettings.phoneNumber.value;
    final ctrl = TextEditingController(text: current);

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change phone number'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Example: 0912345678 or +84 912345678',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    // validate nhẹ: cho trống thì coi như not set
    final cleaned = result.trim();
    if (cleaned.isNotEmpty && !_looksLikePhone(cleaned)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number looks invalid.')),
      );
      return;
    }

    AppSettings.phoneNumber.value = cleaned;
  }

  bool _looksLikePhone(String s) {
    // cho nhập +, khoảng trắng, dấu gạch
    final digits = s.replaceAll(RegExp(r'\D'), '');
    // VN thường 9-11 digits tuỳ dạng (09xxxxxxxx, +84xxxxxxxxx...)
    return digits.length >= 9 && digits.length <= 12;
  }

  // format ra đúng dạng "(+84) 123 456 789"
  String _formatPhoneForUI(String input) {
    final s = input.trim();
    if (s.isEmpty) return '(Not set)';

    final digits = s.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('84') && digits.length >= 11) {
      final national = digits.substring(2);
      return '(+84) ${_groupVN(national)}';
    }

    if (digits.length == 10 && digits.startsWith('0')) {
      return '(+84) ${_groupVN(digits.substring(1))}';
    }

    if (digits.length == 9) {
      return '(+84) ${_groupVN(digits)}';
    }

    return s;
  }

  String _groupVN(String nineDigits) {
    final d = nineDigits.replaceAll(RegExp(r'\D'), '');
    if (d.length < 9) return d;
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6, 9)}';
  }

  // ===== VERIFY =====

  Widget _verifyCard() {
    return _card(
      child: Column(
        children: [
          _switchTile(
            icon: Icons.lock_outline,
            title: 'Two – Factor Authentication (2FA)',
            value: _twoFA,
            onChanged: (v) => setState(() => _twoFA = v),
          ),
          const Divider(height: 18, thickness: 1, color: Color(0x11000000)),
          _switchTile(
            icon: Icons.fingerprint,
            title: 'Biometrics',
            subtitle: 'Fingerprint or Face Recognition',
            value: _biometrics,
            onChanged: (v) => setState(() => _biometrics = v),
          ),
        ],
      ),
    );
  }

  // ✅ GỘP CHUNG: dùng được cả có/không subtitle
  Widget _switchTile({
    IconData? icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    double scale = 0.8,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // gọn hơn
      child: Row(
        children: [
          Icon(icon ?? Icons.lock_outline, color: blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: scale,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
              inactiveTrackColor: Colors.grey.shade500,
              inactiveThumbColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===== LOGIN HISTORY =====

  Widget _loginHistoryCard() {
    return _card(
      child: ValueListenableBuilder<List<LoginHistoryItem>>(
        valueListenable: AppSettings.loginHistory,
        builder: (_, list, __) {
          final items = list.isEmpty
              ? <LoginHistoryItem>[
                  const LoginHistoryItem(
                    device: 'iPhone 13',
                    location: 'Ho Chi Minh City',
                    time: 'Today, 10:30AM',
                  ),
                  const LoginHistoryItem(
                    device: 'iPad Pro',
                    location: 'Ho Chi Minh City',
                    time: '2 days ago, 9:00AM',
                  ),
                ]
              : list;

          return Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _loginRow(items[i]),
                if (i != items.length - 1)
                  const Divider(
                    height: 18,
                    thickness: 1,
                    color: Color(0x11000000),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _loginRow(LoginHistoryItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.phone_iphone, color: blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.device,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.location,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== PRIVACY =====

  Widget _privacyCard(BuildContext context) {
    return _card(
      child: Column(
        children: [
          _arrowRow(
            icon: Icons.privacy_tip_outlined,
            text: 'Privacy Policy',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const Divider(height: 18, thickness: 1, color: Color(0x11000000)),
          _arrowRow(
            icon: Icons.description_outlined,
            text: 'Terms of Service',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  // ===== CARD BASE =====

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
