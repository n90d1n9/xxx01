// Add this to your main widget or a dedicated shortcut handler
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../states/node_group_provider.dart';
import '../../states/node_route_provider.dart';
import '../../states/provider.dart';
import '../../states/select_route_provider.dart';

class CanvasShortcuts extends ConsumerWidget {
  final Widget child;
  final FocusNode focusNode;

  const CanvasShortcuts({
    super.key,
    required this.child,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      focusNode: focusNode, // Use the provided focusNode here
      autofocus: true,
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          // Select all nodes in current group
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA):
              const SelectAllInGroupIntent(),
          // Deselect all
          LogicalKeySet(LogicalKeyboardKey.escape): const DeselectAllIntent(),
          // Select entire group
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyG):
              const SelectGroupIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            SelectAllInGroupIntent: CallbackAction<SelectAllInGroupIntent>(
              onInvoke: (intent) => _handleSelectAllInGroup(ref),
            ),
            DeselectAllIntent: CallbackAction<DeselectAllIntent>(
              onInvoke: (intent) => _handleDeselectAll(ref),
            ),
            SelectGroupIntent: CallbackAction<SelectGroupIntent>(
              onInvoke: (intent) => _handleSelectGroup(ref),
            ),
          },
          child: child,
        ),
      ),
    );
  }

  void _handleSelectAllInGroup(WidgetRef ref) {
    final selectedGroupId = ref.read(selectedGroupIdProvider);
    if (selectedGroupId != null) {
      final groups = ref.read(nodeGroupsProvider);
      final group = groups.firstWhere((g) => g.id == selectedGroupId);
      ref.read(selectedNodesProvider.notifier).state = group.nodeIds.toSet();
    }
  }

  void _handleDeselectAll(WidgetRef ref) {
    ref.read(selectedNodeIdProvider.notifier).state = null;
    ref.read(selectedNodesProvider.notifier).state = {};
    ref.read(selectedGroupIdProvider.notifier).state = null;
  }

  void _handleSelectGroup(WidgetRef ref) {
    final selectedNodeIds = ref.read(selectedNodesProvider);
    if (selectedNodeIds.isNotEmpty) {
      final route = ref.read(selectedRouteProvider);
      final node = route?.nodes.firstWhere(
        (n) => selectedNodeIds.contains(n.id),
        orElse: () => route.nodes.first,
      );
      if (node?.groupId != null) {
        ref.read(routesProvider.notifier).selectGroup(node!.groupId!);
      }
    }
  }
}

// Intent classes
class SelectAllInGroupIntent extends Intent {
  const SelectAllInGroupIntent();
}

class DeselectAllIntent extends Intent {
  const DeselectAllIntent();
}

class SelectGroupIntent extends Intent {
  const SelectGroupIntent();
}
