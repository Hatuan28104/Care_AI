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

  static const _blue = Color.fromARGB(255, 31, 65, 187);
  static const _bg = Color(0xFFF3F5F9);

  static final List<Map<String, String>> _humans = [
    {
      'name': 'Luna - Nurse',
      'desc': 'Provides compassionate care and medical support.',
      'img': 'assets/images/Luna.png',
    },
    {
      'name': 'Anna - Lawyer',
      'desc': 'Gives legal advice and document assistance.',
      'img': 'assets/images/Anna.png',
    },
    {
      'name': 'Nutrition Expert',
      'desc': 'Customized meal plans and nutrition advice.',
      'img': 'assets/images/Nutrition.png',
    },
    {
      'name': 'Zodiac Expert',
      'desc': 'Personalized insights based on your zodiac sign.',
      'img': 'assets/images/Zodiac.png',
    },
    {
      'name': 'Fitness Trainer',
      'desc': 'Exercises adapted to your health condition.',
      'img': 'assets/images/Fitness.png',
    },
    {
      'name': 'Mindfulness Mentor',
      'desc': 'Meditation and breathing guidance.',
      'img': 'assets/images/Mindfulness.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Container(
              height: 1,
              width: double.infinity,
              color: Colors.black.withOpacity(0.08),
            ),
            const SizedBox(height: 10),
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
              color: Color.fromARGB(255, 31, 65, 187),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _goPremium(context),
            child: _iconBadge(Icons.auto_awesome),
          ),
          const SizedBox(width: 12),
          _notificationIcon(context),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _go(context, const SettingsScreen()),
            child: const Icon(Icons.settings_outlined, size: 25),
          ),
        ],
      ),
    );
  }

  // ===== PREMIUM BANNER (FIX icon PRO bị viền/nền trắng) =====
  Widget _premiumBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: () => _goPremium(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // ✅ ICON PRO: tròn trắng
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white, // 👈 nền TRẮNG
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/pro.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Text(
                  "Your free 3-day Premium hasn't been claimed yet. Tap to claim.",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== CONTENT =====
  Widget _content(BuildContext context) {
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
          const SizedBox(height: 3),
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
              style: TextStyle(
                  color: Color(0xFF1877F1),
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _iconBadge(IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1E40AF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Icon(icon, color: const Color(0xFFFFFFFF), size: 18),
    );
  }

  // ✅ FIX: asset image + bo góc chuẩn, không tràn
  Widget _humanCard(Map<String, String> h) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black.withOpacity(.6),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // ẢNH – KHÔNG OVERLAY
            Positioned.fill(
              child: Image.asset(
                h['img']!,
                fit: BoxFit.cover,
              ),
            ),

            // TEXT TRỰC TIẾP (KHÔNG NỀN)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    h['desc']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
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
                  fontSize: 18,
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
              const Icon(Icons.notifications_none, size: 25),
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
      selectedItemColor: const Color(0xFF1877F2),
      unselectedItemColor: const Color(0xFFADADAD),
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
