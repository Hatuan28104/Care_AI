import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
          child: const _Content(),
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
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Terms of Service',
        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
      ),
    );
  }
}

// ===== CONTENT =====
class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Title('Terms of Service'),
        _Title('Acceptance of Terms'),
        _Paragraph(
            'By creating an account or accessing Elderly Care Digital Human System, you agree to comply with these Terms of Service. These terms form a binding agreement between you and the platform. If you do not accept them, please stop using the service immediately.'),
        _Title('User Responsibilities'),
        _Paragraph(
            'You must provide accurate and up-to-date information. You are responsible for keeping your account details secure and for all activities under your account. Misuse for illegal, harmful, or fraudulent purposes is prohibited. You must always use the platform respectfully and lawfully.'),
        _Title('Service Limitations'),
        _Paragraph(
          'The Elderly Care Digital Human System is a supportive tool for elderly care. It does not replace professional medical advice, diagnosis, or treatment. While the system provides reminders, alerts, and recommendations, users should always consult licensed healthcare professionals for medical issues.',
        ),
        _Title('Account Management'),
        _Paragraph(
          'You may deactivate or permanently delete your account at any time via the app settings or by contacting support. The platform reserves the right to suspend or terminate accounts that violate these terms or compromise the safety of others.',
        ),
        _Title('Updates to Terms and Policy'),
        _Paragraph(
          'These Terms may be updated from time to time to comply with new regulations or improve services. Users will be notified of significant changes before they take effect.',
        ),
      ],
    );
  }
}

// ===== SHARED COMPONENTS =====
class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromARGB(255, 0, 0, 0),
          height: 1.5,
        ),
      ),
    );
  }
}
