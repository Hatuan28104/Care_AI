import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'familycenter_dependent_proflie.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyDependentsScreen extends StatefulWidget {
  const MyDependentsScreen({super.key});

  @override
  State<MyDependentsScreen> createState() => _MyDependentsScreenState();
}

class _MyDependentsScreenState extends State<MyDependentsScreen> {
  static const Color _blue = Color(0xFF1877F2);
  static const Color _red = Color(0xFFFE4343);

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
      final deps = await FamilyApi.getMyDependents();

      setState(() {
        invites = incoming;
        dependents = deps;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = [
      ...invites.map((e) => {'type': 'invite', 'data': e}),
      ...dependents.map((e) => {'type': 'joined', 'data': e}),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 14), // 👈 spacing chuẩn
      itemBuilder: (context, index) {
        final item = items[index];
        if (item['type'] == 'invite') {
          return _inviteCard(item['data']);
        }
        return _joinedCard(item['data']);
      },
    );
  }

  // ================= INVITE CARD =================
  Widget _inviteCard(dynamic inv) {
    return Container(
      height: 123,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _avatar(inv['AvatarUrl']),
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
                        onTap: () => _showAcceptDialog(inv['LoiMoi_ID']),
                        child: _actionBtn('Chấp nhận', _blue),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showRejectDialog(inv['LoiMoi_ID']),
                        child: _actionBtn('Từ chối', _red),
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
    return Slidable(
      key: ValueKey(dep['QuanHeGiamHo_ID']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) async {
              final ok = await _showDeleteConfirm(context);
              if (ok == true) {
                await FamilyApi.endRelationship(dep['QuanHeGiamHo_ID']);
                _loadData();
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
      child: GestureDetector(
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
          height: 123,
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              _avatar(dep['AvatarUrl']),
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
                      style: const TextStyle(
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
      ),
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

  // ================= ACTION =================
  Future<void> _acceptConfirmed(String loiMoiId) async {
    await FamilyApi.acceptInvite(loiMoiId);
    _loadData();
  }

  Future<void> _rejectConfirmed(String loiMoiId) async {
    await FamilyApi.rejectInvite(loiMoiId);
    _loadData();
  }

  // ================= ACCEPT POPUP =================
  void _showAcceptDialog(String loiMoiId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _blue,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Xác nhận lời mời',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn có muốn nhận lời mời không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _acceptConfirmed(loiMoiId);
                    },
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
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

  // ================= REJECT POPUP =================
  void _showRejectDialog(String loiMoiId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _red, width: 4),
                  ),
                  child: const Icon(
                    Icons.priority_high,
                    color: _red,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Xác nhận xóa lời mời',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn có chắc chắn muốn từ chối lời mời này không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red.withOpacity(.3),
                      foregroundColor: _red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _rejectConfirmed(loiMoiId);
                    },
                    child: const Text(
                      'Xóa',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
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

  Widget _avatar(String? avatarUrl) {
    final avatar = FamilyApi.normalizeAvatar(avatarUrl);

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: avatar == null ? _blue.withOpacity(.1) : null,
        image: avatar != null
            ? DecorationImage(
                image: NetworkImage(avatar),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatar == null
          ? const Icon(Icons.person, color: _blue, size: 36)
          : null,
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
