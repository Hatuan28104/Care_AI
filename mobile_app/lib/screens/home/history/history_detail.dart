import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const Color _blue = Color(0xFF1877F2);
  static const Color _bg = Color(0xFFF6F6F6);

  final FocusNode _inputFocus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(() {
      setState(() {
        _isFocused = _inputFocus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _chatHeader(),
            Expanded(child: _chatBody()),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  // ================= CHAT HEADER =================
  Widget _chatHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 12, 18, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: _blue.withOpacity(.1),
            child: const Icon(Icons.person, color: _blue),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                widget.subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CHAT BODY =================
  Widget _chatBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Hôm nay tôi buồn',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Bạn có thể chia sẻ thêm cho tôi được không?',
                style: TextStyle(height: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= INPUT BAR =================
  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          // ===== BACK / EXIT ICON (chỉ hiện khi focus) =====
          if (_isFocused)
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right,
                  color: _blue, size: 30),
              onPressed: () {
                FocusScope.of(context).unfocus(); // 👈 TẮT KEYBOARD
                setState(() {
                  _isFocused = false; // 👈 TRỞ VỀ BAN ĐẦU
                });
              },
            ),

          // ===== LEFT ICONS (ẩn khi focus) =====
          if (!_isFocused) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: _blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: _blue),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, color: _blue),
              onPressed: () {},
            ),
          ],

          // ===== TEXT FIELD =====
          Expanded(
            flex: _isFocused ? 10 : 6,
            child: TextField(
              focusNode: _inputFocus,
              decoration: InputDecoration(
                hintText: _isFocused ? null : 'Hỏi bất cứ điều gì...',
                filled: true,
                fillColor: _bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ===== SEND =====
          IconButton(
            icon: const Icon(Icons.send_rounded, color: _blue),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
