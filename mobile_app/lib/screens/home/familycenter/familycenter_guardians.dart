import 'package:flutter/material.dart';
import 'dart:async';
import 'package:demo_app/api/family_api.dart';
import 'familycenter_guardian_add.dart';
import 'familycenter_guardian_profile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:demo_app/models/tr.dart';
import 'package:demo_app/widgets/common_confirm_dialog.dart';

class MyGuardiansScreen extends StatefulWidget {
  const MyGuardiansScreen({super.key});

  @override
  State<MyGuardiansScreen> createState() => _MyGuardiansScreenState();
}

class _MyGuardiansScreenState extends State<MyGuardiansScreen>
    with WidgetsBindingObserver {
  List<dynamic> guardians = [];
  bool loading = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGuardians();
    _pollTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _loadGuardians(silent: true);
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
      _loadGuardians(silent: true);
    }
  }

  Future<void> _loadGuardians({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() => loading = true);
    }
    try {
      final data = await FamilyApi.getMyGuardians();
      if (!mounted) return;
      setState(() {
        guardians = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
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

            _loadGuardians(silent: true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFE4343),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            context.tr.addNew,
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
      return Center(
        child: Text(context.tr.noGuardians),
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
          key: ValueKey(g['quanhegiamho_id']),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (_) async {
                  final ok = await showConfirmDialog(
                    context,
                    title: context.tr.confirmDelete,
                    message: context.tr.deleteGuardianConfirm,
                    confirmText: context.tr.delete,
                    cancelText: context.tr.cancel,
                  );
                  if (ok == true) {
                    await FamilyApi.endRelationship(g['quanhegiamho_id']);
                    _loadGuardians(silent: true);
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
            name: g['nguoidung']?['tennd'] ?? context.tr.unknownName,
            date: _formatDate(g['ngaybatdau']),
            avatar: FamilyApi.normalizeAvatar(g['nguoidung']?['avatarurl']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GuardianProfile(
                    quanHeId: g['quanhegiamho_id'],
                  ),
                ),
              );
            },
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
        height: 96, // 👈 nhỏ hơn
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72, // 👈 avatar nhỏ
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        avatar!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Color(0xFF1877F2),
                      size: 30,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${context.tr.joinDate}: $date',
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
