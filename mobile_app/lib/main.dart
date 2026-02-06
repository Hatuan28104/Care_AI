import 'package:flutter/material.dart';
import 'screens/intro_screen.dart';
import 'app_settings.dart';
import 'api/auth_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStorage.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: AppSettings.textScale,
      builder: (context, scale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Poppins',
          ),
          title: 'Care AI',
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            return MediaQuery(
              data: mq.copyWith(textScaler: TextScaler.linear(scale)),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashIntroScreen(),
        );
      },
    );
  }
}
