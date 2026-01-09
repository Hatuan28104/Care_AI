import 'package:flutter/material.dart';
import 'history_detail.dart';

import 'package:Care_AI/screens/home/home.dart';
import 'package:Care_AI/screens/home/decive/device_screen.dart';
import 'package:Care_AI/screens/home/familycenter/familycenter_guardians.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const Color blue = Color(0xFF1F6BFF);
  static const Color textDark = Color(0xFF0D459F);
  static const Color bgItem = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _title(),
            _content(context),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Row(
            children: [
              const Text(
                'Care AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: blue.withOpacity(.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.auto_awesome, color: blue, size: 18),
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

  // ===== TITLE =====
  Widget _title() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Text(
        'History',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ===== CONTENT =====
  Widget _content(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: [
          _sectionTitle('TODAY'),
          _historyItem(context,
              title: 'Nora - News', time: '20.10.2025   12:58'),
          const SizedBox(height: 16),
          _sectionTitle('PREVIOUS 7 DAYS'),
          _historyItem(context,
              title: 'Mira - Story', time: '11.10.2025   12:58'),
        ],
      ),
    );
  }

  // ===== SECTION TITLE =====
  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ===== HISTORY ITEM =====
  static Widget _historyItem(
    BuildContext context, {
    required String title,
    required String time,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(title: title, subtitle: time),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgItem,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showActions(context),
              child: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ===== BOTTOM SHEET =====
  static void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('Choose Action',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MyGuardiansScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DeviceScreen()),
          );
        } else if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
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
