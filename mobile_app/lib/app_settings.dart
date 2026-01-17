import 'package:flutter/material.dart';

class AppSettings {
  // ===== TEXT SIZE =====
  static final ValueNotifier<double> textScale = ValueNotifier<double>(1.0);

  // ===== NOTIFICATIONS =====
  static final ValueNotifier<bool> notificationOn = ValueNotifier<bool>(false);

  // ===== DEVICE =====
  static final ValueNotifier<bool> healthAlertOn = ValueNotifier<bool>(false);

  static final ValueNotifier<bool> syncDataOn = ValueNotifier<bool>(false);

  static ValueNotifier<int> unreadAlertCount = ValueNotifier<int>(0);

  static final phoneNumber = ValueNotifier<String>(''); // "(+84) ..."
  static final loginHistory = ValueNotifier<List<LoginHistoryItem>>([]);
}

class LoginHistoryItem {
  final String device;
  final String location;
  final String time;

  const LoginHistoryItem({
    required this.device,
    required this.location,
    required this.time,
  });
}
