import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Care_AI/screens/settings/profile/my_profile.dart';
import 'package:Care_AI/screens/welcome_screen.dart';
import '../../app_settings.dart';

import 'privacy_security/privacy_security.dart';
import 'text_size.dart';
import 'language.dart';
import 'sound_vibration.dart';
import 'help_support.dart';
import '../../api/settings_api.dart';
import '../../api/auth_storage.dart';
import '../../models/tr.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _blue = Color(0xFF1877F2);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  static const Map<String, String> _languageNames = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    'ja': '日本語',
    'zh': '中文',
    'ko': '한국어',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
  };
  Future<void> _loadSettings() async {
    try {
      final data = await SettingsApi.getSettings();

      AppSettings.notificationOn.value = data['notificationOn'];
      AppSettings.healthAlertOn.value = data['healthAlertOn'];
      AppSettings.syncDataOn.value = data['syncDataOn'];
    } catch (e) {
      print("Load settings lỗi: $e");
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section(context.tr.account, fontSize: 18),
              _card([
                _item(
                  icon: Icons.person_outline,
                  text: context.tr.myProfile,
                  onTap: () => _go(context, const MyProfileScreen()),
                ),
                _item(
                  icon: Icons.lock_outline,
                  text: context.tr.privacySecurity,
                  onTap: () => _go(context, const PrivacySecurityScreen()),
                ),
              ]),
              _section(context.tr.display),
              _card([
                _item(
                  icon: Icons.text_fields,
                  text: context.tr.textSize,
                  subtitle: _textSizeLabel(AppSettings.textScale.value),
                  onTap: () => _go(context, const TextSizeScreen()),
                ),
                _item(
                  icon: Icons.language,
                  text: context.tr.language,
                  subtitle:
                      _languageNames[AppSettings.locale.value.languageCode] ??
                          'English',
                  onTap: () => _go(context, const LanguageScreen()),
                ),
              ]),
              _section(context.tr.notifications),
              _card([
                _switchItem(
                  icon: Icons.notifications_none,
                  text: context.tr.notifications,
                  notifier: AppSettings.notificationOn,
                  settingKey: "notificationOn",
                ),
                _item(
                  icon: Icons.volume_up_outlined,
                  text: context.tr.soundVibration,
                  onTap: () => _go(context, const SoundVibrationScreen()),
                ),
              ]),
              _section(context.tr.device),
              _card([
                _switchItem(
                  icon: Icons.health_and_safety_outlined,
                  text: context.tr.healthAlert,
                  notifier: AppSettings.healthAlertOn,
                  settingKey: "healthAlertOn",
                ),
                _switchItem(
                  icon: Icons.sync,
                  text: context.tr.syncData,
                  notifier: AppSettings.syncDataOn,
                  settingKey: "syncDataOn",
                ),
              ]),
              _section(context.tr.support),
              _card([
                _item(
                  icon: Icons.help_outline,
                  text: context.tr.helpSupport,
                  onTap: () => _go(context, const HelpSupportScreen()),
                ),
              ]),
              const SizedBox(height: 20),
              _logoutButton(context),
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
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr.settings,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _section(String text, {double fontSize = 16}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF9F0F0F0),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(children: children),
    );
  }

  Widget _item({
    required IconData icon,
    required String text,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _blue),
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(
                  fontSize: 12, color: Color.fromARGB(200, 0, 0, 0)))
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _switchItem({
    required IconData icon,
    required String text,
    required ValueNotifier<bool> notifier,
    required String settingKey,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (_, value, __) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: Icon(icon, color: _blue),
          title: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: (v) async {
                notifier.value = v;

                try {
                  await SettingsApi.updateSetting(settingKey, v);
                } catch (e) {
                  notifier.value = !v;
                }
              },
              activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
              inactiveTrackColor: const Color.fromARGB(255, 218, 217, 217),
              inactiveThumbColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () async {
          await AuthStorage.clear();
          await FirebaseMessaging.instance.deleteToken();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (_) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          context.tr.logout,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
    );
  }

  String _textSizeLabel(double scale) {
    if (scale <= 1.0) return context.tr.small;
    if (scale <= 1.1) return context.tr.defaultSize;
    if (scale <= 1.2) return context.tr.medium;
    if (scale <= 1.3) return context.tr.large;
    return context.tr.defaultSize;
  }
}
