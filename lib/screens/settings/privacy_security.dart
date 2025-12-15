import 'package:flutter/material.dart';
import 'package:Care_AI/screens/settings/privacy_policy.dart';
import 'package:Care_AI/screens/settings/terms_of_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool twoFA = false;
  bool biometrics = false;

  static const blue = Color(0xFF1F6BFF);
  static const bg = Color(0xFFF3F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy & Security',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            _sectionTitle('Phone Number'),
            _phoneItem(),
            const SizedBox(height: 16),
            _sectionTitle('Verify'),
            _switchItem(
              icon: Icons.lock_outline,
              title: 'Two - Factor Authentication (2FA)',
              value: twoFA,
              onChanged: (v) => setState(() => twoFA = v),
            ),
            _switchItem(
              icon: Icons.fingerprint,
              title: 'Biometrics',
              subtitle: 'Fingerprint or Face Recognition',
              value: biometrics,
              onChanged: (v) => setState(() => biometrics = v),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Login History'),
            _loginItem(
              device: 'iPhone 13',
              location: 'Ho Chi Minh City',
              time: 'Today, 10:30AM',
            ),
            _loginItem(
              device: 'iPad Pro',
              location: 'Ho Chi Minh City',
              time: '2 days ago, 9:00AM',
            ),
            const SizedBox(height: 16),
            _sectionTitle('Privacy'),
            _arrowItem(
              icon: Icons.privacy_tip_outlined,
              text: 'Privacy Policy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),
            _arrowItem(
              icon: Icons.description_outlined,
              text: 'Terms of Service',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsOfServiceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== WIDGETS =====

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _phoneItem() {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.phone_android, color: blue),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              '(+84) 123 456 789',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              // TODO: Change phone
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Change',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _card(
      child: Row(
        children: [
          Icon(icon, color: blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: blue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _loginItem({
    required String device,
    required String location,
    required String time,
  }) {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.phone_iphone, color: blue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  '$location\n$time',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.refresh, color: blue),
        ],
      ),
    );
  }

  Widget _arrowItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return _card(
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
