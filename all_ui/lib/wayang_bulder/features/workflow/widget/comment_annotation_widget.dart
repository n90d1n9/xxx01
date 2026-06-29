import 'package:flutter/material.dart';

import '../components/comment/comment_annotation.dart';

class CommentAnnotationWidget extends StatelessWidget {
  final CommentAnnotation annotation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommentAnnotationWidget({
    super.key,
    required this.annotation,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: annotation.position.dx,
      top: annotation.position.dy,
      child: Container(
        width: annotation.width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: annotation.color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.comment, color: Colors.white, size: 16),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              annotation.text,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
