import 'package:flutter/material.dart';

class AppSettings {
  // ===== TEXT SIZE =====
  static final ValueNotifier<double> textScale = ValueNotifier<double>(1.0);

  // ===== NOTIFICATIONS =====
  static final ValueNotifier<bool> notificationOn = ValueNotifier<bool>(false);

  // ===== DEVICE =====
  static final ValueNotifier<bool> healthAlertOn = ValueNotifier<bool>(false);

  static final ValueNotifier<bool> syncDataOn = ValueNotifier<bool>(false);
}
