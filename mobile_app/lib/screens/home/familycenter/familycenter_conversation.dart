import 'package:flutter/material.dart';
import '../../../models/tr.dart';
import '../../../api/chat_api.dart';
import '../../../api/family_api.dart';

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
  static const Color _bg = Color(0xFFF6F6F6);

  final List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await ChatApi.getHistory(widget.userId);
    final permissions = await FamilyApi.getPermissionConfigs(widget.quanHeId);

    final permissionMap = {
      for (var p in permissions) p["Quyen_ID"]: p["DaKichHoat"]
    };

    setState(() {
      _users.clear();

      for (var item in history) {
        final hoiThoaiId = item["HoiThoai_ID"];

        bool enabled =
            permissionMap[hoiThoaiId] == 1 || permissionMap[hoiThoaiId] == true;
        _users.add({
          "name": item["TenDigitalHuman"] ?? "Conversation",
          "date": item["LanCuoiTuongTac"] ?? "",
          "hoiThoaiId": hoiThoaiId,
          "image": item["ImageUrl"] ?? "",
          "enabled": enabled,
        });
      }

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _titleBar(context),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _titleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.tr.configureSharingPermissions,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
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
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _blue,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(
          _users.length,
          (index) => _userCard(index),
        ),
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
        borderRadius: BorderRadius.circular(18),
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
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "http://10.0.2.2:3000/$image",
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    color: _blue.withOpacity(.1),
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: user['enabled'],
            onChanged: (v) async {
              final oldValue = user['enabled'];

              setState(() {
                _users[index]['enabled'] = v;
              });

              print("CALL API -> hoiThoaiId: ${user["hoiThoaiId"]} active: $v");

              try {
                await FamilyApi.savePermission(
                  quanHeId: widget.quanHeId,
                  quyenId: user["hoiThoaiId"],
                  active: v,
                );

                print("SAVE SUCCESS");
              } catch (e) {
                print("SAVE ERROR: $e");

                setState(() {
                  _users[index]['enabled'] = oldValue;
                });
              }
            },
            activeTrackColor: const Color.fromARGB(255, 19, 114, 255),
            inactiveTrackColor: const Color.fromARGB(255, 218, 217, 217),
            inactiveThumbColor: Colors.white,
          )
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
