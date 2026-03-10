import 'package:flutter/material.dart';
import 'AuthScreen/auth.dart';
import '../models/tr.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _primaryColor = Color(0xFF1F41BB);
  static const _buttonColor = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 100),
              _logo(),
              const SizedBox(height: 30),
              _title(context),
              const SizedBox(height: 4),
              _subtitle(context),
              const Spacer(),
              _actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Hero(
      tag: 'care-logo',
      child: Image.asset(
        'assets/images/Logo.png',
        height: 260,
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Hero(
      tag: 'care-text',
      child: Material(
        color: Colors.transparent,
        child: Text(
          context.tr.welcomeTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w600,
            height: 2,
            color: _primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _subtitle(BuildContext context) {
    return Text(
      context.tr.welcomeSubtitle,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 13.5,
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        children: [
          _button(
            text: context.tr.login,
            filled: true,
            onTap: () => _go(context, AuthTab.login),
          ),
          const SizedBox(height: 16),
          _button(
            text: context.tr.register,
            filled: false,
            onTap: () => _go(context, AuthTab.register),
          ),
        ],
      ),
    );
  }

  /// ===== Navigation =====

  static void _go(BuildContext context, AuthTab tab) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuthScreen(initialTab: tab),
      ),
    );
  }

  /// ===== Button =====

  static Widget _button({
    required String text,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                elevation: 0,
                shape: shape,
              ),
              child: _buttonText(text, Colors.white),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor),
                shape: shape,
              ),
              child: _buttonText(text),
            ),
    );
  }

  static Widget _buttonText(String text, [Color? color]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
