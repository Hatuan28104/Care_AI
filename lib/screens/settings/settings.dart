import 'package:flutter/material.dart';
import 'package:Care_AI/screens/profile/my_profile.dart';
import 'package:Care_AI/screens/welcome_screen.dart';
import '../../app_settings.dart';

import 'privacy_security/privacy_security.dart';
import 'text_size.dart';
import 'language.dart';
import 'sound_vibration.dart';
import 'help_support.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ===== CONSTANTS =====
  static const _bg = Color(0xFFF3F5F9);
  static const _blue = Color(0xFF1F6BFF);

  // ===== NAV =====
  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== ACCOUNT =====
              _section(
                'Account',
                fontSize: 18,
              ),
              _card([
                _item(
                  icon: Icons.person_outline,
                  text: 'My Profile',
                  onTap: () => _go(context, const MyProfileScreen()),
                ),
                _item(
                  icon: Icons.lock_outline,
                  text: 'Privacy & Security',
                  onTap: () => _go(context, const PrivacySecurityScreen()),
                ),
              ]),

              // ===== DISPLAY =====
              _section('Display'),
              _card([
                _item(
                  icon: Icons.text_fields,
                  text: 'Text Size',
                  subtitle: _textSizeLabel(AppSettings.textScale.value),
                  onTap: () => _go(context, const TextSizeScreen()),
                ),
                _item(
                  icon: Icons.language,
                  text: 'Language',
                  subtitle: 'English',
                  onTap: () => _go(context, const LanguageScreen()),
                ),
              ]),

              // ===== NOTIFICATIONS =====
              _section('Notifications'),
              _card([
                _switchItem(
                  icon: Icons.notifications_none,
                  text: 'Notification',
                  notifier: AppSettings.notificationOn,
                ),
                _item(
                  icon: Icons.volume_up_outlined,
                  text: 'Sound & Vibration',
                  onTap: () => _go(context, const SoundVibrationScreen()),
                ),
              ]),

              // ===== DEVICE =====
              _section('Device'),
              _card([
                _switchItem(
                  icon: Icons.health_and_safety_outlined,
                  text: 'Health Alerts',
                  notifier: AppSettings.healthAlertOn,
                ),
                _switchItem(
                  icon: Icons.sync,
                  text: 'Sync Data',
                  notifier: AppSettings.syncDataOn,
                ),
              ]),

              // ===== SUPPORT =====
              _section('Support'),
              _card([
                _item(
                  icon: Icons.help_outline,
                  text: 'Help & Support',
                  onTap: () => _go(context, const HelpSupportScreen()),
                ),
              ]),

              const SizedBox(height: 30),

              // ===== LOG OUT =====
              _logoutButton(context),
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
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 24, color: Colors.black),
      ),
    );
  }

  // ===== SECTIONS =====
  Widget _section(
    String text, {
    double fontSize = 16, // 👈 thêm named parameter
  }) {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }

  // ===== ITEMS =====
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
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (_, value, __) {
        return SwitchListTile(
          value: value,
          onChanged: (v) => notifier.value = v,
          secondary: Icon(icon, color: _blue),
          title:
              Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
          activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
          inactiveTrackColor: const Color.fromARGB(255, 238, 238, 238), // nền
        );
      },
    );
  }

  // ===== LOG OUT =====
  Widget _logoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
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
        child: const Text(
          'Log out',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
    );
  }

  // ===== HELPERS =====
  String _textSizeLabel(double scale) {
    if (scale <= 0.8) return 'Small';
    if (scale <= 0.9) return 'Default';
    if (scale <= 1) return 'Medium';
    if (scale <= 1.1) return 'Large';
    return 'Extra Large';
  }
}
