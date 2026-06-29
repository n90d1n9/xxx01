import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/node_card.dart';
import '../models/node_group.dart';
import '../states/node_group_provider.dart';
import '../states/provider.dart';
import '../states/node_route_provider.dart';
import '../states/select_route_provider.dart';

class NodeWidget extends ConsumerStatefulWidget {
  final NodeCard node;
  final String routeId;
  final bool isSelected;
  final bool isConnecting;
  final bool isGroupSelected;
  final Function(NodeCard)? onTap;

  const NodeWidget({
    super.key,
    required this.node,
    required this.routeId,
    required this.isSelected,
    required this.isConnecting,
    this.isGroupSelected = false,
    this.onTap,
  });

  @override
  ConsumerState<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends ConsumerState<NodeWidget> {
  Offset? dragOffset;

  void _handleConnect() {
    // Clear any existing group selection when connecting
    ref.read(selectedGroupIdProvider.notifier).state = null;

    // Set this node as the connecting node
    ref.read(connectingNodeIdProvider.notifier).state = widget.node.id;

    // Also select this node individually
    ref.read(selectedNodeIdProvider.notifier).state = widget.node.id;
    ref.read(selectedNodesProvider.notifier).state = {widget.node.id};
  }

  void _handleNodeTap() {
    final connectingId = ref.read(connectingNodeIdProvider);
    if (connectingId != null) {
      // Clear group selection when making connections
      ref.read(selectedGroupIdProvider.notifier).state = null;

      // Connect nodes
      if (connectingId != widget.node.id) {
        ref
            .read(routesProvider.notifier)
            .connectNodes(widget.routeId, connectingId, widget.node.id);
      }
      ref.read(connectingNodeIdProvider.notifier).state = null;
    } else {
      // Handle node selection with modifier keys
      if (widget.onTap != null) {
        // Use the parent's tap handler for group selection logic
        widget.onTap!(widget.node);
      } else {
        // Fallback to basic selection
        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

        if (isCtrlPressed) {
          // Ctrl+Click: Toggle selection
          final currentSelection = ref.read(selectedNodesProvider);
          final newSelection = Set<String>.from(currentSelection);
          if (newSelection.contains(widget.node.id)) {
            newSelection.remove(widget.node.id);
          } else {
            newSelection.add(widget.node.id);
          }
          ref.read(selectedNodesProvider.notifier).state = newSelection;
          ref.read(selectedGroupIdProvider.notifier).state = null;
        } else if (isShiftPressed) {
          // Shift+Click: Add to selection
          final currentSelection = ref.read(selectedNodesProvider);
          final newSelection = Set<String>.from(currentSelection)
            ..add(widget.node.id);
          ref.read(selectedNodesProvider.notifier).state = newSelection;
          ref.read(selectedGroupIdProvider.notifier).state = null;
        } else {
          // Regular click: Select single node
          ref.read(selectedNodeIdProvider.notifier).state = widget.node.id;
          ref.read(selectedNodesProvider.notifier).state = {widget.node.id};
          ref.read(selectedGroupIdProvider.notifier).state = null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        // Ensure the node is selected when starting to drag
        if (!widget.isSelected) {
          ref.read(selectedNodeIdProvider.notifier).state = widget.node.id;
          ref.read(selectedNodesProvider.notifier).state = {widget.node.id};
          ref.read(selectedGroupIdProvider.notifier).state = null;
        }
      },
      onPanUpdate: (details) {
        final delta = details.delta;

        // Get current selection to handle multi-drag
        final selectedNodeIds = ref.read(selectedNodesProvider);
        final selectedGroupId = ref.read(selectedGroupIdProvider);

        if (selectedGroupId != null && widget.node.groupId == selectedGroupId) {
          // Move entire group
          ref
              .read(routesProvider.notifier)
              .moveGroup(widget.routeId, selectedGroupId, delta);
        } else if (selectedNodeIds.length > 1 &&
            selectedNodeIds.contains(widget.node.id)) {
          // Move multiple selected nodes
          ref
              .read(routesProvider.notifier)
              .moveNodes(widget.routeId, selectedNodeIds, delta);
        } else {
          // Move single node
          final newNode = widget.node.copyWith(
            position: widget.node.position + delta,
          );
          ref
              .read(routesProvider.notifier)
              .updateNodeInRoute(widget.routeId, widget.node.id, newNode);
        }
      },
      onTap: _handleNodeTap,
      onSecondaryTapDown: (details) {
        // Handle right-click context menu
        _showNodeContextMenu(context, details.globalPosition);
      },
      child: AnimatedScale(
        scale: widget.isSelected || widget.isGroupSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color:
                widget.isGroupSelected
                    ? widget.node.color.withOpacity(0.3)
                    : (widget.isSelected
                        ? widget.node.color.withOpacity(0.8)
                        : widget.node.color),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isSelected
                      ? Colors.amber
                      : (widget.isGroupSelected
                          ? widget.node.color
                          : Colors.transparent),
              width: widget.isSelected ? 3 : (widget.isGroupSelected ? 2 : 0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Group indicator badge
                    if (widget.node.groupId != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Group',
                          style: TextStyle(
                            color: widget.node.color,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    Icon(
                      widget.node.icon,
                      color:
                          widget.isGroupSelected
                              ? widget.node.color
                              : Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.node.name,
                      style: TextStyle(
                        color:
                            widget.isGroupSelected
                                ? widget.node.color
                                : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.node.config.values.first.toString(),
                      style: TextStyle(
                        color:
                            widget.isGroupSelected
                                ? widget.node.color.withOpacity(0.8)
                                : Colors.white70,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.link,
                        size: 16,
                        color:
                            widget.isGroupSelected
                                ? widget.node.color
                                : Colors.white,
                      ),
                      onPressed:
                          _handleConnect, // Use the fixed connect handler
                      tooltip: 'Connect',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 16,
                        color:
                            widget.isGroupSelected
                                ? widget.node.color
                                : Colors.white,
                      ),
                      onPressed: () {
                        ref
                            .read(routesProvider.notifier)
                            .deleteNodeFromRoute(
                              widget.routeId,
                              widget.node.id,
                            );
                        if (ref.read(selectedNodeIdProvider) ==
                            widget.node.id) {
                          ref.read(selectedNodeIdProvider.notifier).state =
                              null;
                        }
                        // Also remove from selected nodes set
                        final selectedNodes = ref.read(selectedNodesProvider);
                        if (selectedNodes.contains(widget.node.id)) {
                          final newSelection = Set<String>.from(selectedNodes)
                            ..remove(widget.node.id);
                          ref.read(selectedNodesProvider.notifier).state =
                              newSelection;
                        }
                      },
                      tooltip: 'Delete',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNodeContextMenu(BuildContext context, Offset globalPosition) {
    final selectedNodes = ref.read(selectedNodesProvider);
    final selectedGroupId = ref.read(selectedGroupIdProvider);
    final groups = ref.read(nodeGroupsProvider);
    final isMultiSelected =
        selectedNodes.length > 1 && selectedNodes.contains(widget.node.id);

    // Check if we're in a group context
    final currentGroup =
        widget.node.groupId != null
            ? groups.firstWhere(
              (g) => g.id == widget.node.groupId,
              orElse:
                  () => NodeGroup(
                    id: '',
                    name: '',
                    color: Colors.transparent,
                    nodeIds: [],
                  ),
            )
            : null;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx,
        globalPosition.dy,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text('Connect'),
          onTap: () {
            ref.read(connectingNodeIdProvider.notifier).state = widget.node.id;
          },
        ),
        if (currentGroup != null) ...[
          PopupMenuItem(
            child: const Text('Remove from Group'),
            onTap: () {
              ref.read(routesProvider.notifier).removeNodesFromGroup(
                currentGroup.id,
                {widget.node.id},
              );
            },
          ),
          PopupMenuItem(
            child: const Text('Ungroup Entire Group'),
            onTap: () {
              ref.read(routesProvider.notifier).ungroup(currentGroup.id);
            },
          ),
        ],
        if (widget.node.groupId == null && selectedNodes.length > 1)
          PopupMenuItem(
            child: const Text('Create Group from Selection'),
            onTap: () {
              _showCreateGroupDialog(context, selectedNodes);
            },
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: () {
            if (isMultiSelected) {
              // Delete all selected nodes
              ref
                  .read(routesProvider.notifier)
                  .deleteNodesFromRoute(widget.routeId, selectedNodes);
              ref.read(selectedNodesProvider.notifier).state = {};
            } else {
              // Delete single node
              ref
                  .read(routesProvider.notifier)
                  .deleteNodeFromRoute(widget.routeId, widget.node.id);
            }
            ref.read(selectedNodeIdProvider.notifier).state = null;
          },
        ),
      ],
    );
  }

  void _showCreateGroupDialog(BuildContext context, Set<String> nodeIds) {
    final textController = TextEditingController();
    final color = widget.node.color; // Use current node color as default

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create Group'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'Enter group name',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${nodeIds.length} nodes will be grouped',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    ref
                        .read(routesProvider.notifier)
                        .createGroup(
                          widget.routeId,
                          nodeIds,
                          textController.text.trim(),
                          color,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }
}
