import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Care_AI/screens/settings/profile/my_profile.dart';
import 'package:Care_AI/screens/welcome_screen.dart';
import 'package:Care_AI/app_settings.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'privacy_security/privacy_security.dart';
import 'text_size.dart';
import 'language.dart';
import 'sound_vibration.dart';
import 'help_support.dart';
import 'package:Care_AI/api/settings_api.dart';
import 'package:Care_AI/api/auth_storage.dart';
import 'package:Care_AI/models/tr.dart';

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
  };
  Future<void> _loadSettings() async {
    try {
      final data = await SettingsApi.getSettings();

      AppSettings.thongbao.value = data['thongbao'];

    } catch (e) {
      print("Load settings lỗi: $e");
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  static void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.settings, showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _section(context.tr.account),
                    _card([
                      _item(
                        icon: Icons.person_outline,
                        text: context.tr.myProfile,
                        onTap: () => _go(context, const MyProfileScreen()),
                      ),
                    ]),
                    _card([
                      _item(
                        icon: Icons.lock_outline,
                        text: context.tr.privacySecurity,
                        onTap: () =>
                            _go(context, const PrivacySecurityScreen()),
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
                    ]),
                    _card([
                      _item(
                        icon: Icons.language,
                        text: context.tr.language,
                        subtitle: _languageNames[
                                AppSettings.locale.value.languageCode] ??
                            'English',
                        onTap: () => _go(context, const LanguageScreen()),
                      ),
                    ]),
                    _section(context.tr.notifications),
                    _card([
                      _switchItem(
                        icon: Icons.notifications_none,
                        text: context.tr.notifications,
                        notifier: AppSettings.thongbao,
                        settingKey: "thongbao",
                      ),
                    ]),
                    _section(context.tr.device),
               
                    _card([
                      _item(
                        icon: Icons.volume_up_outlined,
                        text: context.tr.soundVibration,
                        onTap: () => _go(context, const SoundVibrationScreen()),
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
                    const SizedBox(height: 30),
                    _logoutButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String text, {double fontSize = 18}) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 6),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 3),
          ),
        ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 24, child: Icon(icon, color: _blue, size: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (subtitle != null) ...[
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: SizedBox(
            height: 30,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 24, child: Icon(icon, color: _blue, size: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                AppSwitch(
                  value: value,
                  onChanged: (v) async {
                    notifier.value = v;
                    try {
                      await SettingsApi.updateSetting(settingKey, v);
                    } catch (e) {
                      notifier.value = !v;
                    }
                  },
                ),
              ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
