import 'package:flutter/material.dart';

import '../../model/collaborative_user.dart';

class CollaborativeCursor extends StatelessWidget {
  final CollaborativeUser user;

  const CollaborativeCursor({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cursor icon
        Icon(Icons.mouse, color: user.color, size: 20),

        // User label with selection info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: user.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.selectedNodeIds != null &&
                  user.selectedNodeIds!.isNotEmpty)
                Text(
                  '${user.selectedNodeIds!.length} selected',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),

        // Selection highlight (if user has selected nodes)
        if (user.selectedNodeIds != null && user.selectedNodeIds!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: user.color.withOpacity(0.1),
              border: Border.all(color: user.color.withOpacity(0.5), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '👆 ${user.selectedNodeIds!.length}',
              style: TextStyle(
                color: user.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
