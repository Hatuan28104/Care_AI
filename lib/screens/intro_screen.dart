import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashIntroScreen extends StatefulWidget {
  const SplashIntroScreen({super.key});

  @override
  State<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends State<SplashIntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 1. Vòng tròn nở to (0% -> 60%)
    _scale = Tween<double>(begin: 0.2, end: 15.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOutQuart),
      ),
    );

    // 2. Logo mờ nhẹ (không mất hẳn để Hero có cái mà bay)
    _logoOpacity = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // 3. Chữ hiện lên (60% -> 85%)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _navigateToWelcome();
        });
      }
    });
  }

  void _navigateToWelcome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secondAnim) => const WelcomeScreen(),
        transitionDuration:
            const Duration(milliseconds: 800), // Thời gian Hero bay
        transitionsBuilder: (context, anim, secondAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F7CFF), Color(0xFF4B2DBD)],
          ),
        ),
        child: Stack(
          children: [
            // Lớp 1: Vòng tròn trắng tỏa ra
            Center(
              child: AnimatedBuilder(
                animation: _scale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scale.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Lớp 2: Logo (Hero)
            Center(
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Hero(
                  tag: 'care-logo',
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: 180,
                  ),
                ),
              ),
            ),

            // Lớp 3: Chữ "Xin chào" (Hero)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 +
                  100, // Đặt thấp hơn Logo một chút
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Hero(
                  tag: 'care-text',
                  child: Material(
                    color: Colors.transparent,
                    child: const Text(
                      "Care AI, xin chào",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
