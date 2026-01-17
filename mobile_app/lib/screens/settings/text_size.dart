import 'package:flutter/material.dart';
import '../../app_settings.dart';

class TextSizeScreen extends StatefulWidget {
  const TextSizeScreen({super.key});

  @override
  State<TextSizeScreen> createState() => _TextSizeScreenState();
}

class _TextSizeScreenState extends State<TextSizeScreen> {
  // ===== CONSTANTS =====
  static const _bg = Color(0xFFF3F5F9);
  static const _blue = Color(0xFF1F6BFF);

  // ===== STATE =====
  late double _scale;

  @override
  void initState() {
    super.initState();
    _scale = AppSettings.textScale.value; // lấy từ global
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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

  // ===== APP BAR =====
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
        'Text Size',
        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
      ),
    );
  }

  // ===== PREVIEW =====
  Widget _previewText() {
    return Text(
      'Apps that support Dynamic Type will adjust to your preferred reading size below',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14 * _scale,
        height: 1.5,
      ),
    );
  }

  // ===== SLIDER =====
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

  // ===== ACTION =====
  void _onChanged(double v) {
    setState(() => _scale = v);
    AppSettings.textScale.value = v; // 🔥 update toàn app
  }
}
