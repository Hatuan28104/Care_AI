import 'package:flutter/material.dart';
import 'package:Care_AI/api/chat_api.dart';
import 'history_detail.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/common_confirm_dialog.dart';
import 'package:Care_AI/config/api_config.dart';

class HistoryTab extends StatefulWidget {
  final String userId;

  const HistoryTab({super.key, required this.userId});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  static const Color bgItem = Color.fromARGB(255, 255, 255, 255);

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _title(),
        Expanded(
          child: RefreshIndicator(onRefresh: loadHistory, child: _content()),
        ),
      ],
    );
  }

  /* ================= TITLE ================= */

  Widget _title() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        child: Text(
          context.tr.conversationHistory,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ));
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

        final hoiThoaiId = (item["hoithoai_id"] ?? "").toString();
        final digitalId = (item["digitalhuman_id"] ?? "").toString();
        final name = (item["tendigitalhuman"] ?? "").toString();
        final job = (item["tennghenghiep"] ?? "").toString();
        final image = normalizeImage(item["imageurl"]?.toString());
        final time = formatTime(item["lancuoituongtac"]);

        return _historyItem(hoiThoaiId, digitalId, name, job, image, time);
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
    const radius = 10.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Slidable(
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
                    try {
                      await ChatApi.deleteConversation(hoiThoaiId);
                      loadHistory();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.delete, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bgItem,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        image.isNotEmpty ? NetworkImage(image) : null,
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
                          "$job  $time",
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

    final cleanPath = img.startsWith("/") ? img : "/$img";
    return "${ApiConfig.baseUrl}$cleanPath";
  }
}
