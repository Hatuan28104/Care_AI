import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'dart:async';
import '../../../models/tr.dart';
import 'package:Care_AI/widgets/app_header.dart';

class AddGuardians extends StatefulWidget {
  const AddGuardians({super.key});

  @override
  State<AddGuardians> createState() => _AddGuardiansState();
}

class _AddGuardiansState extends State<AddGuardians> {
  static const Color blue = Color(0xFF1877F2);
  static const Color bg = Color(0xFFF6F6F6);

  final TextEditingController _phoneCtrl = TextEditingController();
  bool _loading = false;
  List<dynamic> _foundUsers = [];
  String? _error;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: context.tr.addNew,
            ),
            _description(),
            _phoneInput(),
            const SizedBox(height: 18),
            Expanded(
              child: _buildResultArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_foundUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _foundUsers.length,
      itemBuilder: (context, index) {
        return _guardianStyleCard(_foundUsers[index]);
      },
    );
  }

  Widget _description() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Text(
        context.tr.enterGuardianPhone,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: blue,
        ),
      ),
    );
  }

  Widget _phoneInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        onChanged: _onPhoneChanged,
        decoration: InputDecoration(
          hintText: context.tr.enterPhoneNumber,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: blue, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ================= CARD =================
  Widget _guardianStyleCard(Map<String, dynamic> user) {
    print('DEBUG USER = $user');
    final avatar = FamilyApi.normalizeAvatar(user['AvatarUrl']);
    final status = user['inviteStatus'];

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: avatar == null ? Colors.grey.shade300 : null,
              image: avatar != null && avatar.toString().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(avatar),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: avatar == null
                ? const Icon(Icons.person, size: 28, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user['TenND'] ?? context.tr.unknownName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (status == 'none') ...[
                      _actionBtn(context.tr.sendInvite, blue, () {
                        _sendInvite(user['SoDienThoai']);
                      }),
                      const SizedBox(width: 12),
                      _actionBtn(context.tr.cancel, Colors.red, () {
                        Navigator.pop(context);
                      }),
                    ],
                    if (status == 'pending')
                      _actionBtn(context.tr.cancelRequest,
                          const Color.fromARGB(174, 158, 158, 158), () {
                        _cancelInvite(user['LoiMoi_ID']);
                      }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ================= SEND INVITE =================
  Future<void> _sendInvite(String phone) async {
    try {
      await FamilyApi.sendInviteByPhone(phone);
      _showSuccessDialog();
      _searchUser();
    } catch (_) {}
  }

  Future<void> _cancelInvite(String loiMoiId) async {
    try {
      await FamilyApi.cancelInvite(loiMoiId);
      _searchUser(); // reload danh sách
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// ================= SUCCESS POPUP =================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.of(ctx).canPop()) {
            Navigator.of(ctx).pop();
          }
        });

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr.inviteSentSuccess,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= SEARCH =================
  Future<void> _searchUser() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _loading = true;
      _foundUsers = [];
      _error = null;
    });

    try {
      final users = await FamilyApi.findUserByPhone(phone);
      setState(() {
        _foundUsers = users;
        _error = users.isEmpty ? context.tr.userNotFound : null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onPhoneChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _searchUser);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phoneCtrl.dispose();
    super.dispose();
  }
}
