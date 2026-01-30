import 'package:flutter/material.dart';
import '../../app_settings.dart';

class TextSizeScreen extends StatefulWidget {
  const TextSizeScreen({super.key});

  @override
  State<TextSizeScreen> createState() => _TextSizeScreenState();
}

class _TextSizeScreenState extends State<TextSizeScreen> {
  static const _blue = Color(0xFF1877F2);

  late double _scale;

  @override
  void initState() {
    super.initState();
    _scale = AppSettings.textScale.value;
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
          child: Column(
            children: [
              _previewText(),
              const Spacer(),
              _slider(),
            ],
          ),
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
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Cỡ chữ',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }

  Widget _previewText() {
    return Text(
      'Các ứng dụng hỗ trợ cỡ chữ động sẽ tự điều chỉnh theo kích thước chữ bạn chọn bên dưới',
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 14 * _scale,
        height: 1.5,
      ),
    );
  }

  Widget _slider() {
    return Row(
      children: [
        const Text('A', style: TextStyle(fontSize: 12, color: Colors.black54)),
        Expanded(
          child: Slider(
            value: _scale,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            activeColor: _blue,
            inactiveColor: Colors.black12,
            onChanged: _onChanged,
          ),
        ),
        const Text('A', style: TextStyle(fontSize: 20, color: Colors.black54)),
      ],
    );
  }

  // ===== Update =====
  void _onChanged(double v) {
    setState(() => _scale = v);
    AppSettings.textScale.value = v;
  }
}
