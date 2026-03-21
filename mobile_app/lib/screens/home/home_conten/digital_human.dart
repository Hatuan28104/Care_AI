import 'package:flutter/material.dart';
import 'package:demo_app/api/digital_api.dart';
import 'package:demo_app/config/api_config.dart';
import 'chat.dart';
import '../../../models/tr.dart';

class DigitalHumanAllScreen extends StatefulWidget {
  final String userId;

  const DigitalHumanAllScreen({
    super.key,
    required this.userId,
  });

  @override
  State<DigitalHumanAllScreen> createState() => _DigitalHumanAllScreenState();
}

class _DigitalHumanAllScreenState extends State<DigitalHumanAllScreen> {
  late Future<List<dynamic>> _futureHumans;

  String _imageUrlFrom(dynamic raw) {
    final value = raw?.toString() ?? '';
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    final clean = value.startsWith('/') ? value : '/$value';
    return '${ApiConfig.baseUrl}$clean';
  }

  @override
  void initState() {
    super.initState();
    _futureHumans = DigitalApi.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr.digitalHuman,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureHumans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(context.tr.loadDataError),
            );
          }

          final humans = snapshot.data ?? [];
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: humans.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.78,
            ),
            itemBuilder: (_, index) {
              final human = humans[index];

              return GestureDetector(
                onTap: () {
                  final imageUrl = _imageUrlFrom(human['imageurl']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        name: (human['tendigitalhuman'] ?? '').toString(),
                        image: imageUrl,
                        intro: context.tr.aiIntro,
                        digitalId: (human['digitalhuman_id'] ?? '').toString(),
                        userId: widget.userId,
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
                            child: Image.network(
                          _imageUrlFrom(human['imageurl']),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        )),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Text(
                            (human['tendigitalhuman'] ?? '').toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
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
}
