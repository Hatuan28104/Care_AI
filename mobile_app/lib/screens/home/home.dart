import 'package:flutter/material.dart';
import 'package:Care_AI/app_settings.dart';
import 'package:Care_AI/screens/settings/settings.dart';

import 'home_conten/home_tab.dart';
import 'familycenter/family_tab.dart';
import 'decive/device_tab.dart';
import 'history/history_tab.dart';

import 'home_conten/premium.dart';
import 'home_conten/alert.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _bg = Color(0xFFF6F6F6);

  int _currentIndex = 0;

  final _tabs = const [
    HomeTab(),
    FamilyTab(),
    DeviceTab(),
    HistoryTab(),
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
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _tabs,
              ),
            ),
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
              color: Color(0xFF1F41BB),
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

  Widget _iconBadge(IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3B82F6),
            Color(0xFF1E40AF),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  // ===== NOTIFICATION =====
  Widget _notificationIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => _go(context, const AlertScreen()),
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
  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF1877F2),
      unselectedItemColor: const Color(0xFFADADAD),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() => _currentIndex = index);
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
