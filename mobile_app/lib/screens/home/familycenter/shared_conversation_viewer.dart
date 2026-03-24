import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import 'package:Care_AI/config/api_config.dart';

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
  List<Map<String, dynamic>> messages = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      final res = await ChatApi.getMessages(widget.chatId.trim());

      setState(() {
        messages = List<Map<String, dynamic>>.from(res);
        loading = false;
        error = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  Widget messageBubble(Map msg) {
    final isDigital = msg["ladigital"] == true;
    final content = (msg["noidung"] ?? "").toString();
    final isUser = !isDigital;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1877F2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          content,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF1877F2),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.image.isNotEmpty
                  ? NetworkImage(
                      widget.image.startsWith("http")
                          ? widget.image
                          : "${ApiConfig.baseUrl}${widget.image.startsWith("/") ? widget.image : "/${widget.image}"}",
                    )
                  : null,
              child: widget.image.isEmpty
                  ? const Icon(Icons.smart_toy, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Chưa có nội dung hội thoại"),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: loadMessages,
                            child: const Text("Tải lại"),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: loadMessages,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return messageBubble(messages[index]);
                        },
                      ),
                    ),
    );
  }
}
