import 'package:flutter/material.dart';
import '../../../models/tr.dart';

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1877F2);
  static const Color _bg = Color(0xFFF6F6F6);

  // ===== STATE =====
  bool heartRate = false;
  bool temperature = false;
  bool bloodPressure = false;
  bool steps = false;
  bool sleep = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _titleBar(context),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  // ================= TITLE BAR =================
  Widget _titleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.tr.healthData,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        _healthItem(
          icon: Icons.favorite,
          label: 'Nhịp tim',
          value: heartRate,
          onChanged: (v) => setState(() => heartRate = v),
        ),
        _healthItem(
          icon: Icons.thermostat,
          label: 'Nhiệt độ cơ thể',
          value: temperature,
          onChanged: (v) => setState(() => temperature = v),
        ),
        _healthItem(
          icon: Icons.monitor_heart,
          label: 'Huyết áp',
          value: bloodPressure,
          onChanged: (v) => setState(() => bloodPressure = v),
        ),
        _healthItem(
          icon: Icons.directions_walk,
          label: 'Số bước',
          value: steps,
          onChanged: (v) => setState(() => steps = v),
        ),
        _healthItem(
          icon: Icons.bedtime,
          label: 'Giấc ngủ',
          value: sleep,
          onChanged: (v) => setState(() => sleep = v),
        ),
        const SizedBox(height: 28),
        _saveButton(),
      ],
    );
  }

  // ================= HEALTH ITEM =================
  Widget _healthItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: _blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged, // ✅ ĐÚNG
            activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
            inactiveTrackColor: const Color.fromARGB(255, 218, 217, 217),
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // ================= SAVE BUTTON =================
  Widget _saveButton() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            // TODO: handle save
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            context.tr.save,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
