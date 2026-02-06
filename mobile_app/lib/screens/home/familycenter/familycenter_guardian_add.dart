import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'dart:async';

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
            _subHeader(context),
            _description(),
            _phoneInput(),
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_foundUsers.isNotEmpty)
              ..._foundUsers.map((u) => _guardianStyleCard(u)).toList(),
          ],
        ),
      ),
    );
  }

  // ================= SUB HEADER =================
  Widget _subHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 2),
          const Text(
            'Thêm mới',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= DESCRIPTION =================
  Widget _description() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Text(
        'Nhập số điện thoại của người giám hộ của bạn',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: blue,
        ),
      ),
    );
  }

  // ================= PHONE INPUT =================
  Widget _phoneInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        onChanged: _onPhoneChanged,
        decoration: InputDecoration(
          hintText: 'Nhập số điện thoại',
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

  // ================= CARD (GIỐNG MY GUARDIANS) =================
  Widget _guardianStyleCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Container(
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user['TenND'] ?? 'Không tên',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _actionBtn('Gửi lời mời', blue, () {
                        _sendInvite(user['SoDienThoai']);
                      }),
                      const SizedBox(width: 14),
                      _actionBtn('Hủy', Colors.redAccent, () {
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
      ),
    );
  }

  Future<void> _sendInvite(String phone) async {
    if (phone.isEmpty) {
      _showMsg('Số điện thoại không hợp lệ');
      return;
    }

    try {
      await FamilyApi.sendInviteByPhone(phone);
      _showMsg('Đã gửi lời mời');
    } catch (e) {
      _showMsg(e.toString());
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _searchUser() async {
    final phone = _phoneCtrl.text.trim();

    if (phone.isEmpty) {
      _showMsg('Vui lòng nhập số điện thoại');
      return;
    }

    setState(() {
      _loading = true;
      _foundUsers = [];
      _error = null;
    });

    try {
      final users = await FamilyApi.findUserByPhone(phone);

      setState(() {
        _foundUsers = users;
        _error = users.isEmpty ? 'Không tìm thấy người dùng' : null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onPhoneChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (value.trim().length < 2) {
        setState(() {
          _foundUsers = [];
          _error = null;
        });
        return;
      }

      _searchUser();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _phoneCtrl.dispose();
    super.dispose();
  }
}
