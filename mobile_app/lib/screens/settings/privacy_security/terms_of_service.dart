import 'package:flutter/material.dart';
import 'package:demo_app/models/tr.dart';
import 'package:demo_app/widgets/app_header.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.termsOfService),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
                child: const _Content(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(context.tr.termsOfService),
        _Title(context.tr.acceptTerms),
        _Paragraph(context.tr.termsIntro),
        _Title(context.tr.userResponsibility),
        _Paragraph(context.tr.userResponsibilityDesc),
        _Title(context.tr.serviceLimitations),
        _Paragraph(context.tr.serviceLimitationsDesc),
        _Title(context.tr.accountManagement),
        _Paragraph(context.tr.accountManagementDesc),
        _Title(context.tr.termsUpdates),
        _Paragraph(context.tr.termsUpdatesDesc),
      ],
    );
  }
}

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
          fontSize: 14,
          color: Color.fromARGB(255, 0, 0, 0),
          height: 1.5,
        ),
      ),
    );
  }
}
