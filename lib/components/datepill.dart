import 'package:flutter/material.dart';

class DateRangeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DateRangeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // pill shape
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.calendar_today, size: 10),
          SizedBox(width: 6),
          Text("Date Range", style: TextStyle(fontSize: 10)),
          SizedBox(width: 6),
          Icon(Icons.arrow_drop_down, size: 10),
        ],
      ),
    );
  }
}
