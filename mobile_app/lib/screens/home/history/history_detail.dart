import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import '../../../models/tr.dart';

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
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  /* ================= LOAD MESSAGES ================= */

  Future<void> loadMessages() async {
    final data = await ChatApi.getMessages(conversationId!);

    final list = data.map<Map<String, dynamic>>((msg) {
      bool laDigital = msg["LaDigital"] == true || msg["LaDigital"] == 1;

      return {
        "text": msg["NoiDung"] ?? "",
        "isUser": !laDigital,
      };
    }).toList();

    setState(() {
      messages = list;
      loading = false;
    });

    scrollToBottom();
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

  /* ================= SEND MESSAGE ================= */

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

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

      if (response["hoiThoaiId"] != null) {
        conversationId = response["hoiThoaiId"];
      }

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({
          "text": response["reply"] ?? context.tr.serverError,
          "isUser": false
        });
      });
    } catch (e) {
      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({"text": context.tr.serverError, "isUser": false});
      });
    }

    Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
  }

  /* ================= MESSAGE UI ================= */

  Widget messageBubble(Map<String, dynamic> msg) {
    final isUser = msg["isUser"] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CircleAvatar(
                radius: 16,
                backgroundImage:
                    widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
                child:
                    widget.image.isEmpty ? const Icon(Icons.smart_toy) : null,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF1F41BB) : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: msg["isTyping"] == true
                  ? Text(
                      context.tr.typing,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : Text(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /* ================= INPUT ================= */

  Widget inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: context.tr.enterMessage,
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
            backgroundColor: const Color(0xFF1F41BB),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          )
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
                    itemBuilder: (context, index) {
                      return messageBubble(messages[index]);
                    },
                  ),
          ),
          inputBar(),
        ],
      ),
    );
  }
}
