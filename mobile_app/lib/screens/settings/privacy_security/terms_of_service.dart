import 'package:flutter/material.dart';
import '../../../models/tr.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
          child: const _Content(),
        ),
      ),
    );
  }

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
      title: Text(
        context.tr.termsOfService,
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
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
