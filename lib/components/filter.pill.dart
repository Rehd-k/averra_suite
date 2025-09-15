import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final String selected;
  final List menuList;
  final Function doSelect;
  final IconData pillIcon;
  const CategoryDropdown({
    super.key,
    required this.selected,
    required this.menuList,
    required this.doSelect,
    required this.pillIcon,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        doSelect(value);
      },
      itemBuilder: (context) => menuList
          .map(
            (item) => PopupMenuItem(
              value: item['title'] as String,
              child: Text(item['title']),
            ),
          )
          .toList(),
      offset: const Offset(0, 40), // dropdown below button
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // pill shape
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onPressed: null, // handled by PopupMenuButton
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(pillIcon, size: 10),
            const SizedBox(width: 6),
            Text(selected, style: const TextStyle(fontSize: 10)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_drop_down, size: 10),
          ],
        ),
      ),
    );
  }
}
