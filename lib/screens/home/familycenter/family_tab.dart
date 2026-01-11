import 'package:flutter/material.dart';
import 'familycenter_dependent.dart';
import 'familycenter_guardian_add.dart';
import 'familycenter_guardian_profile.dart';

const Color accent = Color(0xFF1877F2);

class FamilyTab extends StatelessWidget {
  const FamilyTab({super.key});

  // ===== COLORS (theo Home) =====
  static const Color primary = Color(0xFF1F41BB);
  static const Color accent = Color(0xFF1877F2);
  static const Color bg = Color(0xFFF6F6F6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tabs(context),
        _addButton(context),
        Expanded(child: _content()),
      ],
    );
  }

  // ================= TABS =================
  Widget _tabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
      child: Row(
        children: [
          Expanded(
            child: _tabItem(
              icon: Icons.group_outlined,
              text: 'My Guardians',
              active: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyDependentsScreen(),
                  ),
                );
              },
              child: _tabItem(
                icon: Icons.favorite_border,
                text: 'My Dependents',
                active: false,
              ),
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
          Icon(icon, size: 18, color: active ? accent : Colors.grey),
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

  // ================= ADD BUTTON =================
  Widget _addButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddGuardians(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE24F4F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Add',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: const [
        GuardianCard(
          name: 'Tú Anh',
          date: '23/09/2025',
        ),
      ],
    );
  }
}

// ================= GUARDIAN CARD =================
class GuardianCard extends StatelessWidget {
  final String name;
  final String date;

  const GuardianCard({
    super.key,
    required this.name,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const GuardianProfile(),
          ),
        );
      },
      child: Container(
        height: 123,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              color: Colors.black12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: accent.withOpacity(.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person,
                color: accent,
                size: 36,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join date: $date',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
