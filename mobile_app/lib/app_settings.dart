import 'package:flutter/material.dart';
import 'models/login_history_item.dart'; 

class AppSettings {
  static final ValueNotifier<double> textScale = ValueNotifier<double>(1.1);
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('vi'));
  static final ValueNotifier<bool> notificationOn = ValueNotifier<bool>(false);

  static final ValueNotifier<bool> healthAlertOn = ValueNotifier<bool>(false);

  static final ValueNotifier<bool> syncDataOn = ValueNotifier<bool>(false);

  static final ValueNotifier<int> unreadAlertCount = ValueNotifier<int>(0);

  static final ValueNotifier<String> phoneNumber = ValueNotifier<String>("");

  static final ValueNotifier<List<LoginHistoryItem>> loginHistory =
      ValueNotifier<List<LoginHistoryItem>>([]);
}
