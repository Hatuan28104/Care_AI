import 'package:flutter/material.dart';

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
                  children: const [
                    SizedBox(height: 18),
                    _Title('Chính sách quyền riêng tư'),
                    SizedBox(height: 8),
                    _Paragraph(
                      'Chào mừng bạn đến với Hệ thống hỗ trợ theo dõi sức khỏe. '
                      'Chính sách quyền riêng tư này áp dụng cho tất cả các dịch vụ của hệ thống, '
                      'bao gồm ứng dụng, website, phần mềm và các nền tảng liên quan.',
                    ),
                    _Paragraph(
                      'Chúng tôi cam kết bảo vệ quyền riêng tư của bạn. Chính sách này giải thích cách '
                      'chúng tôi thu thập, sử dụng, chia sẻ và bảo vệ thông tin cá nhân của bạn. '
                      'Khi sử dụng nền tảng, bạn đồng ý với các nội dung được mô tả dưới đây. '
                      'Nếu bạn không đồng ý, vui lòng ngừng sử dụng dịch vụ.',
                    ),
                    SizedBox(height: 20),
                    _Bullet('Thông tin chúng tôi thu thập'),
                    _Bullet('Cách chúng tôi sử dụng thông tin'),
                    _Bullet('Chia sẻ thông tin'),
                    _Bullet('Bảo mật dữ liệu'),
                    _Bullet('Quyền của bạn'),
                    SizedBox(height: 20),
                    _Title('Thông tin của bạn được sử dụng để:'),
                    _Bullet(
                        'Cung cấp các dịch vụ theo dõi sức khỏe, nhắc nhở và hỗ trợ chăm sóc.'),
                    _Bullet(
                        'Gửi cảnh báo cho người giám hộ hoặc nhân viên y tế khi cần thiết.'),
                    _Bullet(
                        'Cải thiện độ ổn định của hệ thống và cá nhân hóa trải nghiệm người dùng.'),
                    _Bullet(
                        'Đảm bảo an toàn, tuân thủ quy định pháp luật và sử dụng đúng mục đích.'),
                    SizedBox(height: 16),
                    _Title(
                        'Chúng tôi chỉ chia sẻ thông tin của bạn trong các trường hợp sau:'),
                    _Bullet(
                        'Với người giám hộ hoặc thành viên gia đình khi có sự cho phép của bạn.'),
                    _Bullet(
                        'Với các cơ sở y tế, khi được ủy quyền hoặc trong trường hợp khẩn cấp.'),
                  ],
                ),
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
      title: const Text(
        'Chính sách quyền riêng tư',
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
          fontSize: 12,
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
                fontSize: 12,
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
