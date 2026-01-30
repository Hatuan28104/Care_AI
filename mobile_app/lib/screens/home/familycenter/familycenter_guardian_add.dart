import 'package:flutter/material.dart';

class AddGuardians extends StatelessWidget {
  const AddGuardians({super.key});

  static const Color blue = Color(0xFF1877F2);
  static const Color textDark = Color.fromARGB(255, 13, 69, 159);
  static const Color bg = Color(0xFFF6F6F6);

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
            _guardianStyleCard(), // giống My Guardians
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
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: '0987123488',
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: const Icon(Icons.search, color: blue),
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
  Widget _guardianStyleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
            // Avatar
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
                  const Text(
                    'Alizabeth Browns',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _actionBtn('Gửi lời mời', blue),
                      const SizedBox(width: 14),
                      _actionBtn('Hủy', Colors.redAccent),
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

  // ================= ACTION BUTTON =================
  Widget _actionBtn(String text, Color color) {
    return Container(
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
    );
  }
}
