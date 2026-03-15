import 'package:flutter/material.dart';
import 'familycenter_health_data.dart';
import 'familycenter_conversation.dart';
import '../../../models/tr.dart';

class ConfigurePermissionsScreen extends StatelessWidget {
  final String userId;
  final String quanHeId;

  const ConfigurePermissionsScreen({
    super.key,
    required this.userId,
    required this.quanHeId,
  });

  static const Color _blue = Color(0xFF1877F2);
  static const Color _bg = Color(0xFFF6F6F6);

  @override
  Widget build(BuildContext context) {
    print("ConfigurePermissionsScreen userId = $userId");
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _titleBar(context),
            Expanded(child: _content(context)),
          ],
        ),
      ),
    );
  }

  // ================= TITLE BAR =================
  Widget _titleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.tr.configurePermissions,
                style: const TextStyle(
                  fontSize: 24,
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

  // ================= CONTENT =================
  Widget _content(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
      children: [
        _permissionCard(
          icon: Icons.chat_bubble_outline,
          title: context.tr.conversationHistory,
          desc: context.tr.chooseConversationsToShare,
          buttonText: context.tr.chooseConversation,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConversationScreen(
                  userId: userId,
                  quanHeId: quanHeId,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _permissionCard(
          icon: Icons.favorite,
          iconColor: Colors.redAccent,
          title: context.tr.basicHealthData,
          desc: context.tr.shareImportantHealthData,
          buttonText: context.tr.chooseHealthData,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HealthDataScreen(
                  quanHeId: quanHeId,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ================= PERMISSION CARD =================
  Widget _permissionCard({
    required IconData icon,
    Color iconColor = Colors.black,
    required String title,
    required String desc,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITLE =====
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ===== DESC + BUTTON =====
          Center(
            child: Column(
              children: [
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        buttonText,
                        style: const TextStyle(
                          color: _blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: _blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
