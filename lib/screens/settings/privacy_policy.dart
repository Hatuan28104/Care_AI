import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // ===== CONSTANTS =====
  static const _bg = Color(0xFFF3F5F9);

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Title('Privacy policy'),
              _Paragraph(
                'Welcome to Elderly Care Digital Human System. '
                'This Privacy Policy applies to all services of Elderly Care Digital Human System, '
                'including applications, websites, software, and related platforms.',
              ),
              _Paragraph(
                'We are committed to protecting your privacy. '
                'This policy explains how we collect, use, share, and safeguard your personal information.',
              ),
              _Bullet('Information We Collect'),
              _Bullet('How We Use Your Information'),
              _Bullet('Sharing of Information'),
              _Bullet('Data Protection'),
              _Bullet('Your Rights'),
              SizedBox(height: 16),
              _Title('Your information is used to:'),
              _Bullet(
                  'Provide health monitoring, reminders, and caregiver support'),
              _Bullet('Send alerts to guardians or healthcare professionals'),
              _Bullet(
                  'Improve system reliability and personalize user experience'),
              _Bullet(
                  'Ensure safety, compliance, and lawful use of the platform'),
              SizedBox(height: 16),
              _Title('We only share your information in the following cases:'),
              _Bullet(
                  'With guardians or family members when you grant permission'),
              _Bullet(
                  'With healthcare providers, only if authorized or in emergencies'),
            ],
          ),
        ),
      ),
    );
  }

  // ===== APP BAR =====
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
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
          fontSize: 14,
          color: Colors.black54,
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
        children: const [
          Text('•  ', style: TextStyle(fontSize: 18, height: 1.3)),
          Expanded(
            child: Text(
              '',
              style:
                  TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
            ),
          ),
        ],
      ).copyWith(text),
    );
  }
}

// ===== EXTENSION (nhỏ gọn bullet) =====
extension on Row {
  Widget copyWith(String text) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        children.first,
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
