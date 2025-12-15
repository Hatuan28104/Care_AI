import 'package:flutter/material.dart';
import 'digital_human.dart';
import 'package:Care_AI/screens/settings/settings.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);

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
    {
      'name': 'Fitness Trainer',
      'desc': 'Exercises adapted to your health condition.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
    {
      'name': 'Mindfulness Mentor',
      'desc': 'Meditation and breathing guidance.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
  ];

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _premiumBanner(),
            const SizedBox(height: 18),
            Expanded(child: _content(context)),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
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
          _iconBadge(Icons.auto_awesome),
          const SizedBox(width: 12),
          const Icon(Icons.notifications_none, size: 22),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _go(context, const SettingsScreen()),
            child: const Icon(Icons.settings_outlined, size: 22),
          ),
        ],
      ),
    );
  }

  // ===== PREMIUM =====
  Widget _premiumBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: const [
            Icon(Icons.smart_toy, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Your free 3-day Premium hasn't been claimed yet. Tap to claim.",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
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

  // ===== DIGITAL HUMAN LIST =====
  Widget _digitalHumanList() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
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
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: action,
            child: const Text(
              'See All',
              style: TextStyle(
                color: _blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _iconBadge(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _blue.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(icon, color: _blue, size: 18),
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
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(h['name']!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(h['desc']!,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
            child: Text(text,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  // ===== NAV =====
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: _blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined), label: 'Family Center'),
        BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: 'Device'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      ],
    );
  }

  // ===== NAV HELPER =====
  static void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
