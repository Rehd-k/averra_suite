import 'package:flutter/material.dart';

class EmptyComponent extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;
  final Function reload;
  const EmptyComponent({
    super.key,
    required this.icon,
    required this.message,
    required this.reload,
    required this.subMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Nice professional icon
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, // 👈 professional finance/expenses icon
              size: 30,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 24),
          // Main title
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          // Sub text
          Text(
            subMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 24),
          // Call to action button
          ElevatedButton.icon(
            onPressed: () {
              reload();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.refresh_outlined, size: 12),
            label: const Text(
              "Reload ?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
