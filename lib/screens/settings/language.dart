import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // ===== CONSTANTS =====
  static const _bg = Color(0xFFF3F5F9);

  // ===== STATE =====
  String _selected = 'English';

  static const _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'German', 'code': 'de'},
    {'name': 'Chinese', 'code': 'zh'},
    {'name': 'Korean', 'code': 'ko'},
    {'name': 'Japanese', 'code': 'ja'},
    {'name': 'Italian', 'code': 'it'},
    {'name': 'French', 'code': 'fr'},
    {'name': 'Vietnamese', 'code': 'vi'},
  ];

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _languages.length,
        itemBuilder: (_, i) => _languageItem(_languages[i]),
      ),
    );
  }

  // ===== APP BAR =====
  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Language',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  // ===== LANGUAGE ITEM =====
  Widget _languageItem(Map<String, String> lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: RadioListTile<String>(
        value: lang['name']!,
        groupValue: _selected,
        onChanged: (v) => setState(() => _selected = v!),
        title: Text(
          lang['name']!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
