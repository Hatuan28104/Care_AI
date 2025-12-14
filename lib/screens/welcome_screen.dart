import 'package:flutter/material.dart';
import 'login/login.dart';
import 'register/register.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // ===== PHẦN TRÊN =====
              const SizedBox(height: 100),

              Image.asset(
                'assets/images/Logo.png',
                height: 260,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 30),

              const Text(
                'Welcome, Care AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 13, 69, 159),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your digital friend, your family's peace of mind.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  height: 1.5,
                ),
              ),

              // ĐẨY PHẦN NÚT XUỐNG DƯỚI (KHÔNG CỐ ĐỊNH PIXEL)
              const Spacer(),

              // ===== PHẦN NÚT (NEO CAO) =====
              Padding(
                padding: const EdgeInsets.only(bottom: 120), // 👈 CHỈNH SỐ NÀY
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F6BFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color.fromARGB(255, 31, 65, 187),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 31, 65, 187),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
}
