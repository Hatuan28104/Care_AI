import 'package:flutter/material.dart';
import 'package:Care_AI/api/digital_api.dart';
import 'digital_human.dart';
import 'chat.dart';
import 'data/basic_health_data.dart';
import 'data/activity_data.dart';
import '../../../models/tr.dart';

class HomeTab extends StatefulWidget {
  final String userId;

  const HomeTab({
    super.key,
    required this.userId,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<List<dynamic>> _futureHumans;

  @override
  void initState() {
    super.initState();
    _futureHumans = DigitalApi.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(child: _content(context)),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _welcomeCard(context),
          const SizedBox(height: 10),
          _sectionHeader(
            context: context,
            title: context.tr.digitalHumanSection,
            action: () => _go(
              context,
              DigitalHumanAllScreen(userId: widget.userId),
            ),
          ),
          const SizedBox(height: 12),
          _digitalHumanList(),
          const SizedBox(height: 26),
          Text(
            context.tr.healthCategories,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _categoryItem(
            icon: Icons.accessibility_new,
            iconColor: Colors.purple,
            text: context.tr.activityData,
            onTap: () => _go(context, const BasicHealthDataScreen()),
          ),
          const SizedBox(height: 6),
          _categoryItem(
            icon: Icons.local_fire_department,
            iconColor: Colors.red,
            text: context.tr.healthData,
            onTap: () => _go(context, const ActivityDataScreen()),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ================= WELCOME CARD =================

  Widget _welcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1F41BB), Color(0xFF1877F2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.hello,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  context.tr.whatSupportToday,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1F41BB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              _go(
                context,
                DigitalHumanAllScreen(userId: widget.userId),
              );
            },
            child: Text(
              context.tr.start,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DIGITAL HUMAN LIST =================

  Widget _digitalHumanList() {
    return SizedBox(
      height: 230,
      child: FutureBuilder<List<dynamic>>(
        future: _futureHumans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(context.tr.loadDataError));
          }

          final humans = snapshot.data!;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: humans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final human = humans[index];

              return GestureDetector(
                onTap: () {
                  _go(
                    context,
                    ChatScreen(
                      name: human['TenDigitalHuman'],
                      image: "http://10.0.2.2:3000/${human['ImageUrl']}",
                      intro: context.tr.aiIntro,
                      digitalId: human['DigitalHuman_ID'].toString().trim(),
                      userId: widget.userId,
                    ),
                  );
                },
                child: Container(
                  width: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.black.withOpacity(.6),
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      "http://10.0.2.2:3000/${human['ImageUrl']}",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= CATEGORY ITEM =================

  Widget _categoryItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

Widget _sectionHeader({
  required BuildContext context,
  required String title,
  VoidCallback? action,
}) {
  return Row(
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      const Spacer(),
      if (action != null)
        GestureDetector(
          onTap: action,
          child: Text(
            context.tr.viewAll,
            style: const TextStyle(
              color: Color(0xFF1877F2),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    ],
  );
}
