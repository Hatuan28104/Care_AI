import 'package:flutter/material.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/app_settings.dart';
import 'privacy_policy.dart';
import 'terms_of_service.dart';
import 'package:Care_AI/api/auth_api.dart';
import 'package:Care_AI/models/login_history_item.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'package:Care_AI/services/time_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  static const blue = Color(0xFF1877F2);
  bool _twoFA = false;
  bool _biometrics = false;
  bool _showAllHistory = false;

  @override
  void initState() {
    super.initState();
    _loadLoginHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.privacySecurity),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  _sectionTitle(context.tr.phoneNumber),
                  _phoneCard(),
                  const SizedBox(height: 14),
                  _sectionTitle(context.tr.verification),
                  _verifyCard(),
                  const SizedBox(height: 14),
                  _loginHeader(),
                  const SizedBox(height: 2),
                  _loginHistoryCard(),
                  const SizedBox(height: 14),
                  _sectionTitle(context.tr.privacy),
                  _privacyCard(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _loginHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            context.tr.loginHistory,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.refresh, color: blue, size: 20),
            onPressed: _loadLoginHistory,
          ),
        ],
      ),
    );
  }

  Widget _phoneCard() {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.phone_android, color: blue),
          const SizedBox(width: 10),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: AppSettings.phoneNumber,
              builder: (_, phone, __) {
                final show = _formatPhoneForUI(phone);
                return Text(
                  show,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: _changePhoneDialog,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFF1877F2)),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: Text(
                context.tr.change,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePhoneDialog() async {
    final current = AppSettings.phoneNumber.value;
    final ctrl = TextEditingController(text: current);

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.tr.changePhone),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: context.tr.phoneExample),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(context.tr.save),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    final cleaned = result.trim();
    if (cleaned.isNotEmpty && !_looksLikePhone(cleaned)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr.invalidPhone)));
      return;
    }

    try {
      await AuthApi.changePhone(cleaned);

      AppSettings.phoneNumber.value = cleaned;

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr.phoneUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  bool _looksLikePhone(String s) {
    final digits = s.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 9 && digits.length <= 12;
  }

  String _formatPhoneForUI(String input) {
    final s = input.trim();
    if (s.isEmpty) return '(Chưa thiết lập)';

    String digits = s.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('84')) {
      digits = '0' + digits.substring(2);
    }

    if (digits.length != 10) return s;

    return '${digits.substring(0, 3)} '
        '${digits.substring(3, 6)} '
        '${digits.substring(6, 10)}';
  }

  Widget _verifyCard() {
    return _card(
      child: Column(
        children: [
          _switchTile(
            icon: Icons.lock_outline,
            title: context.tr.twoFactorAuth,
            value: _twoFA,
            onChanged: (v) => setState(() => _twoFA = v),
          ),
          const Divider(height: 16, thickness: 1, color: Color(0x11000000)),
          _switchTile(
            icon: Icons.fingerprint,
            title: context.tr.biometrics,
            subtitle: context.tr.fingerprintOrFace,
            value: _biometrics,
            onChanged: (v) => setState(() => _biometrics = v),
          ),
        ],
      ),
    );
  }

  Widget _switchTile({
    IconData? icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon ?? Icons.lock_outline, color: blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _loginHistoryCard() {
    return _card(
      child: ValueListenableBuilder<List<LoginHistoryItem>>(
        valueListenable: AppSettings.loginHistory,
        builder: (_, rawList, __) {
          if (rawList.isEmpty) {
            return Text(
              context.tr.noLoginHistory,
              style: TextStyle(color: Colors.black45),
            );
          }

          final list = _buildDisplayHistory(rawList);

          return Column(
            children: [
              for (int i = 0; i < list.length; i++) ...[
                _loginRow(list[i]),
                if (i != list.length - 1)
                  const Divider(
                    height: 18,
                    thickness: 1,
                    color: Color(0x11000000),
                  ),
              ],
              if (!_showAllHistory && rawList.length > list.length)
                TextButton(
                  onPressed: () {
                    setState(() => _showAllHistory = true);
                  },
                  child: Text(
                    context.tr.viewMore,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _loginRow(LoginHistoryItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.phone_iphone, color: blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.device,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.location,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                TimeService.formatSmart(item.time),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _privacyCard(BuildContext context) {
    return _card(
      child: Column(
        children: [
          _arrowRow(
            icon: Icons.privacy_tip_outlined,
            text: context.tr.privacyPolicy,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
          const Divider(height: 18, thickness: 1, color: Color(0x11000000)),
          _arrowRow(
            icon: Icons.description_outlined,
            text: context.tr.termsOfService,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  Future<void> _loadLoginHistory() async {
    try {
      final list = await AuthApi.getLoginHistory();
      AppSettings.loginHistory.value = list;
    } catch (e) {
      debugPrint('Load login history error: $e');
    }
  }

  List<LoginHistoryItem> _buildDisplayHistory(List<LoginHistoryItem> raw) {
    final Map<String, LoginHistoryItem> latestByDevice = {};

    for (final item in raw) {
      if (!latestByDevice.containsKey(item.device)) {
        latestByDevice[item.device] = item;
      }
    }

    final list = latestByDevice.values.toList();

    list.sort((a, b) =>
        TimeService.toLocal(b.time).compareTo(TimeService.toLocal(a.time)));
    if (!_showAllHistory && list.length > 2) {
      return list.take(2).toList();
    }

    return list;
  }
}
