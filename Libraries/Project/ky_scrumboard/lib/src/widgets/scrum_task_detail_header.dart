import 'package:flutter/material.dart';

import '../../models/scrum_task.dart';
import '../scrum_board_palette.dart';

class ScrumTaskDetailHeader extends StatelessWidget {
  const ScrumTaskDetailHeader({
    super.key,
    required this.task,
    required this.onClose,
  });

  final ScrumTask task;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: ScrumBoardPalette.ink,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Close task details',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
