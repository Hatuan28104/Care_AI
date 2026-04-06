import 'package:flutter/material.dart';
import 'dart:async';
import 'package:Care_AI/app_settings.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/common_confirm_dialog.dart';
import 'package:Care_AI/api/alert_api.dart';
import 'package:Care_AI/widgets/app_components.dart';
import 'alert_detail.dart';
import 'package:Care_AI/services/time_service.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> with WidgetsBindingObserver {
  static const _blue = Color(0xFF1877F2);

  final List<_AlertItem> _alerts = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    loadAlerts();
    AppSettings.alertVersion.addListener(_onNewAlert);
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      loadAlerts();
    });
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
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    AppSettings.alertVersion.removeListener(_onNewAlert);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadAlerts();
    }
  }
  /* ================= LOAD ALERT ================= */

  Future<void> loadAlerts() async {
    try {
      final data = await AlertApi.getAlerts();
      if (!mounted) return;

      setState(() {
        // Sort Newest First (UTC ISO string comparison works fine)
        data.sort((a, b) =>
            b["thoigian"].toString().compareTo(a["thoigian"].toString()));

        _alerts.clear();
        _alerts.addAll(
          data.map(
            (e) => _AlertItem(
              id: e["notification_id"].toString(),
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.red,
              title: (e["tieude"] ?? "Thông báo").toString(),
              thoigian: (e["thoigian"] ?? "").toString(),
              detail: (e["noidung"] ?? "").toString(),
              level: e["level"] ?? 1,
              isRead: e["dadoc"] == true,
            ),
          ),
        );
      });
      _syncBadge();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _syncBadge() {
    final unread = _alerts.where((e) => !e.isRead).length;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppSettings.unreadAlertCount.value = unread;
    });
  }

  Color _getBorderColor(String title, String detail) {
    final text = (title + " " + detail).toLowerCase();

    if (text.contains("nguy hiểm") || text.contains("giảm")) {
      return Colors.red;
    }

    if (text.contains("bình thường") || text.contains("ổn định")) {
      return const Color(0xFFE6EA00);
    }

    if (text.contains("tốt") || text.contains("tuyệt vời")) {
      return const Color(0xFF139D4A);
    }

    return Colors.grey.shade300;
  }
  /* ================= BUILD ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: context.tr.notifications, showBack: true),
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
            const SizedBox(height: 12),
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

    String? lastDate;

    return RefreshIndicator(
      onRefresh: loadAlerts,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
        itemCount: _alerts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final item = _alerts[i];
          final dateHeader = TimeService.formatDateSmart(item.thoigian);

          final showDate = dateHeader != lastDate;
          lastDate = dateHeader;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showDate)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    dateHeader,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7A7A7A),
                    ),
                  ),
                ),
              _tile(context, item),
            ],
          );
        },
      ),
    );
  }

  /* ================= ITEM ================= */

  Widget _tile(BuildContext context, _AlertItem item) {
    final borderColor = _getBorderColor(item.title, item.detail);
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
                title: context.tr.confirmDelete,
                message: context.tr.deleteAlertWarning,
                confirmText: context.tr.delete,
                cancelText: context.tr.cancel,
                confirmColor: Colors.red,
              );

              if (ok == true) {
                try {
                  await AlertApi.deleteAlert(item.id);
                  setState(() => _alerts.remove(item));
                  _syncBadge();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.delete, size: 26, color: Colors.white),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlertMessageDetail(
                title: item.title,
                detail: item.detail,
                thoigian: item.thoigian,
              ),
            ),
          );

          if (!item.isRead) {
            try {
              await AlertApi.markAsRead(item.id);
              setState(() => item.isRead = true);
              _syncBadge();
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: item.isRead ? Colors.transparent : borderColor,
              width: item.isRead ? 0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: item.isRead ? 4 : 8,
                color: borderColor.withOpacity(item.isRead ? 0.1 : 0.3),
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                color: borderColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      TimeService.formatTime(item.thoigian),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (!item.isRead) const Icon(Icons.circle, size: 8, color: _blue),
            ],
          ),
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
  final String thoigian; // raw ISO
  final String detail;
  final int level;
  bool isRead;

  _AlertItem({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.thoigian,
    required this.detail,
    required this.level,
    this.isRead = false,
  });
}
