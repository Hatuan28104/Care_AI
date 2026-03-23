import 'package:flutter/material.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/app_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.privacyPolicy),
            Expanded(
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
