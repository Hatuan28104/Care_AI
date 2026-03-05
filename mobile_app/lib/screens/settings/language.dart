import 'package:flutter/material.dart';
import '../../app_settings.dart';
import '../../l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _primary = Color(0xFF1877F2);
  static const _border = Color(0xFFD6DAE3);

  final _searchCtrl = TextEditingController();
  String _selected = '';
  String _query = '';
  bool _dirty = false;

  static const List<Map<String, String>> _languages = [
    {'name': 'United States', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Việt Nam', 'code': 'vi', 'flag': '🇻🇳'},
    {'name': 'Deutschland', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'France', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'España', 'code': 'es', 'flag': '🇪🇸'},
    {'name': 'Italia', 'code': 'it', 'flag': '🇮🇹'},
    {'name': 'Portugal', 'code': 'pt', 'flag': '🇵🇹'},
    {'name': 'Россия', 'code': 'ru', 'flag': '🇷🇺'},
    {'name': '中国', 'code': 'zh', 'flag': '🇨🇳'},
    {'name': '台灣', 'code': 'zh', 'flag': '🇹🇼'},
    {'name': '日本', 'code': 'ja', 'flag': '🇯🇵'},
    {'name': '대한민국', 'code': 'ko', 'flag': '🇰🇷'},
  ];

  @override
  void initState() {
    super.initState();

    final current = AppSettings.locale.value.languageCode;

    final lang = _languages.firstWhere(
      (l) => l['code'] == current,
      orElse: () => _languages[1],
    );

    _selected = lang['name']!;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredLanguages();
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _appBar(context, l),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 14, 28, 24),
        children: [
          _searchBar(l),
          const SizedBox(height: 12),
          Text(
            l.chooseLanguage,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ...list.map(_languageCard),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, AppLocalizations l) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l.language,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
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

  Widget _searchBar(AppLocalizations l) {
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
        decoration: InputDecoration(
          hintText: l.search,
          border: InputBorder.none,
          icon: const Icon(Icons.search),
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
              child: Text(
                name,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
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

  void _onSave() {
    final lang = _languages.firstWhere((l) => l['name'] == _selected);

    final code = lang['code']!;

    AppSettings.locale.value = Locale(code);

    final l = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.languageChanged),
        duration: const Duration(seconds: 1),
      ),
    );

    setState(() => _dirty = false);
  }
}
