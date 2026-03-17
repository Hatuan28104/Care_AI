import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = "OK",
  String cancelText = "Cancel",
  Color confirmColor = Colors.red,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: confirmColor, width: 4),
                ),
                child: Icon(Icons.priority_high, color: confirmColor),
              ),
              const SizedBox(height: 14),

              /// 🔹 TITLE (dynamic)
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              /// 🔹 MESSAGE (dynamic)
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 16),

              /// 🔹 CONFIRM
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor.withOpacity(0.2),
                    elevation: 0,
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      color: confirmColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// 🔹 CANCEL
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xD1D1D3D9),
                    elevation: 0,
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 71, 71, 71),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}