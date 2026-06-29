import 'package:flutter/material.dart';

class InsertableWidget {
  final String id;
  final String name;
  final IconData icon;
  final String category;
  final Color color;

  InsertableWidget(this.id, this.name, this.icon, this.category, this.color);
}

class _WidgetCard extends StatelessWidget {
  final InsertableWidget widget;
  final VoidCallback onTap;

  const _WidgetCard({required this.widget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              widget.name,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
