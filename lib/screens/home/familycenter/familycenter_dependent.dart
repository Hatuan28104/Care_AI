import 'package:flutter/material.dart';
import 'familycenter_guardians.dart';
import 'familycenter_dependent_proflie.dart';
import 'package:Care_AI/screens/home/home.dart';
import 'package:Care_AI/screens/home/decive/note.dart';
import 'package:Care_AI/screens/home/history/history_screen.dart';

class MyDependentsScreen extends StatelessWidget {
  const MyDependentsScreen({super.key});

  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1F6BFF);
  static const Color _bg = Color(0xFFF3F5F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            _tabs(context),
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

  // ================= TABS =================
  Widget _tabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
      child: Row(
        children: [
          // My Guardians (inactive)
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyGuardiansScreen(),
                  ),
                );
              },
              child: _tabItem(
                icon: Icons.group_outlined,
                text: 'My Guardians',
                active: false,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // My Dependents (active)
          Expanded(
            child: _tabItem(
              icon: Icons.favorite_border,
              text: 'My Dependents',
              active: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required IconData icon,
    required String text,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: active ? null : Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: active ? _blue : Colors.grey),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: active ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      children: [
        _inviteCard(context),
        const SizedBox(height: 14),
        _joinedCard(context),
      ],
    );
  }

  // ================= INVITE CARD =================
  Widget _inviteCard(BuildContext context) {
    return Container(
      height: 123,
      width: 361,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _avatar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'LiLy Lary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionBtn('Accept', _blue),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showDeclineDialog(context),
                        child: _actionBtn('Decline', const Color(0xFFE24F4F)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context) {
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
                // Icon
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

                // Title (CHỈ ĐỔI CHỮ)
                const Text(
                  'Decline Invitation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Description (CHỈ ĐỔI CHỮ)
                const Text(
                  'Are you sure you want to decline\nthe invitation?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 16),

                // Decline (GIỮ NGUYÊN STYLE)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: xử lý decline (để trống theo yêu cầu)
                      Navigator.pop(ctx);
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
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Cancel (GIỮ NGUYÊN)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDEDED),
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

  // ================= JOINED CARD =================
  Widget _joinedCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DependentProfileScreen(),
          ),
        );
      },
      child: Container(
        height: 123,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _avatar(),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edsel Vanily',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Join date: 23/09/2025',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          blurRadius: 14,
          color: Colors.black12,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  Widget _avatar() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: _blue.withOpacity(.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.person, color: _blue, size: 36),
    );
  }

  Widget _actionBtn(String text, Color color) {
    return Container(
      width: 90,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
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
