import 'package:flutter/material.dart';
import 'history_detail.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  // ===== COLORS =====
  static const Color primary = Color(0xFF1F41BB);
  static const Color bgItem = Color(0xFFF6F6F6);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(),
        Expanded(child: _content(context)),
      ],
    );
  }

  // ===== TITLE =====
  Widget _title() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Text(
        'Lịch sử',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
    );
  }

  // ===== CONTENT =====
  Widget _content(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      children: [
        _sectionTitle('Hôm nay'),
        _historyItem(
          context,
          title: 'Nora - Tin tức',
          time: '20.10.2025   12:58',
        ),
        const SizedBox(height: 16),
        _sectionTitle('7 ngày trước'),
        _historyItem(
          context,
          title: 'Mira - Câu chuyện',
          time: '11.10.2025   12:58',
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  // ===== SECTION TITLE =====
  static Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ===== HISTORY ITEM =====
  static Widget _historyItem(
    BuildContext context, {
    required String title,
    required String time,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              title: title,
              subtitle: time,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgItem,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showActions(context),
              child: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== BOTTOM SHEET =====
  static void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== HANDLE =====
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ===== VIEW DETAILS =====
              _actionItem(
                icon: Icons.visibility_outlined,
                text: 'Xem',
                color: Colors.black,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),

              // ===== DELETE =====
              _actionItem(
                icon: Icons.delete_outline,
                text: 'Xóa',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== ACTION ITEM =====
  static Widget _actionItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgItem,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
