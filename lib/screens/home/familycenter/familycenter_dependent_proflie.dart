import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'package:Care_AI/screens/home/decive/note.dart';
import 'package:Care_AI/screens/home/history/history_screen.dart';

class DependentProfileScreen extends StatelessWidget {
  const DependentProfileScreen({super.key});

  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1F6BFF);
  static const Color _bg = Color(0xFFF3F5F9);
  static const Color _itemBg = Color(0xFFF6F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            _profileHeader(context),
            const SizedBox(height: 16),
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

  // ================= PROFILE HEADER =================
  Widget _profileHeader(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 52,
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1527980965255-d3b416303d12',
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Rober Joshon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        _infoItem('Full name', 'Rober Joshon'),
        _infoItem('Date of birth', '20/01/1978'),
        _infoItem('Gender', 'Male'),
        _infoItem('Join date', '23/09/2025'),
        const SizedBox(height: 8),
        const Text(
          'Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _reportItem('Day')),
            const SizedBox(width: 12),
            Expanded(child: _reportItem('Week')),
            const SizedBox(width: 12),
            Expanded(child: _reportItem('Month')),
          ],
        ),
      ],
    );
  }

  // ================= INFO ITEM =================
  Widget _infoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _itemBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= REPORT ITEM =================
  static Widget _reportItem(String label) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.bar_chart, size: 18, color: Colors.grey),
              SizedBox(width: 4),
              Icon(Icons.bar_chart, size: 18, color: _blue),
              SizedBox(width: 4),
              Icon(Icons.bar_chart, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
