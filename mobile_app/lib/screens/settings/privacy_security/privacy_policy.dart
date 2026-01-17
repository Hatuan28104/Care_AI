import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _bg = Color(0xFFF3F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(32, 0, 32, 24), // 👈 lề 2 bên
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 18),
                    _Title('Privacy policy'),
                    SizedBox(height: 8),
                    _Paragraph(
                      'Welcome to Elderly Care Digital Human System. '
                      'This Privacy Policy applies to all services of Elderly Care Digital Human System, '
                      'including applications, websites, software, and related platforms.',
                    ),
                    _Paragraph(
                      'We are committed to protecting your privacy. This Policy explains how we collect, use, share, and safeguard your personal information. By using the platform, you agree to the practices described below. If you do not agree, please stop using the service.',
                    ),

                    SizedBox(height: 20),

                    // ✅ BỎ KHỐI XÁM: để bullet thường
                    _Bullet('Information We Collect'),
                    _Bullet('How We Use Your Information'),
                    _Bullet('Sharing of Information'),
                    _Bullet('Data Protection'),
                    _Bullet('Your Rights'),

                    SizedBox(height: 20),
                    _Title('Your information is used to:'),
                    _Bullet(
                        'Provide health monitoring, reminders, and caregiver support.'),
                    _Bullet(
                        'Send alerts to guardians or healthcare professionals.'),
                    _Bullet(
                        'Improve system reliability and personalize user experience.'),
                    _Bullet(
                        'Ensure safety, compliance, and lawful use of the platform.'),

                    SizedBox(height: 16),
                    _Title(
                        'We only share your information in the following cases:'),
                    _Bullet(
                        'With guardians or family members when you grant permission.'),
                    _Bullet(
                        'With healthcare providers, only if authorized or in emergencies.'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Privacy policy',
        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
      ),
      centerTitle: true,
    );
  }
}

// ===== UI COMPONENTS =====

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          height: 1.5,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
