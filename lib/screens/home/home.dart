import 'package:flutter/material.dart';
import 'package:Care_AI/screens/settings/settings.dart';
import 'digital_human.dart';
import 'premium.dart';
import 'package:Care_AI/screens/home/decive/device_screen.dart';
import 'package:Care_AI/screens/home/familycenter/familycenter_guardians.dart';
import 'package:Care_AI/screens/home/history/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ===== CONSTANTS =====
  static const Color blue = Color(0xFF1F6BFF);
  static const Color bg = Color(0xFFF3F5F9);

  // ===== DATA =====
  static final List<Map<String, String>> _humans = [
    {
      'name': 'Luna - Nurse',
      'desc': 'Provides compassionate care and medical support.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
    {
      'name': 'Anna - Lawyer',
      'desc': 'Gives legal advice and document assistance.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
    {
      'name': 'Nutrition Expert',
      'desc': 'Customized meal plans and nutrition advice.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _premiumBanner(context),
            const SizedBox(height: 18),
            Expanded(child: _content(context)),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              GestureDetector(
                onTap: () => _goPremium(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: blue,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.notifications_none, size: 22),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () => _go(context, const SettingsScreen()),
                child: const Icon(Icons.settings_outlined, size: 22),
              ),
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

  // ===== PREMIUM BANNER =====
  Widget _premiumBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: GestureDetector(
        onTap: () => _goPremium(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Your free 3-day Premium hasn't been claimed yet. Tap to claim.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ===== CONTENT =====
  Widget _content(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            title: 'Digital Human',
            action: () => _go(context, const DigitalHumanAllScreen()),
          ),
          const SizedBox(height: 12),
          _digitalHumanList(),
          const SizedBox(height: 22),
          const Text(
            'Health Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          _categoryItem(
            icon: Icons.accessibility_new,
            iconColor: Colors.purple,
            text: 'Basic health data',
          ),
          const SizedBox(height: 10),
          _categoryItem(
            icon: Icons.local_fire_department,
            iconColor: Colors.red,
            text: 'Activity data',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ===== LIST =====
  Widget _digitalHumanList() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _humans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _humanCard(_humans[i]),
      ),
    );
  }

  // ===== COMPONENTS =====
  Widget _sectionHeader({required String title, VoidCallback? action}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: action,
            child: const Text(
              'See All',
              style: TextStyle(color: blue, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _humanCard(Map<String, String> h) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(h['img']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(.7), Colors.transparent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              h['name']!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              h['desc']!,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  // ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
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

  // ===== NAV HELPERS =====
  static void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static void _goPremium(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PremiumScreen(),
      ),
    );
  }
}
