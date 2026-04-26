import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import 'package:Care_AI/models/tr.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  final ImagePicker _imagePicker = ImagePicker();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isListening = false;
  bool _speechInitialized = false;
  String _speechBaseText = '';
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
    if (_isListening) {
      _speechToText.stop();
    }
    controller.dispose();
    scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /* ================= LOAD ================= */
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
          "text": "",
          "path": image.path,
          "isUser": true,
          "isImage": true,
        });
        messages.add({"isTyping": true});
      });

      scrollToBottom();

      final mediaUrl = await ChatApi.uploadChatImage(image.path);

      final response = await ChatApi.sendMessage(
        message: "",
        userId: widget.userId,
        digitalId: widget.digitalId,
        hoiThoaiId: conversationId,
        loaiTinNhan: "image",
        mediaUrl: mediaUrl,
      );

      if ((response["hoi_thoai_id"] ?? "").toString().isNotEmpty) {
        conversationId = response["hoi_thoai_id"];
      }

      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);
        messages.last["media_url"] = mediaUrl;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.removeWhere((m) => m["isTyping"] == true);
      });
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

          if (status == 'listening' ||
              status == 'done' ||
              status == 'notListening') {
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

    controller.value = TextEditingValue(
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

    _speechBaseText = controller.text.trim();

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

  Future<void> loadMessages() async {
    try {
      final data = await ChatApi.getMessages(conversationId!.trim());

      final list = data.map<Map<String, dynamic>>((msg) {
        final laDigital = msg["ladigital"] == true;

        final loaiTinNhan = (msg["loai_tin_nhan"] ?? "text").toString();
        final mediaUrl =
            msg["media_url"] == null ? null : msg["media_url"].toString();

        return {
          "text": (msg["noidung"] ?? "").toString(),
          "isUser": !laDigital,
          "isImage": loaiTinNhan == "image",
          "loai_tin_nhan": loaiTinNhan,
          "media_url": mediaUrl,
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
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

        messages.add({"text": "${context.tr.error}: $e", "isUser": false});
      });
    }

    _sending = false;

    Future.delayed(const Duration(milliseconds: 100), scrollToBottom);
  }

  /* ================= MESSAGE ================= */

  Widget messageBubble(Map<String, dynamic> msg) {
    final isUser = msg["isUser"] == true;
    final isImage = msg["isImage"] == true || msg["loai_tin_nhan"] == "image";
    final double maxWidth = MediaQuery.of(context).size.width * 0.7;
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            padding:
                isImage ? const EdgeInsets.all(4) : const EdgeInsets.all(12),
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: isImage
                  ? Colors.transparent
                  : isUser
                      ? Colors.blue
                      : Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
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
                      Text("..."),
                    ],
                  )
                : isImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Builder(
                          builder: (_) {
                            final path = (msg["path"] ?? "").toString();
                            final mediaUrl =
                                (msg["media_url"] ?? "").toString();

                            if (mediaUrl.isNotEmpty) {
                              return Image.network(
                                mediaUrl,
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
                              );
                            }

                            return Image.file(
                              File(path),
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
                            );
                          },
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
              icon: const Icon(
                Icons.keyboard_arrow_right,
                color: Colors.blue,
                size: 28,
              ),
              onPressed: () => FocusScope.of(context).unfocus(),
            ),
          if (!_isFocused) ...[
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
              onPressed: () => _focusNode.requestFocus(),
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.blue),
              onPressed: _openCamera,
            ),
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : Colors.blue,
              ),
              onPressed: _toggleVoiceToText,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
