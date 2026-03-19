import 'package:flutter/material.dart';
import 'package:Care_AI/app_settings.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/common_confirm_dialog.dart';
import 'package:Care_AI/api/alert_api.dart';
import 'package:Care_AI/models/current_user.dart';
import 'package:Care_AI/widgets/app_header.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  static const _bg = Color(0xFFF6F6F6);
  static const _blue = Color(0xFF1877F2);

  final List<_AlertItem> _alerts = [];

  @override
  void initState() {
    super.initState();

    loadAlerts();
    AppSettings.alertVersion.addListener(_onNewAlert);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onNewAlert() {
    loadAlerts();
  }

  @override
  void dispose() {
    AppSettings.alertVersion.removeListener(_onNewAlert);
    super.dispose();
  }
  /* ================= LOAD ALERT ================= */

  Future<void> loadAlerts() async {
    final user = CurrentUser.user;

    if (user == null) {
      return;
    }

    final userId = user.nguoiDungId;
    final data = await AlertApi.getAlerts(userId);

    if (!mounted) return;

    setState(() {
      _alerts.clear();

      _alerts.addAll(data.map((e) => _AlertItem(
            id: e["Notification_ID"],
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.red,
            title: e["TieuDe"] ?? "Thông báo",
            time: _formatTime(e["ThoiGian"]),
            detail: e["NoiDung"],
            isRead: e["DaDoc"] ?? false,
          )));
    });

    _syncBadge();
  }

  String _formatTime(String? iso) {
    if (iso == null || iso.isEmpty) return "";

    final date = DateTime.parse(iso).toLocal();
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}  •  ${date.day}/${date.month}";
  }

  void _syncBadge() {
    final unread = _alerts.where((e) => !e.isRead).length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppSettings.unreadAlertCount.value = unread;
    });
  }

  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: context.tr.notifications,
              showBack: true,
            ),
            Expanded(child: _list()),
          ],
        ),
      ),
    );
  }

  /* ================= LIST ================= */

  Widget _list() {
    if (_alerts.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadAlerts,
        child: ListView(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                context.tr.noAlerts,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadAlerts,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
        itemCount: _alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _tile(context, _alerts[i]),
      ),
    );
  }

  /* ================= ITEM ================= */

  Widget _tile(BuildContext context, _AlertItem item) {
    return Slidable(
      key: ValueKey(item.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          CustomSlidableAction(
            onPressed: (_) async {
              final ok = await showConfirmDialog(
                context,
                title: context.tr.deleteAlertTitle,
                message: context.tr.deleteAlertWarning,
                confirmText: context.tr.accept,
                cancelText: context.tr.cancel,
                confirmColor: Colors.red,
              );

              if (ok == true) {
                final user = CurrentUser.user;

                if (user != null) {
                  await AlertApi.deleteAlert(item.id, user.nguoiDungId);
                }

                setState(() => _alerts.remove(item));
                _syncBadge();
              }
            },
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.delete, size: 26, color: Colors.white),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _AlertDetail(item: item),
            ),
          );

          if (!item.isRead) {
            final user = CurrentUser.user;

            if (user != null) {
              await AlertApi.markAsRead(item.id, user.nguoiDungId);
            }

            setState(() => item.isRead = true);
            _syncBadge();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFFFF4F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isRead ? Colors.transparent : Colors.red.shade200,
              width: item.isRead ? 0 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Color(0x11000000),
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(item.icon, color: item.iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                const Icon(Icons.circle, size: 10, color: _blue),
            ],
          ),
        ),
      ),
    );
  }
}

/* ================= DETAIL ================= */

class _AlertDetail extends StatelessWidget {
  const _AlertDetail({required this.item});
  final _AlertItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: context.tr.alert,
              showBack: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color.fromARGB(255, 254, 136, 136)),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 12,
                            color: Color(0x11000000),
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item.icon,
                                color: item.iconColor,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                item.time,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item.detail,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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

/* ================= MODEL ================= */

class _AlertItem {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final String detail;
  bool isRead;

  _AlertItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.detail,
    this.isRead = false,
  });
}
