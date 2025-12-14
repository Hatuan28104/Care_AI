import 'package:flutter/material.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;

  const SuccessDialog({
    super.key,
    required this.title,
    this.message = 'Wish you have an experience\nwith the application',
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    String message = 'Wish you have an experience\nwith the application',
    Duration autoClose = const Duration(seconds: 2),
    VoidCallback? onClosed,
  }) async {
    // show dialog
    unawaited(
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'success',
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) {
          return Center(
            child: SuccessDialog(title: title, message: message),
          );
        },
        transitionBuilder: (_, anim, __, child) {
          final t = Curves.easeOut.transform(anim.value);
          return Transform.scale(
            scale: 0.96 + (0.04 * t),
            child: Opacity(opacity: anim.value, child: child),
          );
        },
      ),
    );

    // auto close
    await Future.delayed(autoClose);
    if (context.mounted) Navigator.of(context).pop();

    onClosed?.call();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF21B14B);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: green, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.check_rounded, color: green, size: 34),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// helper để khỏi warning unawaited
void unawaited(Future<void> f) {}
