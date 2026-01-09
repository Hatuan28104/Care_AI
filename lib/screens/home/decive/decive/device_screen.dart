import 'package:flutter/material.dart';
import 'device_scan.dart';
import 'device_add.dart';

import 'package:Care_AI/screens/home/home.dart';
import 'package:Care_AI/screens/home/familycenter/familycenter_guardians.dart';
import 'package:Care_AI/screens/home/history/history_screen.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1F6BFF);
  static const Color _bg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(child: _content(context)),
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
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D459F),
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
              const Icon(Icons.notifications_none, size: 22),
              const SizedBox(width: 12),
              const Icon(Icons.settings_outlined, size: 22),
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

  // ================= CONTENT =================
  Widget _content(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // ===== DEVICE IMAGE =====
        Center(
          child: Container(
            width: 300,
            height: 300,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black12,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                'assets/images/decive.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        const Spacer(),

        // ===== ACTION BUTTONS =====
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 300),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Scanner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddDeviceScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Add device',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= BOTTOM NAV =================
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: _blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MyGuardiansScreen()),
          );
        } else if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_outlined),
          label: 'Family Center',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.graphic_eq),
          label: 'Device',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
      ],
    );
  }
}
