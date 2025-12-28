import 'package:flutter/material.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // ===== CONSTANTS =====
  static const _blue = Color(0xFF1F6BFF);
  static const _bg = Color(0xFFF3F5F9);

  // ===== STATE =====
  bool _freeTrial = false;
  String _plan = 'yearly'; // yearly | monthly

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 14),
              _hero(),
              const SizedBox(height: 20),
              _features(),
              const SizedBox(height: 16),
              _freeTrialSwitch(),
              const SizedBox(height: 16),
              _plans(),
              const Spacer(),
              _continueButton(),
              const SizedBox(height: 10),
              _footer(),
            ],
          ),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
        const Text(
          'CARE AI',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            // TODO: Restore purchase
          },
          child: const Text('Restore'),
        ),
      ],
    );
  }

  // ===== HERO =====
  Widget _hero() {
    return Column(
      children: const [
        Icon(Icons.health_and_safety, size: 80, color: _blue),
        SizedBox(height: 12),
        Text(
          'GET PRO ACCESS',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // ===== FEATURES =====
  Widget _features() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _FeatureItem('Unlimited calls with Digital Human'),
        _FeatureItem('Add family members'),
        _FeatureItem('Add devices'),
      ],
    );
  }

  // ===== FREE TRIAL =====
  Widget _freeTrialSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text(
            'Enable Free Trial',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Switch(
            value: _freeTrial,
            activeColor: _blue,
            onChanged: (v) => setState(() => _freeTrial = v),
          ),
        ],
      ),
    );
  }

  // ===== PLANS =====
  Widget _plans() {
    return Column(
      children: [
        _planCard(
          tag: 'BEST VALUE',
          title: 'YEARLY',
          price: '1,199,000đ / year',
          selected: _plan == 'yearly',
          onTap: () => setState(() => _plan = 'yearly'),
        ),
        const SizedBox(height: 10),
        _planCard(
          title: 'MONTHLY',
          price: '150,000đ / month',
          selected: _plan == 'monthly',
          onTap: () => setState(() => _plan = 'monthly'),
        ),
      ],
    );
  }

  Widget _planCard({
    String? tag,
    required String title,
    required String price,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _blue : Colors.grey.shade300,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CONTINUE =====
  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Purchase via Google Play / App Store
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  // ===== FOOTER =====
  Widget _footer() {
    return Column(
      children: const [
        Text(
          'Auto-renews yearly unless canceled.',
          style: TextStyle(fontSize: 11, color: Colors.black54),
        ),
        SizedBox(height: 4),
        Text(
          'Terms of Use · Privacy Policy',
          style: TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

// ===== FEATURE ITEM =====
class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
