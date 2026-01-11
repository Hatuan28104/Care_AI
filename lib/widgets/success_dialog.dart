import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirm;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirm,
  });

  /// ===== SHOW =====
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    Duration autoClose = const Duration(seconds: 2), // ✅ 2s
    VoidCallback? onConfirm,
  }) async {
    bool closed = false;

    // show dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'success',
      barrierColor: Colors.black.withOpacity(0.55),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Center(
          child: SuccessDialog(
            title: title,
            message: message,
            onConfirm: () {
              if (closed) return;
              closed = true;
              Navigator.of(context).pop();
              onConfirm?.call();
            },
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final scale = 0.9 + (0.1 * anim.value);
        return Transform.scale(
          scale: scale,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );

    // ===== AUTO CLOSE =====
    await Future.delayed(autoClose);
    if (context.mounted && !closed) {
      closed = true;
      Navigator.of(context).pop();
      onConfirm?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF000000);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onConfirm, // ✅ bấm popup là tắt
        child: Container(
          width: 360,
          height: 260,
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== ICON =====
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1877F2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // ===== TITLE =====
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: black,
                ),
              ),

              const SizedBox(height: 20),

              // ===== MESSAGE =====
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
