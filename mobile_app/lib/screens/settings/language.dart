import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // ===== THEME =====
  static const _bg = Color.fromARGB(255, 255, 255, 255);
  static const _primary = Color(0xFF1F6BFF);
  static const _border = Color(0xFFD6DAE3);

  // ===== STATE =====
  final _searchCtrl = TextEditingController();
  String _selected = 'English';
  String _query = '';
  bool _dirty = false;

  static const List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Vietnamese', 'code': 'vi', 'flag': '🇻🇳'},
    {'name': 'German', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'French', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'Spanish', 'code': 'es', 'flag': '🇪🇸'},
    {'name': 'Italian', 'code': 'it', 'flag': '🇮🇹'},
    {'name': 'Portuguese', 'code': 'pt', 'flag': '🇵🇹'},
    {'name': 'Russian', 'code': 'ru', 'flag': '🇷🇺'},
    {'name': 'Chinese (Simplified)', 'code': 'zh', 'flag': '🇨🇳'},
    {'name': 'Chinese (Traditional)', 'code': 'zh-Hant', 'flag': '🇹🇼'},
    {'name': 'Japanese', 'code': 'ja', 'flag': '🇯🇵'},
    {'name': 'Korean', 'code': 'ko', 'flag': '🇰🇷'},
    {'name': 'Thai', 'code': 'th', 'flag': '🇹🇭'},
    {'name': 'Indonesian', 'code': 'id', 'flag': '🇮🇩'},
    {'name': 'Malay', 'code': 'ms', 'flag': '🇲🇾'},
    {'name': 'Filipino', 'code': 'fil', 'flag': '🇵🇭'},
    {'name': 'Hindi', 'code': 'hi', 'flag': '🇮🇳'},
    {'name': 'Arabic', 'code': 'ar', 'flag': '🇸🇦'},
    {'name': 'Turkish', 'code': 'tr', 'flag': '🇹🇷'},
    {'name': 'Dutch', 'code': 'nl', 'flag': '🇳🇱'},
    {'name': 'Swedish', 'code': 'sv', 'flag': '🇸🇪'},
    {'name': 'Norwegian', 'code': 'no', 'flag': '🇳🇴'},
    {'name': 'Danish', 'code': 'da', 'flag': '🇩🇰'},
    {'name': 'Finnish', 'code': 'fi', 'flag': '🇫🇮'},
    {'name': 'Polish', 'code': 'pl', 'flag': '🇵🇱'},
    {'name': 'Ukrainian', 'code': 'uk', 'flag': '🇺🇦'},
    {'name': 'Czech', 'code': 'cs', 'flag': '🇨🇿'},
    {'name': 'Hungarian', 'code': 'hu', 'flag': '🇭🇺'},
    {'name': 'Romanian', 'code': 'ro', 'flag': '🇷🇴'},
    {'name': 'Greek', 'code': 'el', 'flag': '🇬🇷'},
    {'name': 'Hebrew', 'code': 'he', 'flag': '🇮🇱'},
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
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
        children: [
          _searchBar(),
          const SizedBox(height: 12),
          const Text(
            'Select Language',
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

  // ===== APP BAR =====
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
        'Language',
        style: TextStyle(
          fontWeight: FontWeight.w800,
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

  // ===== SEARCH =====
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
                hintText: 'Search',
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

  // ===== ITEM UI (card giống ảnh) =====
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
            // radio tròn bên phải
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
    // TODO: lưu thật vào AppSettings / SharedPreferences / Provider...
    // ví dụ demo:
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved: $_selected'),
        duration: const Duration(seconds: 1),
      ),
    );
    setState(() => _dirty = false);
  }
}
