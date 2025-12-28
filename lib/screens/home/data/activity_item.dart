import 'package:flutter/material.dart';

class ActivityItem {
  final String title;        // Steps, Calories, Distance
  final int value;           // 1960
  final String unit;         // steps, kcal, km
  final IconData icon;
  final Color iconColor;
  final String time;         // Today, Yesterday,...

  const ActivityItem({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.time,
  });
}
