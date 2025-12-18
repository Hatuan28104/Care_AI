import 'package:flutter/material.dart';
import 'package:Care_AI/app_settings.dart';
import 'package:Care_AI/screens/settings/settings.dart';

import 'digital_human.dart';
import 'premium.dart';
import 'alert.dart';
import 'decive/device_screen.dart';

import 'data/basic_health_data.dart';
import 'data/activity_data.dart';
import 'data/metric_item.dart';

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

          // PRO icon -> Premium
          GestureDetector(
            onTap: () => _goPremium(context),
            child: _iconBadge(Icons.auto_awesome),
          ),

          const SizedBox(width: 12),

          // Notification icon (badge)
          _notificationIcon(context),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: () => _go(context, const SettingsScreen()),
            child: const Icon(Icons.settings_outlined, size: 22),
          ),
        ],
      ),
    );
  }

  // ===== PREMIUM BANNER =====
  Widget _premiumBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
    // demo data
    final basicDemo = [
      const MetricItem(
        icon: Icons.favorite,
        iconColor: Colors.red,
        title: 'Heart rate',
        value: '72',
        unit: 'BPM',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.bloodtype,
        iconColor: Colors.blue,
        title: 'Blood pressure',
        value: '120 / 80',
        unit: 'mmHg',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.monitor_heart,
        iconColor: Colors.indigo,
        title: 'Blood oxygen - SpO₂',
        value: '98',
        unit: '%',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.thermostat,
        iconColor: Colors.orange,
        title: 'Body temperature',
        value: '36.8',
        unit: '°C',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.fitness_center,
        iconColor: Colors.purple,
        title: 'BMI',
        value: '21.5',
        unit: 'kg/m²',
        time: '18:30',
      ),
    ];

    final activityDemo = [
      const MetricItem(
        icon: Icons.directions_walk,
        iconColor: Colors.red,
        title: 'Steps',
        value: '600',
        unit: 'steps',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.route,
        iconColor: Colors.orange,
        title: 'Walking + Running Distance',
        value: '3.0',
        unit: 'km',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.bedtime,
        iconColor: Colors.indigo,
        title: 'Sleep duration',
        value: '7.5',
        unit: 'hours',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.auto_graph,
        iconColor: Colors.blue,
        title: 'Sleep quality',
        value: '85',
        unit: '%',
        time: '18:30',
      ),
      const MetricItem(
        icon: Icons.local_fire_department,
        iconColor: Colors.purple,
        title: 'Exercise level',
        value: '50',
        unit: 'minutes',
        time: '18:30',
      ),
    ];

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
            onTap: () => _go(context, BasicHealthDataScreen(items: basicDemo)),
          ),
          const SizedBox(height: 10),
          _categoryItem(
            icon: Icons.local_fire_department,
            iconColor: Colors.red,
            text: 'Activity data',
            onTap: () => _go(context, ActivityDataScreen(items: activityDemo)),
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
              style: TextStyle(color: _blue, fontWeight: FontWeight.w600),
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
      ),
    );
  }

  // ===== NOTIFICATION ICON =====
  Widget _notificationIcon(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AlertScreen()),
        );
      },
      child: ValueListenableBuilder<int>(
        valueListenable: AppSettings.unreadAlertCount,
        builder: (_, count, __) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none, size: 22),
              if (count > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F6BFF),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: _blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 2) {
          _go(context, const DeviceScreen());
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
