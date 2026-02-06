import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'familycenter_guardian_add.dart';
import 'familycenter_guardian_profile.dart';

class MyGuardiansScreen extends StatefulWidget {
  const MyGuardiansScreen({super.key});

  @override
  State<MyGuardiansScreen> createState() => _MyGuardiansScreenState();
}

class _MyGuardiansScreenState extends State<MyGuardiansScreen> {
  List<dynamic> guardians = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadGuardians();
  }

  Future<void> _loadGuardians() async {
    try {
      final data = await FamilyApi.getMyGuardians();
      setState(() {
        guardians = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _addButton(),
        Expanded(child: _content()),
      ],
    );
  }

  Widget _addButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 18, 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddGuardians()),
            );

            // 🔥 GIỜ GỌI ĐƯỢC
            _loadGuardians();
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
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (guardians.isEmpty) {
      return const Center(
        child: Text('Chưa có người giám hộ'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      itemCount: guardians.length,
      itemBuilder: (context, index) {
        final g = guardians[index];
        return GuardianCard(
          name: g['TenND'] ?? 'Không tên',
          date: _formatDate(g['NgayBatDau']),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GuardianProfile(
                  quanHeId: g['QuanHeGiamHo_ID'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ================= GUARDIAN CARD =================
class GuardianCard extends StatelessWidget {
  final String name;
  final String date;
  final VoidCallback onTap;

  const GuardianCard({
    super.key,
    required this.name,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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

// ================= HELPER =================
String _formatDate(dynamic raw) {
  if (raw == null) return '--/--/----';
  final d = DateTime.tryParse(raw.toString());
  if (d == null) return '--/--/----';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
