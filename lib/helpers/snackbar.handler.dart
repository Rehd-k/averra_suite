import 'package:flutter/material.dart';

enum SnackBarType { error, success, normal }

void showBeautifulSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
  SnackBarType type = SnackBarType.normal,
}) {
  final Color? glowBase = switch (type) {
    SnackBarType.error => Colors.redAccent,
    SnackBarType.success => Colors.greenAccent,
    SnackBarType.normal => null,
  };

  final List<BoxShadow> shadows = [
    const BoxShadow(
      color: Colors.black26,
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
    if (glowBase != null)
      BoxShadow(
        color: glowBase.withOpacity(0.22),
        blurRadius: 24,
        spreadRadius: 1,
        offset: const Offset(0, 0),
      ),
  ];

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    padding: EdgeInsets.zero,
    duration: duration,
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: shadows,
        border: Border.all(
          color: glowBase != null
              ? glowBase.withOpacity(0.18)
              : Theme.of(context).dividerColor.withOpacity(0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                if (onAction != null) onAction();
              },
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
