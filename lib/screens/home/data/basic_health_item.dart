import 'package:flutter/material.dart';

class BasicHealthItem {
  final IconData icon; // icon hiển thị
  final Color iconColor; // màu icon
  final String title; // tên chỉ số
  final String value; // giá trị (72, 600...)
  final String unit; // đơn vị (BPM, steps...)
  final String time; // thời gian (18:30)

  const BasicHealthItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
    required this.time,
  });
}
