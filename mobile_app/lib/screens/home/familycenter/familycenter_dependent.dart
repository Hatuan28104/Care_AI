import 'package:flutter/material.dart';
import 'familycenter_dependent_proflie.dart';

class MyDependentsScreen extends StatelessWidget {
  const MyDependentsScreen({super.key});

  static const Color _blue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      children: [
        _inviteCard(context),
        const SizedBox(height: 14),
        _joinedCard(context),
      ],
    );
  }

  // ================= INVITE CARD =================
  Widget _inviteCard(BuildContext context) {
    return Container(
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
                  const Text(
                    'LiLy Lary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _actionBtn('Chấp nhận', _blue),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _showDeclineDialog(context),
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

  void _showDeclineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Từ chối lời mời',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bạn có chắc chắn muốn từ chối lời mời này không?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Từ chối'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= JOINED CARD =================
  Widget _joinedCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const DependentProfileScreen(),
          ),
        );
      },
      child: Container(
        height: 123,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _avatar(),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Edsel Vanily',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Ngày tham gia: 23/09/2025',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
