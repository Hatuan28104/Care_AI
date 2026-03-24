import 'package:flutter/material.dart';
import 'package:Care_AI/models/tr.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.onBack,
  });

  static const Color _blue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack ?? () => Navigator.pop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.arrow_back_ios_new, size: 18, color: _blue),
                  SizedBox(width: 4),
                  _BackText(),
                ],
              ),
            ),
          if (showBack) const SizedBox(height: 12),
          Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackText extends StatelessWidget {
  const _BackText();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.tr.back,
      style: const TextStyle(fontSize: 15, color: AppHeader._blue),
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const Color _blue = Color(0xFF1877F2);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: _blue,
        inactiveTrackColor: Colors.grey.shade300,
        inactiveThumbColor: Colors.white,
      ),
    );
  }
}
