import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationSharingScreenState();
}

class _ConversationSharingScreenState extends State<ConversationScreen> {
  // ===== CONSTANTS =====
  static const Color _blue = Color(0xFF1877F2);
  static const Color _bg = Color(0xFFF6F6F6);

  // ===== MOCK DATA =====
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Alex - Bác sĩ',
      'last': 'Tin nhắn gần nhất: September 27, 2025',
      'enabled': false,
    },
    {
      'name': 'Anna - Luật sư',
      'last': 'Tin nhắn gần nhất: September 26, 2025',
      'enabled': false,
    },
    {
      'name': 'Luna - Y tá',
      'last': 'Tin nhắn gần nhất: September 23, 2025',
      'enabled': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _titleBar(context),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  // ================= TITLE BAR =================
  Widget _titleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Thiết lập quyền chia sẻ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ================= CONTENT =================
  Widget _content() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        const Center(
          child: Text(
            'Chia sẻ lịch sử trò chuyện',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: _blue,
            ),
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(
          _users.length,
          (index) => _userCard(index),
        ),
        const SizedBox(height: 28),
        _saveButton(),
      ],
    );
  }

  // ================= USER CARD =================
  Widget _userCard(int index) {
    final user = _users[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _blue.withOpacity(.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: _blue),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['last'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Switch
          Switch(
            value: user['enabled'],
            onChanged: (v) {
              setState(() {
                _users[index]['enabled'] = v;
              });
            },
            activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
            inactiveTrackColor: const Color.fromARGB(255, 218, 217, 217),
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  // ================= SAVE BUTTON =================
  Widget _saveButton() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            // TODO: handle save
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: const Text(
            'Lưu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
