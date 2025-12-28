import 'package:flutter/material.dart';
import 'login/login.dart';
import 'register/register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _primary = Color(0xFF1F6BFF);
  static const _titleColor = Color(0xFF0D459F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // ===== LOGO =====
              Image.asset(
                'assets/images/Logo.png',
                height: 260,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              // ===== TITLE =====
              const Text(
                'Welcome, Care AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _titleColor,
                ),
              ),

              const SizedBox(height: 12),

              // ===== SUBTITLE =====
              const Text(
                "Your digital friend, your family's peace of mind.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ===== ACTION BUTTONS =====
              Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    _primaryButton(
                      text: 'Login',
                      onTap: () => _go(context, const LoginScreen()),
                    ),
                    const SizedBox(height: 16),
                    _outlineButton(
                      text: 'Register',
                      onTap: () => _go(context, const RegisterScreen()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== NAVIGATION =====
  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ===== BUTTONS =====
  static Widget _primaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static Widget _outlineButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _titleColor,
          side: const BorderSide(color: _titleColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
