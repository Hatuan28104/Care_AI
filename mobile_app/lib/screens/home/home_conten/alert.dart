import 'package:flutter/material.dart';
import '../../../app_settings.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:Care_AI/models/tr.dart';
import 'package:Care_AI/widgets/common_confirm_dialog.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  static const _bg = Color(0xFFF6F6F6);
  static const _blue = Color(0xFF1877F2);

  final List<_AlertItem> _alerts = [
    _AlertItem(
      id: 'a1',
      icon: Icons.favorite,
      iconColor: Colors.red,
      title: 'Abnormally increased heart rate',
      time: '17:35 Today',
      detail:
          'Your heart rate increased abnormally. Consider resting and re-measuring in 5 minutes.',
    ),
    _AlertItem(
      id: 'a2',
      icon: Icons.sentiment_dissatisfied,
      iconColor: Colors.orange,
      title: 'Negative emotions',
      time: '14:35 Today',
      detail:
          'We detected signs of negative emotions. Try breathing exercises or talk to someone you trust.',
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
    _syncBadge();
  }

  void _syncBadge() {
    final unread = _alerts.where((e) => !e.isRead).length;
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
            Expanded(child: _list()),
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
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.tr.notifications,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  // ===== LIST =====
  Widget _list() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      itemCount: _alerts.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Row(
            children: [
              Text(
                context.tr.today.toUpperCase(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    for (final a in _alerts) {
                      a.isRead = true;
                    }
                  });
                  _syncBadge();
                },
                child: Text(
                  context.tr.markAllRead,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _blue,
                  ),
                ),
              ),
            ],
          );
        }
        return _tile(context, _alerts[i - 1]);
      },
    );
  }

  // ===== ITEM =====
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
                setState(() => _alerts.remove(item));
                _syncBadge();
              }
            },
            backgroundColor: Colors.red,
            borderRadius: BorderRadius.circular(10),
            child: const Center(
              child: Icon(
                Icons.delete,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _AlertDetail(item: item)),
          );
          if (!item.isRead) {
            setState(() => item.isRead = true);
            _syncBadge();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: Color.fromARGB(200, 0, 0, 0),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
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
                    child: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        context.tr.alert,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(18),
              child: _HeartRateCard(item: item),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== CARD =====
class _HeartRateCard extends StatelessWidget {
  const _HeartRateCard({required this.item});
  final _AlertItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 173, 173, 173),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x22000000),
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // icon + title
          Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: Colors.red, size: 100),
              ),
              const SizedBox(width: 60),
              Text(
                context.tr.heartRateTitle,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // BPM
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic, // 👈 BẮT BUỘC
            children: const [
              Text(
                '140',
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 6),
              Text(
                'BPM',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // High badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color.fromARGB(208, 244, 67, 54)),
            ),
            child: Text(
              context.tr.high,
              style: TextStyle(
                color: const Color.fromARGB(208, 244, 67, 54),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // user
          const Row(
            children: [
              Icon(Icons.person, size: 30, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                'Alizabeth Browns',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // time + date
          const Row(
            children: [
              Icon(Icons.access_time, size: 30, color: Colors.black54),
              SizedBox(width: 6),
              Text('10:30 – 11:00'),
              SizedBox(width: 20),
              Icon(Icons.calendar_today, size: 24, color: Colors.black54),
              SizedBox(width: 6),
              Text('October 28th, 2025'),
            ],
          ),

          const SizedBox(height: 10),

          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: context.tr.detailedDescription,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: context.tr.unstableHeartRate,
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== MODEL =====
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
