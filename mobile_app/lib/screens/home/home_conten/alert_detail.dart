import 'package:flutter/material.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/services/time_service.dart';

class AlertMessageDetail extends StatelessWidget {
  const AlertMessageDetail({
    super.key,
    required this.title,
    required this.detail,
    required this.thoigian,
  });

  final String title;
  final String detail;
  final String thoigian;

  Color _getBorderColor(String title, String detail) {
    final text = (title + " " + detail).toLowerCase();

    if (text.contains("nguy hiểm") || text.contains("bất thường")) {
      return Colors.red;
    }
    if (text.contains("tốt") ||
        text.contains("tuyệt vời") ||
        text.contains("ổn định") ||
        text.contains("tích cực")) {
      return Colors.green;
    }

    if (text.contains("bình thường")) {
      return const Color(0xFFE6EA00);
    }
    return Colors.grey.shade300;
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget content,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            child: Align(
              alignment: isMultiline ? Alignment.topCenter : Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(top: isMultiline ? 2 : 0),
                child: Icon(icon, size: 18, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          Expanded(child: content),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(title, detail);
    final isCompare = detail.toLowerCase().contains("so sánh");

    String sender = "";
    String message = detail;

    if (detail.trim().startsWith("Người thân:")) {
      final parts = detail.split(":");

      if (parts.length > 1) {
        final possibleName = parts[1].trim().split("\n").first.trim();

        if (possibleName.isNotEmpty && possibleName.split(" ").length >= 2) {
          sender = possibleName;

          message = detail.replaceFirst(RegExp(r"Người thân:.*\n?"), "").trim();
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.alert, showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          color: borderColor.withOpacity(0.25),
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: borderColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isCompare
                                    ? Icons.show_chart
                                    : Icons.chat_bubble_outline,
                                color: borderColor,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Text(
                          context.tr.messageInfo,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(height: 12),

                        /// ✅ Chỉ hiện khi có tên thật
                        if (sender.isNotEmpty)
                          _buildInfoRow(
                            icon: Icons.person,
                            label: context.tr.relative,
                            content: Text(sender),
                          ),

                        _buildInfoRow(
                          icon: Icons.access_time,
                          label: context.tr.time,
                          content: Text(TimeService.formatFull(thoigian)),
                        ),

                        _buildInfoRow(
                          icon: Icons.description_outlined,
                          label: context.tr.content,
                          isMultiline: true,
                          content: Text(
                            message,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
