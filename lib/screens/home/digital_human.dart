import 'package:flutter/material.dart';

class DigitalHumanAllScreen extends StatelessWidget {
  const DigitalHumanAllScreen({super.key});

  // ===== CONSTANTS =====
  static const _bg = Color(0xFFF3F5F9);

  // ===== DATA =====
  static const _humans = [
    {
      'name': 'Luna - Nurse',
      'desc': 'Provides compassionate care and medical support.',
      'img': 'assets/images/Luna.png',
    },
    {
      'name': 'Anna - Lawyer',
      'desc': 'Gives legal advice and document assistance.',
      'img': 'assets/images/Anna.png',
    },
    {
      'name': 'Nutrition Expert',
      'desc': 'Customized meal plans and nutrition advice.',
      'img': 'assets/images/Nutrition.png',
    },
    {
      'name': 'Zodiac Expert',
      'desc': 'Personalized insights based on your zodiac sign.',
      'img': 'assets/images/Zodiac.png',
    },
    {
      'name': 'Fitness Trainer',
      'desc': 'Exercises adapted to your health condition.',
      'img': 'assets/images/Fitness.png',
    },
    {
      'name': 'Mindfulness Mentor',
      'desc': 'Meditation and breathing guidance.',
      'img': 'assets/images/Mindfulness.png',
    },
  ];

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _appBar(context),
      body: _grid(),
    );
  }

  // ===== APP BAR =====
  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Digital Human',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ===== GRID =====
  Widget _grid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _humans.length,
      itemBuilder: (_, i) => _HumanGridCard(
        name: _humans[i]['name']!,
        desc: _humans[i]['desc']!,
        img: _humans[i]['img']!,
      ),
    );
  }
}

// ===== CARD =====
class _HumanGridCard extends StatelessWidget {
  final String name;
  final String desc;
  final String img;

  const _HumanGridCard({
    required this.name,
    required this.desc,
    required this.img,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Colors.black.withOpacity(.75),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
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
    );
  }
}
