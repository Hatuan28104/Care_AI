import 'package:flutter/material.dart';

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
      title: const Text(
        'Điều khoản sử dụng',
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
      children: const [
        _Title('Điều khoản sử dụng'),
        _Title('Chấp nhận điều khoản'),
        _Paragraph(
          'Bằng việc tạo tài khoản hoặc truy cập Hệ thống hỗ trợ theo dõi sức khỏe, '
          'bạn đồng ý tuân thủ các Điều khoản sử dụng này. Các điều khoản này tạo thành một thỏa thuận '
          'ràng buộc pháp lý giữa bạn và nền tảng. Nếu bạn không đồng ý với các điều khoản này, '
          'vui lòng ngừng sử dụng dịch vụ ngay lập tức.',
        ),
        _Title('Trách nhiệm của người dùng'),
        _Paragraph(
          'Bạn phải cung cấp thông tin chính xác và được cập nhật. Bạn chịu trách nhiệm bảo mật '
          'thông tin tài khoản của mình và mọi hoạt động diễn ra dưới tài khoản đó. '
          'Nghiêm cấm việc sử dụng nền tảng cho các mục đích trái pháp luật, gây hại hoặc gian lận. '
          'Người dùng phải luôn sử dụng hệ thống một cách tôn trọng và đúng quy định pháp luật.',
        ),
        _Title('Giới hạn của dịch vụ'),
        _Paragraph(
          'Hệ thống Nhân sự số Chăm sóc Người cao tuổi là công cụ hỗ trợ trong việc chăm sóc người cao tuổi '
          'và không thay thế cho tư vấn, chẩn đoán hoặc điều trị y tế chuyên nghiệp. '
          'Mặc dù hệ thống có thể cung cấp các nhắc nhở, cảnh báo và gợi ý, '
          'người dùng vẫn cần tham khảo ý kiến của các chuyên gia y tế được cấp phép '
          'đối với các vấn đề liên quan đến sức khỏe.',
        ),
        _Title('Quản lý tài khoản'),
        _Paragraph(
          'Bạn có thể tạm ngưng hoặc xóa vĩnh viễn tài khoản của mình bất kỳ lúc nào '
          'thông qua cài đặt ứng dụng hoặc bằng cách liên hệ với bộ phận hỗ trợ. '
          'Nền tảng có quyền tạm khóa hoặc chấm dứt tài khoản nếu phát hiện vi phạm các điều khoản này '
          'hoặc gây ảnh hưởng đến sự an toàn của người khác.',
        ),
        _Title('Cập nhật điều khoản và chính sách'),
        _Paragraph(
          'Các Điều khoản sử dụng này có thể được cập nhật theo thời gian nhằm tuân thủ '
          'các quy định pháp luật mới hoặc cải thiện chất lượng dịch vụ. '
          'Người dùng sẽ được thông báo trước về những thay đổi quan trọng trước khi chúng có hiệu lực.',
        ),
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
