import 'package:flutter/material.dart';

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
    {'name': 'Tiếng Thái', 'code': 'th', 'flag': '🇹🇭'},
    {'name': 'Tiếng Indonesia', 'code': 'id', 'flag': '🇮🇩'},
    {'name': 'Tiếng Mã Lai', 'code': 'ms', 'flag': '🇲🇾'},
    {'name': 'Tiếng Filipino', 'code': 'fil', 'flag': '🇵🇭'},
    {'name': 'Tiếng Hindi', 'code': 'hi', 'flag': '🇮🇳'},
    {'name': 'Tiếng Ả Rập', 'code': 'ar', 'flag': '🇸🇦'},
    {'name': 'Tiếng Thổ Nhĩ Kỳ', 'code': 'tr', 'flag': '🇹🇷'},
    {'name': 'Tiếng Hà Lan', 'code': 'nl', 'flag': '🇳🇱'},
    {'name': 'Tiếng Thụy Điển', 'code': 'sv', 'flag': '🇸🇪'},
    {'name': 'Tiếng Na Uy', 'code': 'no', 'flag': '🇳🇴'},
    {'name': 'Tiếng Đan Mạch', 'code': 'da', 'flag': '🇩🇰'},
    {'name': 'Tiếng Phần Lan', 'code': 'fi', 'flag': '🇫🇮'},
    {'name': 'Tiếng Ba Lan', 'code': 'pl', 'flag': '🇵🇱'},
    {'name': 'Tiếng Ukraina', 'code': 'uk', 'flag': '🇺🇦'},
    {'name': 'Tiếng Séc', 'code': 'cs', 'flag': '🇨🇿'},
    {'name': 'Tiếng Hungary', 'code': 'hu', 'flag': '🇭🇺'},
    {'name': 'Tiếng Romania', 'code': 'ro', 'flag': '🇷🇴'},
    {'name': 'Tiếng Hy Lạp', 'code': 'el', 'flag': '🇬🇷'},
    {'name': 'Tiếng Do Thái', 'code': 'he', 'flag': '🇮🇱'},
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
      backgroundColor: Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
        children: [
          _searchBar(),
          const SizedBox(height: 12),
          const Text(
            'Chọn ngôn ngữ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...list.map(_languageCard),
          const SizedBox(height: 10),
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
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Ngôn ngữ',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: _dirty ? _onSave : null,
            icon: Icon(
              Icons.save_outlined,
              size: 26,
              color: _dirty ? _primary : Colors.black26,
            ),
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
        border: Border.all(color: Colors.black26, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (s) => setState(() => _query = s.trim()),
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _filteredLanguages() {
    final q = _query.toLowerCase();
    if (q.isEmpty) return _languages;
    return _languages.where((l) {
      final name = (l['name'] ?? '').toLowerCase();
      final code = (l['code'] ?? '').toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();
  }

  Widget _languageCard(Map<String, String> lang) {
    final name = lang['name'] ?? '';
    final flag = lang['flag'] ?? '🏳️';
    final selected = _selected == name;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border, width: 1.4),
      ),
      child: InkWell(
        onTap: () => _pick(name),
        borderRadius: BorderRadius.circular(15),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFB9C4E6),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primary,
                  ),
                ),
              ),
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

  void _onSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lưu: $_selected'),
        duration: const Duration(seconds: 1),
      ),
    );
    setState(() => _dirty = false);
  }
}
