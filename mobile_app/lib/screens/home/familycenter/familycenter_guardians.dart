import 'package:flutter/material.dart';
import 'familycenter_guardian_add.dart';
import 'familycenter_guardian_profile.dart';

class MyGuardiansScreen extends StatelessWidget {
  const MyGuardiansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _addButton(context),
        Expanded(child: _content()),
      ],
    );
  }
}

// ================= ADD BUTTON =================
Widget _addButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 12, 18, 6),
    child: Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddGuardians()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFE4343),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Thêm',
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
          MaterialPageRoute(builder: (_) => const GuardianProfile()),
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
                color: const Color(0xFF1877F2).withOpacity(.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person,
                color: Color(0xFF1877F2),
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
                  'Ngày tham gia: $date',
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
