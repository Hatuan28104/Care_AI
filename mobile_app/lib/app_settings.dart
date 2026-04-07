import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/login_history_item.dart';

class AppSettings {
  static final ValueNotifier<double> textScale = ValueNotifier<double>(1.1);
  static VoidCallback? reloadAlert;
  static ValueNotifier<int> alertVersion = ValueNotifier(0);
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('vi'));
  static final ValueNotifier<bool> thongbao = ValueNotifier<bool>(true);

  static final ValueNotifier<int> unreadAlertCount = ValueNotifier<int>(0);

  static final ValueNotifier<String> phoneNumber = ValueNotifier<String>("");

  static final ValueNotifier<List<LoginHistoryItem>> loginHistory =
      ValueNotifier<List<LoginHistoryItem>>([]);

  static SharedPreferences? _prefs;
  static Function(String message)? addGlobalAlert;
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    textScale.value = _prefs?.getDouble('textScale') ?? 1.1;

    thongbao.value =
        _prefs?.getBool('thongbao') ?? _prefs?.getBool('Thongbao') ?? true;

    phoneNumber.value = _prefs?.getString('phoneNumber') ?? '';

    final savedLang = _prefs?.getString('locale');
    if (savedLang != null) {
      locale.value = Locale(savedLang);
    }

    locale.addListener(() {
      _prefs?.setString('locale', locale.value.languageCode);
    });

    textScale.addListener(() {
      _prefs?.setDouble('textScale', textScale.value);
    });

    thongbao.addListener(() {
      _prefs?.setBool('thongbao', thongbao.value);
    });

    phoneNumber.addListener(() {
      _prefs?.setString('phoneNumber', phoneNumber.value);
    });
  }
}
