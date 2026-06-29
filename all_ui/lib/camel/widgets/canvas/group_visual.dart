import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/node.dart';
import '../../models/canvas_transform.dart';
import '../../models/node_group.dart';
import '../../states/node_route_provider.dart';
import '../../states/select_route_provider.dart';

class GroupVisual extends ConsumerWidget {
  final NodeGroup group;
  final WNode route;
  final CanvasTransform transform;
  final bool isSelected;

  const GroupVisual({
    super.key,
    required this.group,
    required this.route,
    required this.transform,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupNodes =
        route.nodes.where((n) => group.nodeIds.contains(n.id)).toList();
    if (groupNodes.isEmpty) return const SizedBox.shrink();

    // Calculate group bounds
    final bounds = group.calculateBounds(groupNodes);
    final screenBounds = Rect.fromLTWH(
      _canvasToScreen(Offset(bounds.left, bounds.top), transform).dx,
      _canvasToScreen(Offset(bounds.left, bounds.top), transform).dy,
      bounds.width * transform.scale,
      bounds.height * transform.scale,
    );

    return Stack(
      children: [
        // Group header (draggable area)
        Positioned(
          left: screenBounds.left - 10,
          top: screenBounds.top - 30,
          child: GestureDetector(
            onTap: () {
              ref.read(routesProvider.notifier).selectGroup(group.id);
            },
            onSecondaryTapDown: (details) {
              _showGroupHeaderContextMenu(
                context,
                details.globalPosition,
                group,
                ref,
              );
            },
            child: Container(
              width: screenBounds.width + 20,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.orange : group.color.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.drag_indicator,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    // Add Expanded to prevent text overflow
                    child: Text(
                      group.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for long names
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${groupNodes.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Group header (draggable area)
        Positioned(
          left: screenBounds.left - 10,
          top: screenBounds.top - 30,
          child: GestureDetector(
            onTap: () {
              ref.read(routesProvider.notifier).selectGroup(group.id);
            },
            onSecondaryTapDown: (details) {
              _showGroupHeaderContextMenu(
                context,
                details.globalPosition,
                group,
                ref,
              );
            },
            child: Container(
              width: screenBounds.width + 20,
              height: 24,
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.orange : group.color.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(Icons.drag_indicator, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${groupNodes.length} nodes',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showGroupHeaderContextMenu(
    BuildContext context,
    Offset globalPosition,
    NodeGroup group,
    WidgetRef ref,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: [
        PopupMenuItem(
          child: const Text('Rename Group'),
          onTap: () {
            _showRenameGroupDialog(context, group, ref);
          },
        ),
        PopupMenuItem(
          child: const Text('Ungroup'),
          onTap: () {
            ref.read(routesProvider.notifier).ungroup(group.id);
          },
        ),
        PopupMenuItem(
          child: const Text(
            'Delete Group and Nodes',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            // Delete all nodes in the group first
            ref
                .read(routesProvider.notifier)
                .deleteNodesFromRoute(
                  ref.read(selectedRouteProvider)!.id,
                  group.nodeIds.toSet(),
                );
            // Then remove the group
            ref.read(routesProvider.notifier).ungroup(group.id);
          },
        ),
      ],
    );
  }

  void _showRenameGroupDialog(
    BuildContext context,
    NodeGroup group,
    WidgetRef ref,
  ) {
    final textController = TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename Group'),
            content: TextField(
              controller: textController,
              decoration: const InputDecoration(hintText: 'Enter group name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final updatedGroup = group.copyWith(
                    name: textController.text,
                  );
                  ref
                      .read(routesProvider.notifier)
                      .updateGroup(group.id, updatedGroup);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Offset _canvasToScreen(Offset canvasPos, CanvasTransform transform) {
    return canvasPos * transform.scale + transform.offset;
  }
}
