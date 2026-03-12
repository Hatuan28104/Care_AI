import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import '../../../models/tr.dart';

class ChatDetailScreen extends StatefulWidget {
  final String hoiThoaiId;
  final String digitalId;
  final String userId;
  final String title;
  final String image;

  const ChatDetailScreen({
    super.key,
    required this.hoiThoaiId,
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
  final FocusNode focusNode = FocusNode();

  static const Color blue = Color(0xFF1877F2);
  static const Color aiBubble = Color(0xFFF1F1F1);

  bool loading = true;
  bool isFocused = false;

  String? conversationId;

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

    conversationId = widget.hoiThoaiId;
    loadMessages();

    focusNode.addListener(() {
      setState(() {
        isFocused = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  /* ================= LOAD MESSAGES ================= */

  Future<void> loadMessages() async {
    try {
      final data = await ChatApi.getMessages(widget.hoiThoaiId);

      final list = data.map<Map<String, dynamic>>((msg) {
        int laDigital = msg["LaDigital"] is int
            ? msg["LaDigital"]
            : (msg["LaDigital"] == true ? 1 : 0);

        return {
          "text": msg["NoiDung"] ?? "",
          "isUser": laDigital == 0,
        };
      }).toList();

      setState(() {
        messages = list;
        loading = false;
      });

      scrollToBottom();
    } catch (e) {
      setState(() {
        loading = false;
      });
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

  /* ================= SEND MESSAGE ================= */

  Future<void> sendMessage() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
      messages.add({"isUser": false, "isTyping": true});
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
          "text": response["reply"] ?? context.tr.aiNotUnderstand,
          "isUser": false,
        });
      });
    } catch (e) {
      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({
          "text": context.tr.serverError,
          "isUser": false,
        });
      });
    }

    Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
  }

  /* ================= MESSAGE UI ================= */

  Widget messageBubble(Map<String, dynamic> msg) {
    final isUser = msg["isUser"] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage:
                  NetworkImage("http://10.0.2.2:3000/${widget.image}"),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? blue : aiBubble,
                borderRadius: BorderRadius.circular(18),
              ),
              child: msg["isTyping"] == true
                  ? Text(
                      context.tr.typing,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  /* ================= HEADER ================= */

  Widget header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 12, 18, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          CircleAvatar(
            radius: 20,
            backgroundImage:
                NetworkImage("http://10.0.2.2:3000/${widget.image}"),
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  /* ================= INPUT BAR ================= */

  Widget inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          if (isFocused)
            IconButton(
              icon:
                  const Icon(Icons.keyboard_arrow_right, color: blue, size: 28),
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
            ),
          if (!isFocused) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: blue),
              onPressed: () {
                FocusScope.of(context).requestFocus(focusNode);
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: blue),
              onPressed: () {
                FocusScope.of(context).requestFocus(focusNode);
              },
            ),
            IconButton(
              icon: const Icon(Icons.mic_none, color: blue),
              onPressed: () {
                FocusScope.of(context).requestFocus(focusNode);
              },
            ),
          ],
          Expanded(
            flex: isFocused ? 10 : 6,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: isFocused ? null : context.tr.enterMessage,
                filled: true,
                fillColor: const Color(0xFFF3F3F3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            backgroundColor: blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
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
      body: SafeArea(
        child: Column(
          children: [
            header(),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return messageBubble(messages[index]);
                      },
                    ),
            ),
            inputBar(),
          ],
        ),
      ),
    );
  }
}
