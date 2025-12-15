import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'app_settings.dart'; // 👈 thêm dòng này

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppSettings.textScale, // 👈 nghe textScale toàn app
      builder: (context, scale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Care AI',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D459F),
            ),
            useMaterial3: true,
          ),

          // 🔥 ÁP DỤNG TEXT SIZE TOÀN APP
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: scale,
              ),
              child: child!,
            );
          },

          // 👇 KHÔNG TRUYỀN GÌ NỮA
          home: const WelcomeScreen(),
        );
      },
    );
  }
}
