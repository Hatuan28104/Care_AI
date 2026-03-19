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
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

// ✅ BASE URL theo platform
final baseUrl = kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";

// ✅ Background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init Firebase đúng chuẩn (web + mobile)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ✅ xin quyền
  await messaging.requestPermission();

// ✅ nhận noti khi app mở
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Foreground notification:");
    AppSettings.alertVersion.value++;

    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
  });

// ✅ mở từ background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🔥 OPEN FROM BACKGROUND");
    AppSettings.alertVersion.value++;
  });

// ✅ mở từ killed
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    print("🔥 OPEN FROM TERMINATED");
    AppSettings.alertVersion.value++;
  }

  // ✅ load storage TRƯỚC
  await AuthStorage.load();
  final jwt = await AuthStorage.getToken();

  // ✅ TOKEN REFRESH
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print("🔄 New FCM TOKEN: $newToken");

    if (jwt != null) {
      await http.post(
        Uri.parse("$baseUrl/auth/save-fcm-token"),
        headers: {
          "Authorization": "Bearer $jwt",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "fcmToken": newToken,
        }),
      );

      print("✅ Token refreshed → đã update server");
    }
  });

  // ✅ GET TOKEN LẦN ĐẦU
  String? token = await messaging.getToken();
  print("🔥 FCM TOKEN: $token");

  if (token != null && jwt != null) {
    await http.post(
      Uri.parse("$baseUrl/auth/save-fcm-token"),
      headers: {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "fcmToken": token,
      }),
    );

    print("✅ Đã gửi token lên server");
  }

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
              theme: ThemeData(
                scaffoldBackgroundColor: const Color(0xFFF6F6F6),
              ),
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
