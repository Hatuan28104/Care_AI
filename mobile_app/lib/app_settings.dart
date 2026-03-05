import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/login_history_item.dart';

class AppSettings {
  static final ValueNotifier<double> textScale = ValueNotifier<double>(1.1);

  static final ValueNotifier<Locale> locale =
      ValueNotifier(WidgetsBinding.instance.platformDispatcher.locale);
  static final ValueNotifier<bool> notificationOn = ValueNotifier<bool>(true);

  static final ValueNotifier<bool> healthAlertOn = ValueNotifier<bool>(true);

  static final ValueNotifier<bool> syncDataOn = ValueNotifier<bool>(true);

  static final ValueNotifier<int> unreadAlertCount = ValueNotifier<int>(0);

  static final ValueNotifier<String> phoneNumber = ValueNotifier<String>("");

  static final ValueNotifier<List<LoginHistoryItem>> loginHistory =
      ValueNotifier<List<LoginHistoryItem>>([]);

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    textScale.value = _prefs?.getDouble('textScale') ?? 1.1;

    notificationOn.value = _prefs?.getBool('notificationOn') ?? true;

    healthAlertOn.value = _prefs?.getBool('healthAlertOn') ?? true;

    syncDataOn.value = _prefs?.getBool('syncDataOn') ?? true;

    // 🔥 LOAD LANGUAGE
    final savedLang = _prefs?.getString('locale');
    if (savedLang != null) {
      locale.value = Locale(savedLang);
    }

    // 🔥 SAVE LANGUAGE
    locale.addListener(() {
      _prefs?.setString('locale', locale.value.languageCode);
    });

    textScale.addListener(() {
      _prefs?.setDouble('textScale', textScale.value);
    });

    notificationOn.addListener(() {
      _prefs?.setBool('notificationOn', notificationOn.value);
    });

    healthAlertOn.addListener(() {
      _prefs?.setBool('healthAlertOn', healthAlertOn.value);
    });

    syncDataOn.addListener(() {
      _prefs?.setBool('syncDataOn', syncDataOn.value);
    });
  }
}
