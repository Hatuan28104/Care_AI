import 'package:flutter/material.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color.fromARGB(255, 255, 255, 255);
  static const _fieldBg = Color(0xFFF3F5FF);

  // ===== CONTROLLERS =====
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
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Quick Contact'),
            const SizedBox(height: 12),
            _quickContact(),
            const SizedBox(height: 22),

            _sectionTitle('Submit a Support Request'),
            const SizedBox(height: 12),
            _formCard(context),

            // ✅ PHẦN DƯỚI (giống ảnh)
            const SizedBox(height: 12),
            _contactInfoCard(),
            const SizedBox(height: 12),
            _faqCard(),
          ],
        ),
      ),
    );
  }

  // ===== APP BAR =====
  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Help & Support',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  // ===== SECTION TITLE =====
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

  // ===== QUICK CONTACT =====
  Widget _quickContact() {
    return Column(
      children: [
        _pill('Call Hotline: 1900 xxxx'),
        const SizedBox(height: 6),
        _pill('Email: support@careai.vn'),
        const SizedBox(height: 6),
        _pill('Chat'),
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
          )
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ===== FORM CARD =====
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Full Name'),
          const SizedBox(height: 6),
          _input(_nameCtrl, 'Enter your full name'),
          const SizedBox(height: 6),
          _label('Phone Number'),
          const SizedBox(height: 6),
          _input(_phoneCtrl, 'Enter your phone number',
              type: TextInputType.phone),
          const SizedBox(height: 6),
          _label('Email'),
          const SizedBox(height: 6),
          _input(_emailCtrl, 'Enter your email',
              type: TextInputType.emailAddress),
          const SizedBox(height: 6),
          _label('Subject'),
          const SizedBox(height: 6),
          _subjectDropdown(),
          const SizedBox(height: 6),
          _label('Message'),
          const SizedBox(height: 6),
          _input(_msgCtrl, 'Describe your issue...', lines: 2),
          const SizedBox(height: 6),
          _submitButton(context),
        ],
      ),
    );
  }

  // ===== LABEL =====
  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ===== INPUT =====
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  // ===== SUBJECT DROPDOWN (✅ có icon chọn) =====
  Widget _subjectDropdown() {
    final items = [
      {'label': 'Technical Support', 'icon': Icons.build_outlined},
      {'label': 'Account & Security', 'icon': Icons.lock_outline},
      {'label': 'AI Features', 'icon': Icons.smart_toy_outlined},
      {'label': 'Payment', 'icon': Icons.credit_card_outlined},
      {'label': 'Other', 'icon': Icons.more_horiz},
    ];

    return DropdownButtonFormField<String>(
      value: _subject,
      icon: const SizedBox.shrink(), // ❌ bỏ icon mặc định
      onChanged: (v) => setState(() => _subject = v),
      items: items.map((e) {
        return DropdownMenuItem<String>(
          value: e['label'] as String,
          child: Row(
            children: [
              Icon(
                e['icon'] as IconData,
                size: 20,
                color: _blue,
              ),
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
        hintText: 'Select a subject',
        filled: true,
        fillColor: _fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  // ===== SUBMIT =====
  Widget _submitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'Submit Request',
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
        const Text(
          'Contact Information',
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
                title: 'Hotline',
                value: '1900 xxxx',
                note: '24/7 Support',
              ),
              const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
              _contactRow(
                icon: Icons.email_outlined,
                title: 'Email',
                value: 'support@careai.vn',
                note: 'Response within 24h',
              ),
              const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
              _contactRow(
                icon: Icons.location_on_outlined,
                title: 'Address',
                value: '123 ABC Street, District 1, Ho Chi Minh City',
                note: null,
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
      'How can I change the font size?',
      'What can AI help me with?',
      'How can I make a video call to Digital Human?',
      'Is my information safe?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
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
                      height: 1, thickness: 1, color: Color(0x11000000)),
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
