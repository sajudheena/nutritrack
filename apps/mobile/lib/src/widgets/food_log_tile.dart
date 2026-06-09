import 'package:flutter/material.dart';
import 'package:common/common.dart';

/// A ListTile showing a food log entry with food name, grams, calories,
/// and a delete button.
class FoodLogTile extends StatelessWidget {
  final FoodLogEntry entry;
  final VoidCallback onDelete;

  const FoodLogTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF4CAF50),
          child: Icon(Icons.restaurant, color: Colors.white, size: 20),
        ),
        title: Text(
          entry.foodName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${entry.grams.toStringAsFixed(0)} g  •  '
          'P: ${entry.nutrients.protein.toStringAsFixed(1)} g  '
          'C: ${entry.nutrients.carbs.toStringAsFixed(1)} g  '
          'F: ${entry.nutrients.fat.toStringAsFixed(1)} g',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.nutrients.calories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: Colors.red.shade300, size: 20),
              tooltip: 'Delete entry',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
