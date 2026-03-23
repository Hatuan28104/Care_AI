import 'package:flutter/material.dart';
import 'familycenter_guardians.dart';
import 'familycenter_dependent.dart';
import 'package:demo_app/models/tr.dart';

class FamilyTab extends StatefulWidget {
  const FamilyTab({super.key});

  @override
  State<FamilyTab> createState() => _FamilyTabState();
}

class _FamilyTabState extends State<FamilyTab> {
  int _index = 0;
  static const Color blue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _tabs(),
        Expanded(
          child: IndexedStack(
            index: _index,
            children: const [
              MyGuardiansScreen(),
              MyDependentsScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _index = 0),
              child: _tabItem(
                icon: Icons.group_outlined,
                text: context.tr.guardians,
                active: _index == 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _index = 1),
              child: _tabItem(
                icon: Icons.favorite_border,
                text: context.tr.dependents,
                active: _index == 1,
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
          Icon(icon, size: 18, color: active ? blue : Colors.grey),
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
}
