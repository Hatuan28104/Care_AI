import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'familycenter_dependent_proflie.dart';
import 'package:Care_AI/api/auth_storage.dart';

class MyDependentsScreen extends StatefulWidget {
  const MyDependentsScreen({super.key});

  @override
  State<MyDependentsScreen> createState() => _MyDependentsScreenState();
}

class _MyDependentsScreenState extends State<MyDependentsScreen> {
  static const Color _blue = Color(0xFF1877F2);

  List<dynamic> invites = [];
  List<dynamic> dependents = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final incoming = await FamilyApi.getIncomingInvites();

      setState(() {
        invites = incoming;
      });

      try {
        final deps = await FamilyApi.getMyDependents();
        setState(() {
          dependents = deps;
        });
      } catch (_) {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      children: [
        ...invites.map(_inviteCard).toList(),
        if (invites.isNotEmpty && dependents.isNotEmpty)
          const SizedBox(height: 14),
        ...dependents.map(_joinedCard).toList(),
      ],
    );
  }

  // ================= INVITE CARD =================
  Widget _inviteCard(dynamic inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 123,
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
                  Text(
                    inv['TenND'] ?? 'Không tên',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _accept(inv['LoiMoi_ID']),
                        child: _actionBtn('Chấp nhận', _blue),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _reject(inv['LoiMoi_ID']),
                        child: _actionBtn('Từ chối', const Color(0xFFFE4343)),
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

  // ================= JOINED CARD =================
  Widget _joinedCard(dynamic dep) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DependentProfileScreen(
              quanHeId: dep['QuanHeGiamHo_ID'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 123,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _avatar(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dep['TenND'] ?? 'Không tên',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ngày tham gia: ${_formatDate(dep['NgayBatDau'])}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ACTION =================
  Future<void> _accept(String loiMoiId) async {
    await FamilyApi.acceptInvite(loiMoiId);
    _loadData();
  }

  Future<void> _reject(String loiMoiId) async {
    await FamilyApi.rejectInvite(loiMoiId);
    _loadData();
  }

  // ================= UI HELPERS =================
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
}

// ================= HELPER =================
String _formatDate(dynamic raw) {
  if (raw == null) return '--/--/----';
  final d = DateTime.tryParse(raw.toString());
  if (d == null) return '--/--/----';
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
