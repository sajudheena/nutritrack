import 'package:flutter/material.dart';

/// A labeled progress bar showing [current] vs [target] for a nutrient.
///
/// Color codes:
///   - >= 100% of target → red (over target)
///   - >= 75% of target  → amber
///   - otherwise         → green
class NutrientProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;

  const NutrientProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    this.unit = 'g',
  });

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = target > 0 ? (current / target * 100).round() : 0;

    final Color barColor;
    if (percentage >= 100) {
      barColor = Colors.red.shade400;
    } else if (percentage >= 75) {
      barColor = Colors.amber.shade600;
    } else {
      barColor = Colors.green.shade500;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} $unit  ($percentage%)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
