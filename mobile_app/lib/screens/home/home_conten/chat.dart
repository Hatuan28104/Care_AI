import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import 'package:Care_AI/models/tr.dart';

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
  final ImagePicker _imagePicker = ImagePicker();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  String? _conversationId;
  String _speechBaseText = '';
  bool _isFocused = false;
  bool _isListening = false;
  bool _speechInitialized = false;

  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

    messages.add({"text": widget.intro, "isUser": false});

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (_isListening) {
      _speechToText.stop();
    }
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

  void _showErrorSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr.errorOccurred),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null || image.path.isEmpty) return;
      if (!mounted) return;

      setState(() {
        messages.add({
          "text": image.path,
          "path": image.path,
          "isUser": true,
          "isImage": true,
        });
      });

      _scrollToBottom();
    } catch (_) {
      _showErrorSnackBar();
    }
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechInitialized) return true;

    try {
      final bool available = await _speechToText.initialize(
        onStatus: (status) {
          if (!mounted) return;

          final bool listening = status == 'listening';
          if (_isListening == listening) return;

          if (listening || status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = listening;
            });
          }
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
          });
        },
        options: [stt.SpeechToText.androidNoBluetooth],
      );

      if (!available) return false;

      _speechInitialized = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  void _updateVoiceText(String recognizedWords) {
    final String voiceText = recognizedWords.trim();
    final String nextText = _speechBaseText.isEmpty
        ? voiceText
        : voiceText.isEmpty
            ? _speechBaseText
            : '$_speechBaseText $voiceText';

    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  Future<void> _stopListening() async {
    try {
      await _speechToText.stop();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _toggleVoiceToText() async {
    if (_isListening) {
      await _stopListening();
      return;
    }

    final bool isReady = await _ensureSpeechReady();
    if (!isReady) {
      _showErrorSnackBar();
      return;
    }

    _speechBaseText = _controller.text.trim();

    try {
      await _speechToText.listen(
        localeId: 'vi_VN',
        onResult: (result) {
          if (!mounted) return;
          _updateVoiceText(result.recognizedWords);
        },
      );

      if (!mounted) return;
      setState(() {
        _isListening = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      _showErrorSnackBar();
    }
  }

  /* ================= SEND MESSAGE ================= */

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (!mounted) return;
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
        hoiThoaiId: _conversationId,
      );

      _conversationId = response["hoi_thoai_id"];

      if (!mounted) return;

      final bool canhBao = response["canh_bao"] == true;
      final int mucDo = int.tryParse((response["muc_do"] ?? 0).toString()) ?? 0;

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);

        messages.add({
          "text": (response["reply"] ?? "").toString(),
          "isUser": false,
        });
      });

      if (canhBao) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Cảnh báo"),
            content: const Text("Phát hiện nội dung nguy hiểm"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else if (mucDo == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(" Nội dung có dấu hiệu tiêu cực"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);
        messages.add({"text": "${context.tr.error}: $e", "isUser": false});
      });
    }

    _scrollToBottom();
  }

  /* ================= MESSAGE UI ================= */

  Widget buildMessage(Map<String, dynamic> msg) {
    final isUser = msg["isUser"] == true;
    final isImage = msg["isImage"] == true;
    final double maxWidth = MediaQuery.of(context).size.width * 0.70;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding: isImage ? const EdgeInsets.all(4) : const EdgeInsets.all(12),
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            decoration: BoxDecoration(
              color: isImage ? Colors.transparent : isUser ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: msg["isTyping"] == true
                ? Text(
                    context.tr.typing,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : isImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File((msg["path"] ?? msg["text"] ?? "").toString()),
                          width: maxWidth,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: maxWidth,
                            height: 180,
                            alignment: Alignment.center,
                            color: Colors.grey[300],
                            child: Text(
                              context.tr.errorOccurred,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
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
              icon: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.blue,
                size: 28,
              ),
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
              onPressed: _openCamera,
            ),
          ],
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.blue,
            ),
            onPressed: _toggleVoiceToText,
          ),
          Expanded(
            flex: _isFocused ? 9 : 6,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: _isFocused ? null : context.tr.enterMessage,
                filled: true,
                fillColor: const Color(0xFFF6F6F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.image),
              onBackgroundImageError: (_, __) {},
              child: widget.image.isEmpty ? const Icon(Icons.person) : null,
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
