import 'package:flutter/material.dart';
import 'package:Care_AI/api/family_api.dart';
import 'package:Care_AI/config/api_config.dart';
import 'report_detail_screen.dart';
import 'package:Care_AI/models/tr.dart';
import 'shared_conversation_viewer.dart';

class DependentProfileScreen extends StatefulWidget {
  final String quanHeId;

  const DependentProfileScreen({super.key, required this.quanHeId});

  @override
  State<DependentProfileScreen> createState() => _DependentProfileScreenState();
}

class _DependentProfileScreenState extends State<DependentProfileScreen> {
  static const Color blue = Color(0xFF1877F2);

  Map<String, dynamic>? data;
  bool loading = true;
  String? error;

  List<Map<String, dynamic>> conversations = [];
  bool loadingConversation = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadConversations();
  }

  // ================= LOAD PROFILE =================

  Future<void> _loadProfile() async {
    try {
      final res = await FamilyApi.getRelationshipProfile(widget.quanHeId);

      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  // ================= LOAD CONVERSATIONS =================
  Future<void> _loadConversations() async {
    try {
      setState(() => loadingConversation = true);
      print("QUANHE ID SEND: ${widget.quanHeId}");

      final res = await FamilyApi.getSharedConversation(widget.quanHeId);
      print("API RESPONSE: $res");

      setState(() {
        conversations = List<Map<String, dynamic>>.from(res);
        loadingConversation = false;
      });
    } catch (e) {
      print(e);
      setState(() => loadingConversation = false);
    }
  }
  // ================= FORMAT =================

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';

    final d = DateTime.parse(iso);

    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  String _genderText(dynamic g) {
    if (g == true) return context.tr.male;
    if (g == false) return context.tr.female;
    return '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Column(
                    children: [
                      _profileHeader(),
                      const SizedBox(height: 16),
                      Expanded(child: _content()),
                    ],
                  ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _profileHeader() {
    final avatar = FamilyApi.normalizeAvatar(data?['avatarurl']);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_ios_new, size: 18, color: blue),
                  const SizedBox(width: 4),
                  Text(
                    context.tr.back,
                    style: const TextStyle(fontSize: 15, color: blue),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundImage: avatar != null && avatar.isNotEmpty
                    ? NetworkImage(avatar)
                    : null,
                child:
                    avatar == null ? const Icon(Icons.person, size: 42) : null,
              ),
              const SizedBox(height: 12),
              Text(
                data?['tennd'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  // ================= CONTENT =================

  Widget _content() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        Text(
          context.tr.basicInfo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        _infoItem(context.tr.fullName, data?['tennd'] ?? ""),
        _infoItem(context.tr.birthDate, _formatDate(data?['ngaysinh'])),
        _infoItem(context.tr.gender, _genderText(data?['gioitinh'])),
        _infoItem(context.tr.joinDate, _formatDate(data?['ngaybatdau'])),
        const SizedBox(height: 8),
        Text(
          context.tr.report,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ReportItem(
                label: context.tr.day,
                type: 'day',
                quanHeId: widget.quanHeId,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ReportItem(
                label: context.tr.week,
                type: 'week',
                quanHeId: widget.quanHeId,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ReportItem(
                label: context.tr.month,
                type: 'month',
                quanHeId: widget.quanHeId,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _conversationSection(),
      ],
    );
  }

  // ================= CONVERSATION SECTION =================

  Widget _conversationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.sharedConversations,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        if (loadingConversation)
          const Center(child: CircularProgressIndicator()),
        if (!loadingConversation && conversations.isEmpty)
          Text(
            context.tr.noSharedConversations,
            style: TextStyle(color: Colors.grey),
          ),
        if (conversations.isNotEmpty)
          ...conversations.map((e) => _conversationCard(e)).toList(),
      ],
    );
  }

  // ================= CONVERSATION CARD =================

  Widget _conversationCard(Map<String, dynamic> item) {
    final chatId = item["hoithoai_id"]?.toString() ?? "";
    final image = (item["imageurl"] ?? "").toString();
    final imageUrl = image.isEmpty
        ? ""
        : (image.startsWith("http")
            ? image
            : "${ApiConfig.baseUrl}${image.startsWith("/") ? image : "/$image"}");

    return InkWell(
      onTap: () {
        if (chatId.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SharedConversationViewer(
              chatId: chatId,
              title: item["tendigitalhuman"]?.toString() ?? "Conversation",
              image: image,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              child: image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(imageUrl, fit: BoxFit.cover),
                    )
                  : Container(
                      color: Colors.blue.withOpacity(.1),
                      child: const Icon(Icons.smart_toy),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["tendigitalhuman"] ?? "Conversation",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatTime(item["lancuoituongtac"]),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  // ================= INFO ITEM =================

  Widget _infoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F41BB).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ================= REPORT ITEM =================

class _ReportItem extends StatelessWidget {
  final String label;
  final String type;
  final String quanHeId;

  const _ReportItem({
    required this.label,
    required this.type,
    required this.quanHeId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailScreen(type: type, quanHeId: quanHeId),
          ),
        );
      },
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1F41BB).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F41BB).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 18),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
