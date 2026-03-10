import 'package:flutter/material.dart';
import '../../../models/tr.dart';

class ReportDetailScreen extends StatelessWidget {
  final String type; // day | week | month

  const ReportDetailScreen({super.key, required this.type});

  String title(BuildContext context) {
    switch (type) {
      case 'week':
        return context.tr.week;
      case 'month':
        return context.tr.month;
      default:
        return context.tr.day;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.blue),
        title: Text(
          title(context),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _heartCard(context),
            const SizedBox(height: 16),
            _grid(),
            const SizedBox(height: 16),
            _statItem('Số bước', '-- bước'),
            _statItem('Quãng đường', '-- km'),
            _statItem('Calo', '-- kcal'),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _heartCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, size: 40, color: Colors.red),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '-- BPM',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                context.tr.noData,
                style: TextStyle(color: Colors.red),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _grid() {
    return Row(
      children: [
        Expanded(child: _mini('Nhiệt độ', '-- °C')),
        const SizedBox(width: 12),
        Expanded(child: _mini('Ngủ', '--')),
      ],
    );
  }

  Widget _mini(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.red)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
