import 'package:flutter/material.dart';
import 'package:demo_app/api/chat_api.dart';
import 'package:demo_app/models/tr.dart';

class ChatDetailScreen extends StatefulWidget {
  final String? hoiThoaiId;
  final String digitalId;
  final String userId;
  final String title;
  final String image;

  const ChatDetailScreen({
    super.key,
    this.hoiThoaiId,
    required this.digitalId,
    required this.userId,
    required this.title,
    required this.image,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isFocused = false;
  bool _sending = false;
  bool loading = true;

  String? conversationId;

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

    conversationId = widget.hoiThoaiId;

    if (conversationId != null && conversationId!.isNotEmpty) {
      loadMessages();
    } else {
      loading = false;
    }

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /* ================= LOAD ================= */

  Future<void> loadMessages() async {
    try {
      final data = await ChatApi.getMessages(conversationId!.trim());

      final list = data.map<Map<String, dynamic>>((msg) {
        final laDigital = msg["ladigital"] == true;

        return {
          "text": (msg["noidung"] ?? "").toString(),
          "isUser": !laDigital,
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        messages = list;
        loading = false;
      });

      scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /* ================= SCROLL ================= */

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /* ================= SEND ================= */

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty || _sending) return;

    _sending = true;

    setState(() {
      messages.add({"text": text, "isUser": true});
      messages.add({"isTyping": true});
    });

    controller.clear();
    scrollToBottom();

    try {
      final response = await ChatApi.sendMessage(
        message: text,
        userId: widget.userId,
        digitalId: widget.digitalId,
        hoiThoaiId: conversationId,
      );

      if ((response["hoi_thoai_id"] ?? "").toString().isNotEmpty) {
        conversationId = response["hoi_thoai_id"].toString();
      }

      if (!mounted) return;

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({
          "text": (response["reply"] ?? context.tr.serverError).toString(),
          "isUser": false,
        });
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({
          "text": "${context.tr.error}: $e",
          "isUser": false,
        });
      });
    }

    _sending = false;

    Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
  }

  /* ================= MESSAGE ================= */

  Widget messageBubble(Map<String, dynamic> msg) {
    final isUser = msg["isUser"] == true;

    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: CircleAvatar(
              radius: 18,
              backgroundImage:
                  widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
              child: widget.image.isEmpty ? const Icon(Icons.smart_toy) : null,
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(18),
            ),
            child: msg["isTyping"] == true
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text("Typing..."),
                    ],
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

  /* ================= INPUT ================= */

  Widget inputBar() {
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
              onPressed: () => FocusScope.of(context).unfocus(),
            ),
          if (!_isFocused) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () => _focusNode.requestFocus(),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              onPressed: () => _focusNode.requestFocus(),
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, color: Colors.blue),
              onPressed: () => _focusNode.requestFocus(),
            ),
          ],
          Expanded(
            flex: _isFocused ? 10 : 6,
            child: TextField(
              controller: controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: _isFocused ? null : context.tr.enterMessage,
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      backgroundColor: Color(0xFFF6F6F6),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage:
                  widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
              child: widget.image.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 10),
            Text(widget.title),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (_, i) => messageBubble(messages[i]),
                  ),
          ),
          inputBar(),
        ],
      ),
    );
  }
}
