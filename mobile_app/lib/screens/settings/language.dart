import 'package:flutter/material.dart';
import '../../app_settings.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _primary = Color(0xFF1877F2);
  static const _border = Color(0xFFD6DAE3);

  final _searchCtrl = TextEditingController();
  String _selected = 'Tiếng Việt';
  String _query = '';
  bool _dirty = false;

  // 🔥 MAP NAME → LOCALE CODE
  static const Map<String, String> _langMap = {
    'Tiếng Việt': 'vi',
    'Tiếng Anh': 'en',
    'Tiếng Nhật': 'ja',
    'Tiếng Hàn': 'ko',
    'Tiếng Trung (Giản thể)': 'zh',
    'Tiếng Trung (Phồn thể)': 'zh',
    'Tiếng Pháp': 'fr',
    'Tiếng Đức': 'de',
    'Tiếng Tây Ban Nha': 'es',
    'Tiếng Ý': 'it',
    'Tiếng Bồ Đào Nha': 'pt',
    'Tiếng Nga': 'ru',
  };

  static const List<Map<String, String>> _languages = [
    {'name': 'Tiếng Anh', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Tiếng Việt', 'code': 'vi', 'flag': '🇻🇳'},
    {'name': 'Tiếng Đức', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'Tiếng Pháp', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'Tiếng Tây Ban Nha', 'code': 'es', 'flag': '🇪🇸'},
    {'name': 'Tiếng Ý', 'code': 'it', 'flag': '🇮🇹'},
    {'name': 'Tiếng Bồ Đào Nha', 'code': 'pt', 'flag': '🇵🇹'},
    {'name': 'Tiếng Nga', 'code': 'ru', 'flag': '🇷🇺'},
    {'name': 'Tiếng Trung (Giản thể)', 'code': 'zh', 'flag': '🇨🇳'},
    {'name': 'Tiếng Trung (Phồn thể)', 'code': 'zh-Hant', 'flag': '🇹🇼'},
    {'name': 'Tiếng Nhật', 'code': 'ja', 'flag': '🇯🇵'},
    {'name': 'Tiếng Hàn', 'code': 'ko', 'flag': '🇰🇷'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredLanguages();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
        children: [
          _searchBar(),
          const SizedBox(height: 12),
          const Text(
            'Chọn ngôn ngữ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ...list.map(_languageCard),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Ngôn ngữ',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
      ),
      actions: [
        IconButton(
          onPressed: _dirty ? _onSave : null,
          icon: Icon(
            Icons.save_outlined,
            color: _dirty ? _primary : Colors.black26,
          ),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black26),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (s) => setState(() => _query = s.trim()),
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  List<Map<String, String>> _filteredLanguages() {
    if (_query.isEmpty) return _languages;
    return _languages.where((l) {
      return (l['name'] ?? '').toLowerCase().contains(_query.toLowerCase());
    }).toList();
  }

  Widget _languageCard(Map<String, String> lang) {
    final name = lang['name']!;
    final flag = lang['flag']!;
    final selected = _selected == name;

    return InkWell(
      onTap: () => _pick(name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _border, width: 1.4),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: _primary,
            ),
          ],
        ),
      ),
    );
  }

  void _pick(String name) {
    if (_selected == name) return;
    setState(() {
      _selected = name;
      _dirty = true;
    });
  }

  // 🔥 CHỖ QUAN TRỌNG NHẤT
  void _onSave() {
    final lang = _languages.firstWhere(
      (l) => l['name'] == _selected,
    );

    final code = lang['code']!;

    AppSettings.locale.value = Locale(code); // 🔥 APPLY NGAY

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã đổi ngôn ngữ: $_selected'),
        duration: const Duration(seconds: 1),
      ),
    );

    setState(() => _dirty = false);
  }
}
