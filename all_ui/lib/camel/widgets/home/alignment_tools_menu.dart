import 'package:flutter/material.dart';
import '../../services/alignment_tools.dart';

class AlignmentToolsMenu extends StatelessWidget {
  final Function(AlignmentType) onAlignment;

  const AlignmentToolsMenu({super.key, required this.onAlignment});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AlignmentType>(
      icon: const Icon(Icons.align_horizontal_left),
      tooltip: 'Align Nodes',
      onSelected: onAlignment,
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: AlignmentType.left,
              child: Row(
                children: [
                  Icon(Icons.align_horizontal_left, size: 18),
                  SizedBox(width: 8),
                  Text('Align Left'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: AlignmentType.right,
              child: Row(
                children: [
                  Icon(Icons.align_horizontal_right, size: 18),
                  SizedBox(width: 8),
                  Text('Align Right'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: AlignmentType.top,
              child: Row(
                children: [
                  Icon(Icons.align_vertical_top, size: 18),
                  SizedBox(width: 8),
                  Text('Align Top'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: AlignmentType.bottom,
              child: Row(
                children: [
                  Icon(Icons.align_vertical_bottom, size: 18),
                  SizedBox(width: 8),
                  Text('Align Bottom'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: AlignmentType.centerH,
              child: Row(
                children: [
                  Icon(Icons.horizontal_rule, size: 18),
                  SizedBox(width: 8),
                  Text('Center Horizontally'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: AlignmentType.centerV,
              child: Row(
                children: [
                  Icon(Icons.more_vert, size: 18),
                  SizedBox(width: 8),
                  Text('Center Vertically'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: AlignmentType.distributeH,
              child: Row(
                children: [
                  Icon(Icons.space_bar, size: 18),
                  SizedBox(width: 8),
                  Text('Distribute Horizontally'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: AlignmentType.distributeV,
              child: Row(
                children: [
                  Icon(Icons.view_headline, size: 18),
                  SizedBox(width: 8),
                  Text('Distribute Vertically'),
                ],
              ),
            ),
          ],
    );
  }
}
