import 'package:flutter/material.dart';
import 'chat.dart';

class DigitalHumanAllScreen extends StatelessWidget {
  const DigitalHumanAllScreen({super.key});

  static const _humans = [
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
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: _appBar(context),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _humans.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (_, i) => _HumanCard(h: _humans[i]),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Nhân vật số',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ===== CARD GIỐNG HOME =====
class _HumanCard extends StatelessWidget {
  final Map<String, String> h;

  const _HumanCard({required this.h});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              name: h['name']!,
              role: h['desc']!,
              image: h['img']!,
              intro: "Hello 👋 How can I help you today?",
            ),
          ),
        );
      },
      child: Container(
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
}
