import 'package:flutter/material.dart';

class DigitalHumanAllScreen extends StatelessWidget {
  const DigitalHumanAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Digital Human',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
        children: const [
          _HumanGridCard(
            name: 'Luna - Nurse',
            desc:
                'Personalized care guidance, medication reminders, and daily health check support.',
            img:
                'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
          ),
          _HumanGridCard(
            name: 'Anna - Lawyer',
            desc:
                'Gives legal advice and document assistance.',
            img:
                'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
          ),
          _HumanGridCard(
            name: 'Nutrition Expert',
            desc:
                'Provides customized meal plans and nutrition advice tailored to health conditions and age.',
            img:
                'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
          ),
          _HumanGridCard(
            name: 'Zodiac Expert',
            desc:
                'Personalized insights based on your zodiac sign.',
            img:
                'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
          ),
          _HumanGridCard(
            name: 'Fitness Trainer',
            desc:
                'Simple exercises such as stretching, yoga, or walking, adjusted to user health condition.',
            img:
                'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
          ),
          _HumanGridCard(
            name: 'Mindfulness Mentor',
            desc:
                'Guides meditation and breathing techniques to reduce stress and improve sleep quality.',
            img:
                'https://images.unsplash.com/photo-1607746882042-944635dfe10e',
          ),
        ],
      ),
    );
  }
}

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
              Colors.black.withOpacity(0.75),
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
}
