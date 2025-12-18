import 'package:flutter/material.dart';
import 'package:Care_AI/screens/home/home.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key});

  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF4D4D),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        color: Color(0xFFFF4D4D),
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Confirm Deletion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Are you sure you want to delete\nthis device?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),

                // Delete
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC1C1),
                      foregroundColor: const Color(0xFFB00000),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Cancel
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9EAEE),
                      foregroundColor: Colors.black54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _deviceCard(),
                    const SizedBox(height: 14),
                    _goodHealthCard(),
                    const SizedBox(height: 16),
                    const Text(
                      "Today's Health Data",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    _gridTopStats(),
                    const SizedBox(height: 12),
                    _barTile(
                      icon: Icons.opacity,
                      iconColor: _blue,
                      title: 'Blood oxygen – SpO₂',
                      valueRight: '98%',
                      progress: 0.82,
                    ),
                    const SizedBox(height: 10),
                    _barTile(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.red,
                      title: 'Calories burned',
                      valueRight: '210 kcal',
                      progress: 0.35,
                    ),
                    const SizedBox(height: 10),
                    _barTile(
                      icon: Icons.accessibility_new,
                      iconColor: Colors.red,
                      title: 'Body temperature',
                      valueRight: '36.8°C',
                      progress: 0.62,
                    ),
                    const SizedBox(height: 10),
                    _barTile(
                      icon: Icons.sentiment_satisfied_alt,
                      iconColor: Colors.orange,
                      title: 'Stress level',
                      valueRight: '45',
                      progress: 0.45,
                    ),
                    const SizedBox(height: 14),
                    _disconnectButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
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
              color: _blue.withOpacity(.10),
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
    );
  }

  // ===== DEVICE CARD =====
  Widget _deviceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F1FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/watch.jpg',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Apple Watch Series Demo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.bluetooth, size: 16, color: Colors.black54),
                    SizedBox(width: 6),
                    Text(
                      'Connected',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.info_outline, color: Colors.black45),
          const SizedBox(width: 10),
          const Icon(Icons.battery_full, color: Colors.green, size: 18),
          const SizedBox(width: 6),
          const Text(
            '85%',
            style:
                TextStyle(fontWeight: FontWeight.w800, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ===== GOOD HEALTH =====
  Widget _goodHealthCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 26),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good health',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your numbers are all within the normal\nrange. Continue to maintain a healthy\nlifestyle!',
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.3,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== GRID TOP STATS =====
  Widget _gridTopStats() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: const [
              _MiniStatCard(
                icon: Icons.favorite_border,
                iconColor: Colors.red,
                title: 'Heart Rate',
                value: '72 BPM',
              ),
              SizedBox(height: 10),
              _MiniStatCard(
                icon: Icons.directions_walk,
                iconColor: _blue,
                title: 'Steps',
                value: '3,247',
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: const [
              _MiniStatCard(
                icon: Icons.monitor_heart_outlined,
                iconColor: Colors.red,
                title: 'Blood pressure',
                value: '120/80',
              ),
              SizedBox(height: 10),
              _MiniStatCard(
                icon: Icons.bedtime_outlined,
                iconColor: _blue,
                title: 'Sleep',
                value: '7h 23m',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== BAR TILE =====
  Widget _barTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String valueRight,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    Text(
                      valueRight,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: const Color(0xFFEDEFF3),
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== DISCONNECT =====
  Widget _disconnectButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFD00000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton.icon(
        onPressed: () => _showDisconnectDialog(context),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Disconnect Device',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ===== BOTTOM NAV =====
  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: _blue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
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

// ===== MINI STAT CARD =====
class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
