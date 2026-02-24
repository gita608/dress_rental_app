import 'package:flutter/material.dart';
import '../models/models.dart';

class StatusBadge extends StatelessWidget {
  final dynamic status; // Can be DressStatus or BookingStatus

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData? icon;

    if (status is DressStatus) {
      switch (status as DressStatus) {
        case DressStatus.available:
          color = Colors.green;
          label = 'Available';
          icon = Icons.check_circle_outline;
          break;
        case DressStatus.rented:
          color = Colors.orange;
          label = 'Rented';
          icon = Icons.shopping_bag_outlined;
          break;
        case DressStatus.cleaning:
          color = Colors.blue;
          label = 'Cleaning';
          icon = Icons.wash_outlined;
          break;
        case DressStatus.repair:
          color = Colors.red;
          label = 'Repair';
          icon = Icons.build_circle_outlined;
          break;
        case DressStatus.outOfStock:
          color = Colors.red;
          label = 'Out of Stock';
          icon = Icons.warning_amber_rounded;
          break;
      }
    } else if (status is BookingStatus) {
      switch (status as BookingStatus) {
        case BookingStatus.pending:
          color = Colors.orange;
          label = 'Pending';
          break;
        case BookingStatus.active:
          color = Colors.green;
          label = 'Active';
          break;
        case BookingStatus.completed:
          color = Colors.grey;
          label = 'Completed';
          break;
      }
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.zero,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
