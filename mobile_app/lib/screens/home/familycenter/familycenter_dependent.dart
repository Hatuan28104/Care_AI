import 'package:flutter/material.dart';
import 'dart:async';
import 'package:demo_app/api/family_api.dart';
import 'familycenter_dependent_proflie.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:demo_app/models/tr.dart';
import 'package:demo_app/widgets/common_confirm_dialog.dart';

class MyDependentsScreen extends StatefulWidget {
  const MyDependentsScreen({super.key});

  @override
  State<MyDependentsScreen> createState() => _MyDependentsScreenState();
}

class _MyDependentsScreenState extends State<MyDependentsScreen>
    with WidgetsBindingObserver {
  static const Color _blue = Color(0xFF1877F2);
  static const Color _red = Color(0xFFFE4343);

  List<dynamic> invites = [];
  List<dynamic> dependents = [];
  bool loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _loadData(silent: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData(silent: true);
    }
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => loading = true);
    }
    try {
      final incoming = await FamilyApi.getIncomingInvites();
      final deps = await FamilyApi.getMyDependents();

      if (!mounted) return;
      setState(() {
        invites = incoming;
        dependents = deps;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
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
      separatorBuilder: (_, __) => const SizedBox(height: 14),
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
      height: 96,
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _avatar(inv['nguoidung']?['avatarurl']),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    inv['nguoidung']?['tennd'] ?? context.tr.unknownName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showAcceptDialog(inv['loimoi_id']),
                        child: _actionBtn(context.tr.accept, _blue),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showRejectDialog(inv['loimoi_id']),
                        child: _actionBtn(context.tr.reject, _red),
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
      key: ValueKey(dep['quanhegiamho_id']),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) async {
              final ok = await showConfirmDialog(
                context,
                title: context.tr.confirmDelete,
                message: context.tr.confirmDeleteDependent,
                confirmText: context.tr.delete,
                cancelText: context.tr.cancel,
              );
              if (ok == true) {
                await FamilyApi.endRelationship(dep['quanhegiamho_id']);
                _loadData(silent: true);
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
                quanHeId: dep['quanhegiamho_id'],
              ),
            ),
          );
        },
        child: Container(
          height: 96,
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              _avatar(dep['nguoidung']?['avatarurl']),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dep['nguoidung']?['tennd'] ?? context.tr.unknownName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${context.tr.joinDate}: ${_formatDate(dep['ngaybatdau'])}',
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

  // ================= ACTION =================
  Future<void> _acceptConfirmed(String loiMoiId) async {
    await FamilyApi.acceptInvite(loiMoiId);

    await _loadData(silent: true);
  }

  Future<void> _rejectConfirmed(String loiMoiId) async {
    await FamilyApi.rejectInvite(loiMoiId);

    setState(() {
      invites.removeWhere((e) => e['loimoi_id'] == loiMoiId);
    });
  }

  void _showAcceptDialog(String loiMoiId) async {
    final ok = await showConfirmDialog(
      context,
      title: context.tr.confirmInvite,
      message: context.tr.acceptInviteQuestion,
      confirmText: context.tr.confirm,
      cancelText: context.tr.cancel,
      confirmColor: _blue,
      confirmBackgroundColor: _blue,
      confirmTextColor: Colors.white,
      icon: Icons.check,
    );

    if (ok == true) {
      await _acceptConfirmed(loiMoiId);
    }
  }

  void _showRejectDialog(String loiMoiId) async {
    final ok = await showConfirmDialog(
      context,
      title: context.tr.confirmDeleteInvite,
      message: context.tr.rejectInviteQuestion,
      confirmText: context.tr.delete,
      cancelText: context.tr.cancel,
      confirmColor: _red,
      icon: Icons.priority_high,
    );

    if (ok == true) {
      await _rejectConfirmed(loiMoiId);
    }
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
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: avatar == null ? _blue.withValues(alpha: 0.1) : null,
        image: avatar != null
            ? DecorationImage(
                image: NetworkImage(avatar),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatar == null
          ? const Icon(Icons.person, color: _blue, size: 30)
          : null,
    );
  }

  Widget _actionBtn(String text, Color color) {
    return Container(
      width: 78,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
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
