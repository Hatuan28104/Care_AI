import 'package:flutter/material.dart';

import 'login_form.dart';
import 'register_form.dart';
import 'login_otp.dart';
import 'register_otp.dart';

enum AuthTab { login, register }

enum AuthStep { form, otp }

class AuthScreen extends StatefulWidget {
  final AuthTab initialTab;

  const AuthScreen({
    super.key,
    this.initialTab = AuthTab.login,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _primaryColor = Color(0xFF1F41BB);

  late AuthTab _tab;
  AuthStep _step = AuthStep.form;

  String _phoneE164 = '';
  String _displayPhone = '';

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final tabWidth = (MediaQuery.of(context).size.width - 36) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: Column(
            children: [
              const SizedBox(height: 28),
              _tabs(tabWidth),
              const SizedBox(height: 32),
              Expanded(child: _content()),
            ],
          ),
        ),
      ),
    );
  }

  // ===== AUTH HEADER =====
  Widget _tabs(double tabWidth) {
    return Column(
      children: [
        Row(
          children: [
            _tabText(
              text: 'Đăng nhập',
              active: _tab == AuthTab.login,
              onTap: () {
                setState(() {
                  _tab = AuthTab.login;
                  _step = AuthStep.form;
                });
              },
            ),
            _tabText(
              text: 'Đăng ký',
              active: _tab == AuthTab.register,
              onTap: () {
                setState(() {
                  _tab = AuthTab.register;
                  _step = AuthStep.form;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 3,
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            alignment: _tab == AuthTab.login
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: tabWidth,
              height: 3,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabText({
    required String text,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: active ? null : onTap,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: active ? _primaryColor : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // ===== CONTENT =====
  Widget _content() {
    if (_step == AuthStep.form) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _tab == AuthTab.login
            ? LoginForm(
                key: const ValueKey('login-form'),
                onOtp: _goOtp,
              )
            : RegisterForm(
                key: const ValueKey('register-form'),
                onOtp: _goOtp,
              ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _tab == AuthTab.login
          ? LoginOtpScreen(
              key: const ValueKey('login-otp'),
              phoneE164: _phoneE164,
              displayPhone: _displayPhone,
              onBack: () => setState(() => _step = AuthStep.form),
            )
          : RegisterOtp(
              key: const ValueKey('register-otp'),
              phoneE164: _phoneE164,
              displayPhone: _displayPhone,
              onBack: () => setState(() => _step = AuthStep.form),
            ),
    );
  }

  void _goOtp(String phoneE164, String displayPhone) {
    setState(() {
      _phoneE164 = phoneE164;
      _displayPhone = displayPhone;
      _step = AuthStep.otp;
    });
  }
}
