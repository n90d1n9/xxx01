import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Comment extends StatelessWidget {
  final String text;
  final String author;
  final DateTime timestamp;
  final VoidCallback? onDelete;

  const Comment({
    super.key,
    required this.text,
    required this.author,
    required this.timestamp,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, y HH:mm').format(timestamp),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 16),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(text),
          ],
        ),
      ),
    );
  }
}
