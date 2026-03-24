import 'package:flutter/material.dart';
import 'package:Care_AI/app_settings.dart';
import 'package:Care_AI/screens/settings/settings.dart';
import 'package:Care_AI/api/profile_api.dart' as profile_api;
import 'package:Care_AI/screens/settings/profile/create_profile.dart';
import 'package:Care_AI/models/tr.dart';

import 'home_conten/home_tab.dart';
import 'familycenter/family_tab.dart';
import 'decive/device_tab.dart';
import 'history/history_tab.dart';
import 'home_conten/alert.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final int initialIndex;

  const HomeScreen({
    super.key,
    required this.userId,
    this.initialIndex = 0,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  int _deviceTabKey = 0;

  bool _checkingProfile = true;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    if (_currentIndex == 2) {
      _deviceTabKey++;
    }

    _ensureCompletedProfile();
  }

  /* ================= PROFILE CHECK ================= */

  Future<void> _ensureCompletedProfile() async {
    try {
      final profile = await profile_api.ProfileApi.getProfile(widget.userId);

      if (!_isProfileCompleted(profile)) {
        if (!mounted) return;

        final phone = (profile?['soDienThoai'] ?? '').toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CreateProfileScreen(
              nguoiDungId: widget.userId,
              phone: phone,
            ),
          ),
        );
        return;
      }
    } catch (_) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreateProfileScreen(
            nguoiDungId: widget.userId,
            phone: '',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _checkingProfile = false);
  }

  bool _isProfileCompleted(Map<String, dynamic>? profile) {
    if (profile == null) return false;

    final fullName = (profile['tenND'] ?? '').toString().trim();
    final normalizedName = fullName.toLowerCase();
    final birthDate = (profile['ngaySinh'] ?? '').toString().trim();
    final gender = profile['gioiTinh'];
    final height = (profile['chieuCao'] as num?)?.toDouble();
    final weight = (profile['canNang'] as num?)?.toDouble();

    final hasName = fullName.isNotEmpty &&
        normalizedName != 'người dùng mới' &&
        normalizedName != 'nguoi dung moi';

    final hasBirthDate = birthDate.isNotEmpty;
    final hasGender = gender == 0 || gender == 1;
    final hasHeight = height != null && height > 0;
    final hasWeight = weight != null && weight > 0;

    return hasName && hasBirthDate && hasGender && hasHeight && hasWeight;
  }

  /* ================= TABS ================= */

  List<Widget> get _tabs => [
        HomeTab(userId: widget.userId),
        const FamilyTab(),
        DeviceTabRouter(key: ValueKey(_deviceTabKey)),
        HistoryTab(userId: widget.userId),
      ];

  @override
  Widget build(BuildContext context) {
    if (_checkingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
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
      bottomNavigationBar: _bottomNav(context),
    );
  }

  /* ================= HEADER ================= */

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

  /* ================= NOTIFICATION ================= */

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
                      color: Color(0xFF1877F2),
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

  /* ================= BOTTOM NAV ================= */

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF1877F2),
      unselectedItemColor: const Color(0xFFADADAD),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
          if (index == 2) _deviceTabKey++; // reload device tab
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: context.tr.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.group_outlined),
          label: context.tr.family,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.graphic_eq),
          label: context.tr.deviceTab,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: context.tr.history,
        ),
      ],
    );
  }

  /* ================= NAV ================= */

  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
