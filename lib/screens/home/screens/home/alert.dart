import 'package:flutter/material.dart';
import '../../app_settings.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  static const _bg = Color(0xFFF3F5F9);
  static const _blue = Color(0xFF1F6BFF);

  // ===== DEMO DATA =====
  final List<_AlertItem> _alerts = [
    _AlertItem(
      id: 'a1',
      icon: Icons.favorite,
      iconColor: Colors.red,
      title: 'Abnormally increased heart rate',
      time: '17:35 Today',
      detail:
          'Your heart rate increased abnormally. Consider resting and re-measuring in 5 minutes.',
      isRead: false,
    ),
    _AlertItem(
      id: 'a2',
      icon: Icons.sentiment_dissatisfied,
      iconColor: Colors.orange,
      title: 'Negative emotions',
      time: '14:35 Today',
      detail:
          'We detected signs of negative emotions. Try breathing exercises or talk to someone you trust.',
      isRead: false,
    ),
    _AlertItem(
      id: 'a3',
      icon: Icons.access_time,
      iconColor: Colors.black54,
      title: 'No response for a long time',
      time: '23:05 yesterday',
      detail:
          'You have not interacted with the device for a long time. Please check connection.',
      isRead: true,
    ),
    _AlertItem(
      id: 'a4',
      icon: Icons.bedtime,
      iconColor: Colors.indigo,
      title: 'Abnormal sleep',
      time: '21:05 yesterday',
      detail:
          'Your sleep pattern appears unusual. Try to keep a consistent bedtime.',
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _syncBadge(); // ✅ safe update (post-frame)
  }

  // ✅ FIX: update badge AFTER build frame, avoid "called during build"
  void _syncBadge() {
    final unread = _alerts.where((e) => !e.isRead).length;

    // tránh set lại nếu không đổi
    if (AppSettings.unreadAlertCount.value == unread) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppSettings.unreadAlertCount.value = unread;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(child: _list(context)),
          ],
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Alert',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                for (final a in _alerts) {
                  a.isRead = true;
                }
              });
              _syncBadge(); // ✅ safe
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: _blue,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== LIST =====
  Widget _list(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      itemCount: _alerts.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i == 0) {
          return const Text(
            'PREVIOUS 7 DAYS',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          );
        }
        final item = _alerts[i - 1];
        return _tile(context, item);
      },
    );
  }

  // ===== ITEM =====
  Widget _tile(BuildContext context, _AlertItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      // ✅ POPUP xác nhận trước khi xóa
      confirmDismiss: (_) async {
        final ok = await _showDeleteConfirm(context);
        return ok == true;
      },

      onDismissed: (_) async {
        setState(() {
          _alerts.removeWhere((e) => e.id == item.id);
        });
        _syncBadge();

        // ✅ POPUP xóa thành công
        await _showDeletedSuccess(context);
      },

      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _AlertDetail(item: item),
            ),
          );
          if (!item.isRead) {
            setState(() => item.isRead = true);
            _syncBadge();
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Color(0x11000000),
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(item.icon, color: item.iconColor, size: 22),
                  if (!item.isRead)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: _blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirm(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: const Icon(Icons.priority_high, color: Colors.red),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Delete Your Alert',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your actions may have serious consequences.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC1C1),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDEDED),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeletedSuccess(BuildContext context) async {
    // show
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(Icons.check, color: Colors.green),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Deleted Successfully',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );

    // auto close after 1s
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context);
  }
}

// ===== DETAIL SCREEN =====
class _AlertDetail extends StatelessWidget {
  const _AlertDetail({required this.item});

  final _AlertItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Alert',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, color: item.iconColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      item.detail,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== MODEL (PRIVATE) =====
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
