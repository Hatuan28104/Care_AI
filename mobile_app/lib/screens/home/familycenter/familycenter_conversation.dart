import 'package:flutter/material.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/api/chat_api.dart';
import 'package:Care_AI/api/family_api.dart';
import 'package:Care_AI/config/api_config.dart';
import 'package:Care_AI/widgets/app_components.dart';

class ConversationScreen extends StatefulWidget {
  final String userId;
  final String quanHeId;

  const ConversationScreen({
    super.key,
    required this.userId,
    required this.quanHeId,
  });

  @override
  State<ConversationScreen> createState() => _ConversationSharingScreenState();
}

class _ConversationSharingScreenState extends State<ConversationScreen> {
  static const Color _blue = Color(0xFF1877F2);

  final List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await ChatApi.getHistory(widget.userId);
      final permissions = await FamilyApi.getPermissionConfigs(widget.quanHeId);

      final permissionMap = {
        for (var p in permissions) p["quyen_id"]: p["dakichhoat"],
      };

      if (!mounted) return;
      setState(() {
        _users.clear();

        for (var item in history) {
          final hoiThoaiId = item["hoithoai_id"];
          final enabled = permissionMap[hoiThoaiId] == 1 ||
              permissionMap[hoiThoaiId] == true;
          _users.add({
            "name": item["tendigitalhuman"] ?? "Conversation",
            "date": item["lancuoituongtac"] ?? "",
            "hoiThoaiId": hoiThoaiId,
            "image": item["imageurl"] ?? "",
            "enabled": enabled,
          });
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.conversationHistory),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            context.tr.shareConversationHistory,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _blue,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(_users.length, (index) => _userCard(index)),
      ],
    );
  }

  Widget _userCard(int index) {
    final user = _users[index];
    final image = user["image"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image.startsWith("http")
                          ? image
                          : "${ApiConfig.baseUrl}${image.startsWith("/") ? image : "/$image"}",
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    color: _blue.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: _blue),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? "",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${context.tr.lastMessage}: ${formatTime(user['date'])}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          AppSwitch(
            value: user['enabled'],
            onChanged: (v) async {
              final oldValue = user['enabled'];

              setState(() {
                _users[index]['enabled'] = v;
              });

              try {
                await FamilyApi.savePermission(
                  quanHeId: widget.quanHeId,
                  quyenId: user["hoiThoaiId"],
                  active: v,
                );
              } catch (e) {
                setState(() {
                  _users[index]['enabled'] = oldValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String formatTime(dynamic isoTime) {
    if (isoTime == null) return "";

    final time = DateTime.parse(isoTime.toString()).toLocal();

    String day = time.day.toString().padLeft(2, '0');
    String month = time.month.toString().padLeft(2, '0');
    String year = time.year.toString();

    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');

    return "$day.$month.$year • $hour:$minute";
  }
}
