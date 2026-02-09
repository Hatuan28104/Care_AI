import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'familycenter_guardian_add.dart';
import 'familycenter_guardian_profile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      itemCount: guardians.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 14), // 👈 spacing ở đây
      itemBuilder: (context, index) {
        final g = guardians[index];

        return Slidable(
          key: ValueKey(g['QuanHeGiamHo_ID']),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (_) async {
                  final ok = await _showDeleteConfirm(context);
                  if (ok == true) {
                    await FamilyApi.endRelationship(g['QuanHeGiamHo_ID']);
                    _loadGuardians();
                  }
                },
                backgroundColor: const Color(0xFFFE4343),
                borderRadius: BorderRadius.circular(20),
                child: const Center(
                  child: Icon(Icons.delete, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          child: GuardianCard(
            name: g['TenND'] ?? 'Không tên',
            date: _formatDate(g['NgayBatDau']),
            avatar: FamilyApi.normalizeAvatar(g['AvatarUrl']),
            onTap: () {},
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: const Icon(Icons.priority_high, color: Colors.red),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Xác nhận xóa',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bạn có chắc chắn muốn xóa người giám hộ này khỏi gia đình không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(125, 255, 100, 100),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(
                        color: Color.fromARGB(221, 140, 24, 35),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(209, 211, 217, 237),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
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
}

// ================= GUARDIAN CARD =================
class GuardianCard extends StatelessWidget {
  final String name;
  final String date;
  final VoidCallback onTap;
  final String? avatar;

  const GuardianCard({
    super.key,
    required this.name,
    required this.date,
    required this.onTap,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              child: avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        avatar!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
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
