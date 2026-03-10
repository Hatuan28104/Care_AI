import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import '../../../models/tr.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String image;
  final String intro;
  final String digitalId;
  final String userId;

  const ChatScreen({
    super.key,
    required this.name,
    required this.image,
    required this.intro,
    required this.digitalId,
    required this.userId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;

  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

    messages.add({
      "text": widget.intro,
      "isUser": false,
    });

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /* ================= SEND MESSAGE ================= */

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
      messages.add({"isUser": false, "isTyping": true});
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await ChatApi.sendMessage(
        message: text,
        userId: widget.userId,
        digitalId: widget.digitalId,
      );

      if (!mounted) return;

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({
          "text": response["success"] == true
              ? response["reply"]
              : "${context.tr.error}: ${response["message"]}",
          "isUser": false,
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({
          "text": context.tr.serverError,
          "isUser": false,
        });
      });
    }

    _scrollToBottom();
  }

  /* ================= MESSAGE UI ================= */

  Widget buildMessage(Map<String, dynamic> msg) {
    final isUser = msg["isUser"] == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(widget.image),
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.70,
            ),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: msg["isTyping"] == true
                ? Text(
                    context.tr.typing,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  )
                : Text(
                    msg["text"] ?? "",
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /* ================= INPUT BAR ================= */

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          if (_isFocused)
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right,
                  color: Colors.blue, size: 28),
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
            ),

          if (!_isFocused) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () {
                FocusScope.of(context).requestFocus(_focusNode);
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              onPressed: () {
                FocusScope.of(context).requestFocus(_focusNode);
              },
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, color: Colors.blue),
              onPressed: () {
                FocusScope.of(context).requestFocus(_focusNode);
              },
            ),
          ],

          Expanded(
            flex: _isFocused ? 10 : 6,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: _isFocused ? null : context.tr.enterMessage,
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),

          const SizedBox(width: 6),

          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(widget.image),
            ),
            const SizedBox(width: 10),
            Text(
              widget.name,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }
}