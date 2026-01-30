import 'package:flutter/material.dart';

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
      appBar: _appBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Liên hệ nhanh'),
            const SizedBox(height: 12),
            _quickContact(),
            const SizedBox(height: 22),
            _sectionTitle('Gửi yêu cầu hỗ trợ'),
            const SizedBox(height: 12),
            _formCard(context),
            const SizedBox(height: 12),
            _contactInfoCard(),
            const SizedBox(height: 12),
            _faqCard(),
          ],
        ),
      ),
    );
  }

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
        'Trợ giúp & Hỗ trợ',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.black,
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
        _pill('Gọi hotline: 1900 xxxx'),
        const SizedBox(height: 6),
        _pill('Email: support@careai.vn'),
        const SizedBox(height: 6),
        _pill('Trò chuyện'),
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
          _label('Họ và tên'),
          const SizedBox(height: 6),
          _input(_nameCtrl, 'Nhập họ và tên'),
          const SizedBox(height: 6),
          _label('Số điện thoại'),
          const SizedBox(height: 6),
          _input(_phoneCtrl, 'Nhập số điện thoại', type: TextInputType.phone),
          const SizedBox(height: 6),
          _label('Email'),
          const SizedBox(height: 6),
          _input(_emailCtrl, 'Nhập email', type: TextInputType.emailAddress),
          const SizedBox(height: 6),
          _label('Chủ đề'),
          const SizedBox(height: 6),
          _subjectDropdown(),
          const SizedBox(height: 6),
          _label('Nội dung'),
          const SizedBox(height: 6),
          _input(_msgCtrl, 'Mô tả vấn đề của bạn...', lines: 2),
          const SizedBox(height: 6),
          _submitButton(context),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
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

  Widget _subjectDropdown() {
    final items = [
      {'label': 'Hỗ trợ kỹ thuật', 'icon': Icons.build_outlined},
      {'label': 'Tài khoản & bảo mật', 'icon': Icons.lock_outline},
      {'label': 'Tính năng AI', 'icon': Icons.smart_toy_outlined},
      {'label': 'Thanh toán', 'icon': Icons.credit_card_outlined},
      {'label': 'Khác', 'icon': Icons.more_horiz},
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
        hintText: 'Chọn chủ đề',
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

  Widget _submitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gửi yêu cầu thành công'),
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
        child: const Text(
          'Gửi yêu cầu',
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
          'Thông tin liên hệ',
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
                note: 'Hỗ trợ 24/7',
              ),
              const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
              _contactRow(
                icon: Icons.email_outlined,
                title: 'Email',
                value: 'support@careai.vn',
                note: 'Phản hồi trong vòng 24 giờ',
              ),
              const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
              _contactRow(
                icon: Icons.location_on_outlined,
                title: 'Địa chỉ',
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
      'Làm thế nào để thay đổi cỡ chữ?',
      'AI có thể hỗ trợ tôi những gì?',
      'Làm thế nào để gọi video với Nhân sự số?',
      'Thông tin của tôi có an toàn không?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Câu hỏi thường gặp',
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
