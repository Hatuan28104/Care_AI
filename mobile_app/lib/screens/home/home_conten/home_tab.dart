import 'package:flutter/material.dart';

import 'digital_human.dart';
import 'chat.dart';
import 'data/basic_health_data.dart';
import 'data/activity_data.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static final List<Map<String, String>> _humans = [
    {
      'name': 'Luna – Y tá',
      'desc': 'Hỗ trợ chăm sóc tận tình và tư vấn y tế.',
      'img': 'assets/images/Luna.png',
    },
    {
      'name': 'Anna – Luật sư',
      'desc': 'Tư vấn pháp lý và hỗ trợ giấy tờ.',
      'img': 'assets/images/Anna.png',
    },
    {
      'name': 'Chuyên gia dinh dưỡng',
      'desc': 'Lập thực đơn và tư vấn dinh dưỡng phù hợp.',
      'img': 'assets/images/Nutrition.png',
    },
    {
      'name': 'Chuyên gia cung hoàng đạo',
      'desc': 'Tư vấn cá nhân dựa trên cung hoàng đạo.',
      'img': 'assets/images/Zodiac.png',
    },
    {
      'name': 'Huấn luyện viên thể chất',
      'desc': 'Bài tập phù hợp với tình trạng sức khỏe.',
      'img': 'assets/images/Fitness.png',
    },
    {
      'name': 'Hướng dẫn thiền',
      'desc': 'Hướng dẫn thiền định và hít thở thư giãn.',
      'img': 'assets/images/Mindfulness.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(child: _content(context)),
      ],
    );
  }

  // ===== CONTENT =====
  Widget _content(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _welcomeCard(context),
          const SizedBox(height: 10),

          _sectionHeader(
            title: 'Digital Human',
            action: () => _go(context, const DigitalHumanAllScreen()),
          ),
          const SizedBox(height: 12),
          _digitalHumanList(),

          const SizedBox(height: 26),

          // ===== HEALTH CATEGORY =====
          const Text(
            'Danh mục sức khỏe',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _categoryItem(
            icon: Icons.accessibility_new,
            iconColor: Colors.purple,
            text: 'Dữ liệu hoạt động',
            onTap: () => _go(
              context,
              const ActivityDataScreen(),
            ),
          ),
          const SizedBox(height: 6),
          _categoryItem(
            icon: Icons.local_fire_department,
            iconColor: Colors.red,
            text: 'Dữ liệu sức khỏe',
            onTap: () => _go(
              context,
              const BasicHealthDataScreen(),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ===== WELCOME CARD =====
  Widget _welcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F41BB),
            Color(0xFF1877F2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Xin chào 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Hôm nay bạn muốn\nđược hỗ trợ điều gì?',
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
                ChatScreen(
                  name: 'Luna – Y tá',
                  role: 'Hỗ trợ chăm sóc tận tình và tư vấn y tế.',
                  image: 'assets/images/Luna.png',
                  intro:
                      'Xin chào 👋 Tôi có thể hỗ trợ bạn hôm nay như thế nào?',
                ),
              );
            },
            child: const Text(
              'Bắt đầu',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ===== DIGITAL HUMAN LIST =====
  Widget _digitalHumanList() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        itemCount: _humans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _humanCard(context, _humans[i]),
      ),
    );
  }

  // ===== SECTION HEADER =====
  Widget _sectionHeader({required String title, VoidCallback? action}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: action,
            child: const Text(
              'Tất cả',
              style: TextStyle(
                color: Color(0xFF1877F2),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // ===== HUMAN CARD =====
  Widget _humanCard(BuildContext context, Map<String, String> h) {
    return GestureDetector(
      onTap: () {
        _go(
          context,
          ChatScreen(
            name: h['name']!,
            role: h['desc']!,
            image: h['img']!,
            intro: 'Xin chào 👋 Tôi có thể hỗ trợ bạn hôm nay như thế nào?',
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
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  h['img']!,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      h['desc']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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

  // ===== CATEGORY ITEM =====
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

  // ===== NAVIGATION =====
  static void _go(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
