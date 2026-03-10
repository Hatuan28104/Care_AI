import 'package:flutter/material.dart';
import '../../../models/tr.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      _Title(context.tr.privacyPolicy),
                      SizedBox(height: 8),
                      _Paragraph(context.tr.privacyIntro1),
                      _Paragraph(context.tr.privacyIntro2),
                      SizedBox(height: 20),
                      _Bullet(context.tr.infoCollected),
                      _Bullet(context.tr.infoUsage),
                      _Bullet(context.tr.infoSharing),
                      _Bullet(context.tr.dataSecurity),
                      _Bullet(context.tr.userRights),
                      SizedBox(height: 20),
                      _Title(context.tr.infoUsedFor),
                      _Bullet(context.tr.serviceTracking),
                      _Bullet(context.tr.alertGuardian),
                      _Bullet(context.tr.improveSystem),
                      _Bullet(context.tr.ensureSafety),
                      const SizedBox(height: 16),
                      _Title(context.tr.infoSharedCases),
                      _Bullet(context.tr.shareWithGuardian),
                      _Bullet(context.tr.shareWithMedical),
                    ]),
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
      title: Text(
        context.tr.privacyPolicy,
        style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
      ),
      centerTitle: true,
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
          fontSize: 14,
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
                fontSize: 14,
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
