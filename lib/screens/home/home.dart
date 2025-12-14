import 'package:flutter/material.dart';
import 'digital_human.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const blue = Color(0xFF1F6BFF);
  static const bg = Color(0xFFF3F5F9);

  // ===== DATA DIGITAL HUMAN =====
  static final List<Map<String, String>> _humans = [
    {
      'name': 'Luna - Nurse',
      'desc': 'Provides compassionate care and medical support.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
    {
      'name': 'Anna - Lawyer',
      'desc': 'Gives legal advice and document assistance.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
    {
      'name': 'Nutrition Expert',
      'desc': 'Customized meal plans and nutrition advice.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
    {
      'name': 'Fitness Trainer',
      'desc': 'Exercises adapted to your health condition.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
    {
      'name': 'Mindfulness Mentor',
      'desc': 'Meditation and breathing guidance.',
      'img': 'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
              child: Row(
                children: [
                  const Text(
                    'Care AI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color.fromARGB(255, 13, 69, 159),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: blue.withOpacity(.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child:
                        const Icon(Icons.auto_awesome, color: blue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.notifications_none, size: 22),
                  const SizedBox(width: 12),
                  const Icon(Icons.settings_outlined, size: 22),
                ],
              ),
            ),

            // ===== PREMIUM BANNER =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.smart_toy, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Your free 3-day Premium hasn't been claimed yet. Tap to claim.",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ===== CONTENT =====
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== DIGITAL HUMAN TITLE =====
                    Row(
                      children: [
                        const Text(
                          'Digital Human',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DigitalHumanAllScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ===== KÉO NGANG DIGITAL HUMAN (CHUẨN) =====
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(), // 👈 QUAN TRỌNG
                        itemCount: _humans.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final h = _humans[index];
                          return _humanCard(
                            name: h['name']!,
                            desc: h['desc']!,
                            img: h['img']!,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ===== HEALTH CATEGORY =====
                    const Text(
                      'Health Categories',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),

                    _categoryItem(
                      icon: Icons.accessibility_new,
                      iconColor: Colors.purple,
                      text: 'Basic health data',
                    ),
                    const SizedBox(height: 10),
                    _categoryItem(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.red,
                      text: 'Activity data',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== BOTTOM NAV =====
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined), label: 'Family Center'),
          BottomNavigationBarItem(
              icon: Icon(Icons.graphic_eq), label: 'Device'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  // ===== CARD DIGITAL HUMAN =====
  static Widget _humanCard({
    required String name,
    required String desc,
    required String img,
  }) {
    return Container(
      width: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: NetworkImage(img),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== CATEGORY ITEM =====
  static Widget _categoryItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
