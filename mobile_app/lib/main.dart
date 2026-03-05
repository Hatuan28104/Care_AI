import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'screens/intro_screen.dart';
import 'app_settings.dart';
import 'api/auth_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("Foreground notification:");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  });
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print("🔄 New FCM TOKEN: $newToken");

    final jwt = await AuthStorage.getToken();
    if (jwt == null) return;

    await http.post(
      Uri.parse("http://10.0.2.2:3000/auth/save-fcm-token"),
      headers: {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fcmToken": newToken,
      }),
    );
  });
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("New FCM TOKEN: $newToken");
  });
  String? token = await messaging.getToken();
  print("FCM TOKEN: $token");

  await AuthStorage.load();
  await AppSettings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppSettings.locale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<double>(
          valueListenable: AppSettings.textScale,
          builder: (context, scale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                for (var locale in supportedLocales) {
                  if (locale.languageCode == deviceLocale?.languageCode) {
                    return locale;
                  }
                }
                return supportedLocales.first;
              },
              builder: (context, child) {
                final mq = MediaQuery.of(context);
                return MediaQuery(
                  data: mq.copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: const SplashIntroScreen(),
            );
          },
        );
      },
    );
  }
}
