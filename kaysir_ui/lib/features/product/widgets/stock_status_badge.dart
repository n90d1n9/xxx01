import 'package:flutter/material.dart';

enum StockStatus { inStock, limited, low }

class StockStatusBadge extends StatelessWidget {
  final StockStatus status;

  const StockStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case StockStatus.inStock:
        color = Colors.green;
        label = 'In Stock';
        break;
      case StockStatus.limited:
        color = Colors.orange;
        label = 'Limited';
        break;
      case StockStatus.low:
        color = Colors.red;
        label = 'Low Stock';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
