import 'package:flutter/material.dart';
import 'login/login.dart';
import 'register/register.dart';
import '../ui.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UI.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Image.asset(
                'assets/images/Logo.png',
                height: 260,
              ),
              const SizedBox(height: 30),
              Text(
                'Welcome, Care AI',
                textAlign: TextAlign.center,
                style: UI.primaryTitle.copyWith(
                  color: const Color(0xFF0D459F),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your digital friend, your family's peace of mind.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    _button(
                      text: 'Login',
                      filled: true,
                      onTap: () => _go(context, const LoginScreen()),
                    ),
                    const SizedBox(height: 16),
                    _button(
                      text: 'Register',
                      filled: false,
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

  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Widget _button({
    required String text,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F6BFF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D459F),
                side: const BorderSide(color: Color(0xFF0D459F)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
