import 'package:flutter/material.dart';
import 'package:Care_AI/screens/settings/privacy_security/privacy_policy.dart';
import 'package:Care_AI/screens/settings/privacy_security/terms_of_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // ===== COLORS =====
  static const Color _blue = Color(0xFF1F6BFF);
  static const Color _bg = Colors.white;
  static const Color _yearlyFill = Color(0xFFEAF7EF);
  static const Color _border = Color.fromARGB(80, 0, 0, 0);
  static const Color _textMuted = Color.fromARGB(255, 177, 182, 192);

  // ===== TEXT STYLES =====
  static const TextStyle _careStyle =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w800);
  static const TextStyle _title =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w700);
  static const TextStyle _itemTitle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const TextStyle _itemText =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400);

  // ===== STATE =====
  bool _freeTrial = false;
  String _plan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            children: [
              _header(context),
              const SizedBox(height: 8),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _hero(),
                      const SizedBox(height: 4),
                      _features(),
                      const SizedBox(height: 8),
                      _freeTrialSwitch(),
                      const SizedBox(height: 8),
                      _plans(),
                      const SizedBox(height: 16),
                      _continueButton(),
                      const SizedBox(height: 8),
                      _footer(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== HEADER =====
  Widget _header(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        children: [
          _circleIcon(
            icon: Icons.close,
            onTap: () => Navigator.pop(context),
            align: Alignment.centerLeft,
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: RichText(
                text: const TextSpan(
                  style: _careStyle,
                  children: [
                    TextSpan(
                        text: 'CARE ', style: TextStyle(color: Colors.black)),
                    TextSpan(text: 'AI', style: TextStyle(color: _blue)),
                  ],
                ),
              ),
            ),
          ),
          _pill(
            text: 'Restore',
            align: Alignment.centerRight,
          ),
        ],
      ),
    );
  }

  // ===== HERO =====
  Widget _hero() {
    return Column(
      children: [
        Image.asset('assets/images/Logo.png', height: 130),
        const Text('GET PRO ACCESS', style: _title),
      ],
    );
  }

  // ===== FEATURES =====
  Widget _features() {
    return const Column(
      children: [
        _FeatureItem(
          icon: Icons.phone_in_talk,
          title: 'UNLIMITED CALLS',
          tail: 'with Digital Human',
        ),
        _FeatureItem(icon: Icons.groups, title: 'ADD FAMILY MEMBERS'),
        _FeatureItem(icon: Icons.laptop_mac, title: 'ADD DEVICES'),
      ],
    );
  }

  // ===== FREE TRIAL =====
  Widget _freeTrialSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const Text(
            'Enable Free Trial',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _freeTrial,
              activeTrackColor: _blue,
              inactiveTrackColor: const Color(0xFFDAD9D9),
              inactiveThumbColor: Colors.white,
              onChanged: (v) => setState(() => _freeTrial = v),
            ),
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
          subtitle: 'Just 1,199,000 per year',
          price: '1,199,000đ\nper year',
          selected: _plan == 'yearly',
          onTap: () => setState(() => _plan = 'yearly'),
        ),
        const SizedBox(height: 12),
        _planCard(
          title: 'MONTHLY',
          price: '150,000đ\nper month',
          selected: _plan == 'monthly',
          dim: true,
          onTap: () => setState(() => _plan = 'monthly'),
        ),
      ],
    );
  }

  Widget _planCard({
    String? tag,
    required String title,
    String? subtitle,
    required String price,
    required bool selected,
    required VoidCallback onTap,
    bool dim = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: (!selected && dim) ? 0.3 : 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _yearlyFill : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? _blue : _border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: _itemText),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(subtitle, style: _itemTitle),
                        ],
                      ],
                    ),
                  ),
                  Text(price, textAlign: TextAlign.right, style: _itemText),
                ],
              ),
            ),
          ),
          if (tag != null) _tag(tag),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Positioned(
      top: -10,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ===== CONTINUE =====
  Widget _continueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _blue,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }

  // ===== FOOTER =====
  Widget _footer(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Auto-renews yearly unless canceled.',
          style: TextStyle(fontSize: 12, color: _textMuted),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
              ),
              child: const Text(
                'Terms of Use',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  color: _textMuted,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  color: _textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'With a subscription, you can get unlimited access to all paid '
          'content of Care AI. Subscriptions are managed by Google Play '
          'Billing and will renew automatically unless canceled at least '
          '24 hours before the current period ends. After purchase, you '
          'can manage your subscriptions in your Account Settings.',
          style: TextStyle(
            fontSize: 11,
            color: _textMuted,
          ),
        ),
      ],
    );
  }

  // ===== REUSABLE =====
  Widget _circleIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Alignment align,
  }) {
    return Align(
      alignment: align,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black12,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: 18),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _pill({
    required String text,
    required Alignment align,
  }) {
    return Align(
      alignment: align,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromARGB(31, 96, 95, 95),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

// ===== FEATURE ITEM =====
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? tail;

  const _FeatureItem({
    required this.icon,
    required this.title,
    this.tail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                if (tail != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    tail!,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
