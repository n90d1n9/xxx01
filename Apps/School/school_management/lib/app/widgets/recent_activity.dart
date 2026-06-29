import 'package:flutter/material.dart';

class RecenTActivity extends StatelessWidget {
  const RecenTActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            FilledButton.tonal(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < 5; i++)
                _buildActivityItem(
                  context,
                  date: 'Mar ${15 - i}, 2025',
                  title:
                      i == 0
                          ? 'New user registered'
                          : i == 1
                          ? 'Order #2458 completed'
                          : i == 2
                          ? 'Payment received'
                          : i == 3
                          ? 'New product added'
                          : 'Customer feedback received',
                  description:
                      i == 0
                          ? 'John Smith created a new account'
                          : i == 1
                          ? 'Order was delivered and marked as completed'
                          : i == 2
                          ? 'Payment of \$1,250 was received for invoice #INV-2023'
                          : i == 3
                          ? 'Admin added a new product "Wireless Earbuds"'
                          : 'Alex Johnson left a 5-star review',
                  icon:
                      i == 0
                          ? Icons.person_add_outlined
                          : i == 1
                          ? Icons.check_circle_outline
                          : i == 2
                          ? Icons.payments_outlined
                          : i == 3
                          ? Icons.add_box_outlined
                          : Icons.star_border,
                  color:
                      i == 0
                          ? Colors.green
                          : i == 1
                          ? Colors.blue
                          : i == 2
                          ? Colors.purple
                          : i == 3
                          ? Colors.orange
                          : Colors.amber,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String date,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(date, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
