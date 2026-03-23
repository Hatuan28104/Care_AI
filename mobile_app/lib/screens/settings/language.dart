import 'package:flutter/material.dart';
import 'package:Care_AI/app_settings.dart';
import 'package:Care_AI/l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _primary = Color(0xFF1877F2);
  static const _border = Color(0xFFD6DAE3);

  final _searchCtrl = TextEditingController();
  String _selectedCode = '';
  String _query = '';
  bool _dirty = false;

  static const List<Map<String, String>> _languages = [
    {'name': 'English (US)', 'code': 'en', 'flag': '🇺🇸'},
    {'name': 'Tiếng Việt', 'code': 'vi', 'flag': '🇻🇳'},
    {'name': '简体中文', 'code': 'zh_CN', 'flag': '🇨🇳'},
    {'name': '日本語', 'code': 'ja', 'flag': '🇯🇵'},
    {'name': 'Deutsch', 'code': 'de', 'flag': '🇩🇪'},
    {'name': 'Français', 'code': 'fr', 'flag': '🇫🇷'},
    {'name': 'Español', 'code': 'es', 'flag': '🇪🇸'},
    {'name': 'Italiano', 'code': 'it', 'flag': '🇮🇹'},
    {'name': 'Português', 'code': 'pt', 'flag': '🇵🇹'},
    {'name': 'Русский', 'code': 'ru', 'flag': '🇷🇺'},
    {'name': '繁體中文', 'code': 'zh_TW', 'flag': '🇹🇼'},
    {'name': '한국어', 'code': 'ko', 'flag': '🇰🇷'},
  ];

  @override
  void initState() {
    super.initState();

    final current = AppSettings.locale.value.toString();

    final lang = _languages.firstWhere(
      (l) => l['code'] == current,
      orElse: () => _languages.first,
    );

    _selectedCode = lang['code']!;
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
      backgroundColor: Color(0xFFF6F6F6),
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
      final name = l['name']!.toLowerCase();
      final code = l['code']!.toLowerCase();
      final q = _query.toLowerCase();

      return name.contains(q) || code.contains(q);
    }).toList();
  }

  Widget _languageCard(Map<String, String> lang) {
    final name = lang['name']!;
    final code = lang['code']!;
    final flag = lang['flag']!;
    final selected = _selectedCode == code;

    return InkWell(
      onTap: () => _pick(code),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
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

  void _pick(String code) {
    if (_selectedCode == code) return;

    setState(() {
      _selectedCode = code;
      _dirty = true;
    });
  }

  void _onSave() {
    final parts = _selectedCode.split('_');

    final locale =
        parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(parts[0]);

    AppSettings.locale.value = locale;

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
