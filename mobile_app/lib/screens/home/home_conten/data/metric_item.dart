import 'package:flutter/material.dart';

class MetricItem {
  final String metricId;
  final String code;

  final IconData icon;
  final Color iconColor;
  final String title;
  final String unit;

  String value;
  String time;

  MetricItem({
    required this.metricId,
    required this.code,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.unit,
    required this.value,
    required this.time,
  });
}
