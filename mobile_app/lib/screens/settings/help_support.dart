import 'package:flutter/material.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/app_components.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const _blue = Color(0xFF1877F2);
  static const _fieldBg = Color(0xFFF3F5FF);

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  String? _subject;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.helpSupport),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(context.tr.quickContact),
                    const SizedBox(height: 12),
                    _quickContact(),
                    const SizedBox(height: 22),
                    _sectionTitle(context.tr.sendSupportRequest),
                    const SizedBox(height: 12),
                    _formCard(context),
                    const SizedBox(height: 12),
                    _contactInfoCard(),
                    const SizedBox(height: 12),
                    _faqCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _quickContact() {
    return Column(
      children: [
        _pill(context.tr.callHotline),
        const SizedBox(height: 6),
        _pill(context.tr.supportEmail),
        const SizedBox(height: 6),
        _pill(context.tr.chat),
      ],
    );
  }

  Widget _pill(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context.tr.fullName),
          const SizedBox(height: 6),
          _input(_nameCtrl, context.tr.enterFullName),
          const SizedBox(height: 6),
          _label(context.tr.phoneNumber),
          const SizedBox(height: 6),
          _input(_phoneCtrl, context.tr.enterPhone, type: TextInputType.phone),
          const SizedBox(height: 6),
          _label(context.tr.email),
          const SizedBox(height: 6),
          _input(
            _emailCtrl,
            context.tr.enterEmail,
            type: TextInputType.emailAddress,
          ),
          const SizedBox(height: 6),
          _label(context.tr.subject),
          const SizedBox(height: 6),
          _subjectDropdown(),
          const SizedBox(height: 6),
          _label(context.tr.content),
          const SizedBox(height: 6),
          _input(_msgCtrl, context.tr.describeProblem, lines: 2),
          const SizedBox(height: 6),
          _submitButton(context),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String hint, {
    TextInputType? type,
    int lines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: lines,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 2.4),
        ),
      ),
    );
  }

  Widget _subjectDropdown() {
    final items = [
      {'label': context.tr.techSupport, 'icon': Icons.build_outlined},
      {'label': context.tr.accountSecurity, 'icon': Icons.lock_outline},
      {'label': context.tr.aiFeatures, 'icon': Icons.smart_toy_outlined},
      {'label': context.tr.payment, 'icon': Icons.credit_card_outlined},
      {'label': context.tr.other, 'icon': Icons.more_horiz},
    ];

    return DropdownButtonFormField<String>(
      value: _subject,
      icon: const SizedBox.shrink(),
      onChanged: (v) => setState(() => _subject = v),
      items: items.map((e) {
        return DropdownMenuItem<String>(
          value: e['label'] as String,
          child: Row(
            children: [
              Icon(e['icon'] as IconData, size: 20, color: _blue),
              const SizedBox(width: 10),
              Text(
                e['label'] as String,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        hintText: context.tr.chooseSubject,
        filled: true,
        fillColor: _fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        suffixIcon: const Icon(
          Icons.keyboard_arrow_down,
          color: _blue,
          size: 26,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 2.4),
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr.requestSentSuccess),
              duration: Duration(seconds: 2),
            ),
          );

          _nameCtrl.clear();
          _phoneCtrl.clear();
          _emailCtrl.clear();
          _msgCtrl.clear();
          setState(() => _subject = null);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          context.tr.sendRequest,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _contactInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.contactInfo,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              _contactRow(
                icon: Icons.call_outlined,
                title: context.tr.hotline,
                value: '1900 xxxx',
                note: context.tr.support247,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
              _contactRow(
                icon: Icons.email_outlined,
                title: context.tr.email,
                value: 'support@careai.vn',
                note: context.tr.replyWithin24h,
              ),
              const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
              _contactRow(
                icon: Icons.location_on_outlined,
                title: context.tr.address,
                value: '123 ABC, Quận 1, TP. Hồ Chí Minh',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String title,
    required String value,
    String? note,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: _blue,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqCard() {
    final faqs = [
      context.tr.faqTextSize,
      context.tr.faqAiSupport,
      context.tr.faqVideoCall,
      context.tr.faqDataSafety,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.faq,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              for (int i = 0; i < faqs.length; i++) ...[
                _faqItem(faqs[i]),
                if (i != faqs.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0x11000000),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _faqItem(String text) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
