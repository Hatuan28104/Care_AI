import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);
  static const _fieldBg = Color(0xFFF3F5FF);

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== QUICK CONTACT =====
            _sectionTitle('Quick Contact'),
            _card([
              _contactItem(Icons.call, 'Call Hotline', '1900 xxxx'),
              const Divider(height: 1),
              _contactItem(Icons.email, 'Email', 'support@careai.vn'),
              const Divider(height: 1),
              _contactItem(Icons.chat, 'Chat', null),
            ]),

            const SizedBox(height: 20),

            // ===== SUBMIT REQUEST =====
            _sectionTitle('Submit a Support Request'),
            _card([
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _field('Full Name'),
                    const SizedBox(height: 10),
                    _field('Phone Number'),
                    const SizedBox(height: 10),
                    _field('Email'),
                    const SizedBox(height: 10),
                    _field('Subject'),
                    const SizedBox(height: 10),
                    _field('Message', maxLines: 4),
                    const SizedBox(height: 20),
                    _submitButton(context),
                  ],
                ),
              ),
            ]),
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
        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
      ),
    );
  }

  // ===== SECTION TITLE =====
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.black.withOpacity(.75),
        ),
      ),
    );
  }

  // ===== CARD =====
  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  // ===== CONTACT ITEM =====
  Widget _contactItem(IconData icon, String title, String? subtitle) {
    return ListTile(
      leading: Icon(icon, color: _blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }

  // ===== INPUT FIELD =====
  Widget _field(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: _fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ===== SUBMIT BUTTON =====
  Widget _submitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => _showSuccessPopup(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'Submit Request',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ===== SUCCESS POPUP =====
  static void _showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle, color: Colors.green, size: 56),
              SizedBox(height: 16),
              Text(
                'Request Submitted!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );

    // auto close
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (Navigator.canPop(context)) Navigator.pop(context);
    });
  }
}
