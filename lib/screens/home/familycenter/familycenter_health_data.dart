import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'package:Care_AI/screens/home/decive/note.dart';
import 'package:Care_AI/screens/home/history/history_screen.dart';

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1F6BFF);
  static const Color _bg = Color(0xFFF3F5F9);

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
            _header(),
            _titleBar(context),
            Expanded(child: _content()),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  // ================= HEADER =================

  Widget _header() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          child: Row(
            children: [
              const Text(
                'Care AI',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 31, 65, 187),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.auto_awesome, color: _blue, size: 18),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.notifications_none),
              const SizedBox(width: 12),
              const Icon(Icons.settings_outlined),
            ],
          ),
        ),
        Container(
          height: 1,
          width: double.infinity,
          color: Colors.black.withOpacity(0.08),
        ),
      ],
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
          const Expanded(
            child: Center(
              child: Text(
                'Health data',
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
          label: 'Heart rate',
          value: heartRate,
          onChanged: (v) => setState(() => heartRate = v),
        ),
        _healthItem(
          icon: Icons.thermostat,
          label: 'Temperature',
          value: temperature,
          onChanged: (v) => setState(() => temperature = v),
        ),
        _healthItem(
          icon: Icons.monitor_heart,
          label: 'Blood pressure',
          value: bloodPressure,
          onChanged: (v) => setState(() => bloodPressure = v),
        ),
        _healthItem(
          icon: Icons.directions_walk,
          label: 'Steps',
          value: steps,
          onChanged: (v) => setState(() => steps = v),
        ),
        _healthItem(
          icon: Icons.bedtime,
          label: 'Sleep',
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
            activeColor: _blue,
            onChanged: onChanged,
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
          child: const Text(
            'Save',
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

  // ================= BOTTOM NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: _blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DeviceScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined), label: 'Family Center'),
        BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: 'Device'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
    );
  }
}
