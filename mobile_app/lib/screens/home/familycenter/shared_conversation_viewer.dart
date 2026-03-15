import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';

class SharedConversationViewer extends StatefulWidget {
  final String chatId;
  final String title;
  final String image;

  const SharedConversationViewer({
    super.key,
    required this.chatId,
    required this.title,
    required this.image,
  });

  @override
  State<SharedConversationViewer> createState() =>
      _SharedConversationViewerState();
}

class _SharedConversationViewerState extends State<SharedConversationViewer> {
  List messages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      final res = await ChatApi.getMessages(widget.chatId);

      print("CHAT ID: ${widget.chatId}");
      print("API RESULT: $res");

      setState(() {
        messages = List<Map<String, dynamic>>.from(res);
        loading = false;
      });
    } catch (e) {
      print("LOAD ERROR: $e");

      setState(() {
        loading = false;
      });
    }
  }

  Widget messageBubble(Map msg) {
    bool isUser = msg["LaDigital"] == 0 || msg["LaDigital"] == false;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1F41BB) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg["NoiDung"] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.image.isNotEmpty
                  ? NetworkImage("http://10.0.2.2:3000/${widget.image}")
                  : null,
              child: widget.image.isEmpty ? const Icon(Icons.smart_toy) : null,
            ),
            const SizedBox(width: 10),
            Text(widget.title),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return messageBubble(messages[index]);
              },
            ),
    );
  }
}
