import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'premium.dart';
import 'package:Care_AI/screens/settings/settings.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String role;
  final String image;
  final String intro;

  const ChatScreen({
    super.key,
    required this.name,
    required this.role,
    required this.image,
    required this.intro,
  });

  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF5F6FA);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Msg> _messages = [];

  final ValueNotifier<bool> _hasText = ValueNotifier(false);

  final ImagePicker _picker = ImagePicker();

  bool _isRecording = false;

  String get displayName => widget.name.split(' - ').first;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _hasText.value = _controller.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hasText.dispose();
    super.dispose();
  }

  // ===== SEND TEXT =====
  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Msg(text, true));
    });

    _controller.clear();
  }

  // ===== + MENU =====
  void _openAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===== CAMERA / GALLERY =====
  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        _messages.add(_Msg("📷 Image selected", true));
      });
    }
  }

  // ===== MIC =====
  void _toggleMic() {
    setState(() => _isRecording = !_isRecording);

    if (!_isRecording) {
      _messages.add(_Msg("🎤 Voice message", true));
    }
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatScreen._bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  _heroSection(context),
                  _introBubble(),
                  ..._messages.map(_chatBubble),
                ],
              ),
            ),
            _inputBar(),
          ],
        ),
      ),
    );
  }

  // ===== CHAT BUBBLE =====
  Widget _chatBubble(_Msg m) {
    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: m.isUser ? ChatScreen._blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          m.text,
          style: TextStyle(
            color: m.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
      child: Row(
        children: [
          const Text(
            'Care AI',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 31, 65, 187),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => const PremiumScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
            child: const Icon(Icons.settings_outlined, size: 25),
          ),
        ],
      ),
    );
  }

  // ===== HERO =====
  Widget _heroSection(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          widget.image,
          width: 428,
          height: 320,
          fit: BoxFit.cover,
          alignment: const FractionalOffset(0.5, 0.18),
        ),
        Positioned(
          top: 6,
          left: -10,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/Luna_avatar.png'),
              ),
              const SizedBox(width: 10),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 4, 4, 4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== INTRO =====
  Widget _introBubble() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: const Color.fromARGB(173, 232, 232, 232),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            "Hi, I'm Care AI 💙\nNice to meet you today. Would you like to share how you've been feeling lately?",
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  // ===== MINI ICON =====
  Widget _miniActionIcon(IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 36,
      child: IconButton(
        icon: Icon(icon),
        iconSize: 26,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: ChatScreen._blue,
        onPressed: onTap,
      ),
    );
  }

  // ===== INPUT BAR =====
  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          _miniActionIcon(Icons.add, _openAttachmentMenu),
          _miniActionIcon(Icons.camera_alt, _pickImage),
          _miniActionIcon(_isRecording ? Icons.stop : Icons.mic, _toggleMic),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: ChatScreen._bg,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: "Ask anything...",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _hasText,
                    builder: (_, hasText, __) {
                      return IconButton(
                        icon: Icon(
                          hasText ? Icons.send : Icons.emoji_emotions_outlined,
                          color: ChatScreen._blue,
                        ),
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: _hasText.value ? _send : () {},
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  _Msg(this.text, this.isUser);
}
