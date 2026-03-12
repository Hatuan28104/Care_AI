import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import 'history_detail.dart';
import '../../../models/tr.dart';
import 'package:flutter/scheduler.dart';

class HistoryTab extends StatefulWidget {
  final String userId;

  const HistoryTab({super.key, required this.userId});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  static const Color primary = Color(0xFF1F41BB);
  static const Color bgItem = Color(0xFFF3F3F3);

  List<Map<String, dynamic>> histories = [];
  bool loading = true;
  @override
  void initState() {
    super.initState();

    loadHistory();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadHistory();
    });
  }

  /* ================= LOAD HISTORY ================= */

  Future<void> loadHistory() async {
    try {
      final data = await ChatApi.getHistory(widget.userId);

      setState(() {
        histories = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(),
        Expanded(child: _content()),
      ],
    );
  }

  /* ================= TITLE ================= */

  Widget _title() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Text(
        context.tr.history,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),
    );
  }

  /* ================= CONTENT ================= */

  Widget _content() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (histories.isEmpty) {
      return Center(child: Text(context.tr.noHistory));
    }

    return RefreshIndicator(
      onRefresh: loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: histories.length,
        itemBuilder: (context, index) {
          final item = histories[index];

          final hoiThoaiId = item["HoiThoai_ID"] ?? "";
          final digitalId = item["DigitalHuman_ID"] ?? "";
          final name = item["TenDigitalHuman"] ?? "";
          final job = item["NgheNghiep"] ?? "";
          final image = item["ImageUrl"] ?? "";
          final time = formatTime(item["LanCuoiTuongTac"]);

          if (hoiThoaiId.isEmpty) return const SizedBox();

          return _historyItem(
            hoiThoaiId,
            digitalId,
            name,
            job,
            image,
            time,
          );
        },
      ),
    );
  }

  /* ================= HISTORY ITEM ================= */

  Widget _historyItem(
    String hoiThoaiId,
    String digitalId,
    String name,
    String job,
    String image,
    String time,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              hoiThoaiId: hoiThoaiId,
              digitalId: digitalId,
              userId: widget.userId,
              title: name,
              image: image,
            ),
          ),
        );

        loadHistory();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgItem,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundImage: image.isNotEmpty
                  ? NetworkImage("http://10.0.2.2:3000/$image")
                  : null,
              child: image.isEmpty ? const Icon(Icons.person, size: 20) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$job • $time",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            /// MENU
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showActionSheet(name, hoiThoaiId);
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ================= ACTION SHEET ================= */

  void showActionSheet(String name, String hoiThoaiId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr.chooseAction,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// RENAME
              actionItem(
                icon: Icons.edit,
                text: context.tr.rename,
                onTap: () {
                  Navigator.pop(context);
                  showRenameDialog(name, hoiThoaiId);
                },
              ),

              const SizedBox(height: 12),

              /// DELETE
              actionItem(
                icon: Icons.delete_outline,
                text: context.tr.delete,
                color: Colors.red,
                onTap: () async {
                  Navigator.pop(context);

                  final ok = await ChatApi.deleteConversation(hoiThoaiId);

                  if (ok) {
                    loadHistory();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /* ================= RENAME DIALOG ================= */

  void showRenameDialog(String oldName, String hoiThoaiId) {
    final controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(context.tr.rename),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: context.tr.enterNewName,
            ),
          ),
          actions: [
            TextButton(
              child: Text(context.tr.cancel),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(context.tr.save),
              onPressed: () async {
                final newName = controller.text.trim();

                Navigator.pop(context);

                final ok = await ChatApi.renameConversation(
                  hoiThoaiId,
                  newName,
                );

                if (ok) {
                  loadHistory();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /* ================= ACTION ITEM ================= */

  Widget actionItem({
    required IconData icon,
    required String text,
    Color color = Colors.black,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ================= FORMAT TIME ================= */

  String formatTime(dynamic isoTime) {
    if (isoTime == null) return "";

    final time = DateTime.parse(isoTime.toString());

    String day = time.day.toString().padLeft(2, '0');
    String month = time.month.toString().padLeft(2, '0');
    String year = time.year.toString();

    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');

    return "$day.$month.$year • $hour:$minute";
  }
}
