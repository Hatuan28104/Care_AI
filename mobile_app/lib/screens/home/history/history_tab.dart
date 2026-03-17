import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import 'history_detail.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/common_confirm_dialog.dart';

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
  }

  /* ================= LOAD HISTORY ================= */

  Future<void> loadHistory() async {
    try {
      final data = await ChatApi.getHistory(widget.userId);

      if (!mounted) return;

      setState(() {
        histories = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

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
        Expanded(
          child: RefreshIndicator(
            onRefresh: loadHistory,
            child: _content(),
          ),
        ),
      ],
    );
  }

  /* ================= TITLE ================= */

  Widget _title() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Text(
        context.tr.history,
        style: const TextStyle(
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 250),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (histories.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 250),
          Center(child: Text(context.tr.noHistory)),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final item = histories[index];

        final hoiThoaiId = item["HoiThoai_ID"] ?? "";
        final digitalId = item["DigitalHuman_ID"] ?? "";
        final name = item["TenDigitalHuman"] ?? "";
        final job = item["NgheNghiep"] ?? "";
        final image = normalizeImage(item["ImageUrl"]);
        final time = formatTime(item["LanCuoiTuongTac"]);

        return _historyItem(
          hoiThoaiId,
          digitalId,
          name,
          job,
          image,
          time,
        );
      },
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
    return Slidable(
      key: ValueKey(hoiThoaiId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) async {
              final ok = await showConfirmDialog(
                context,
                title: context.tr.deleteConversation,
                message: context.tr.confirmDeleteConversation,
                confirmText: context.tr.delete,
                cancelText: context.tr.cancel,
              );
              if (ok == true) {
                await ChatApi.deleteConversation(hoiThoaiId);
                loadHistory();
              }
            },
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
        ],
      ),
      child: InkWell(
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
                backgroundColor: Colors.grey[200],
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                child: image.isEmpty ? const Icon(Icons.smart_toy) : null,
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
            ],
          ),
        ),
      ),
    );
  }

  /* ================= FORMAT TIME ================= */

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

  /* ================= FIX IMAGE URL ================= */

  String normalizeImage(String? img) {
    if (img == null || img.isEmpty) return "";

    if (img.startsWith("http")) return img;

    return "http://10.0.2.2:3000/$img";
  }
}
