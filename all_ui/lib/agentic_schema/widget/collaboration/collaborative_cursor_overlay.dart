import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/canvas_provider.dart';
import '../../state/collaboration_provider.dart';
import '../../state/workflow/workflow_provider.dart';
import 'collaborative_cursor.dart';

class CollaborativeCursorsOverlay extends ConsumerWidget {
  const CollaborativeCursorsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workflowState = ref.watch(workflowProvider);
    if (workflowState.currentWorkflow == null) return const SizedBox.shrink();

    final collaborationState = ref.watch(
      collaborationProvider(workflowState.currentWorkflow!.id),
    );
    final canvasState = ref.watch(canvasProvider);

    final activeUsers = collaborationState.users.values.where(
      (user) =>
          user.cursorPosition != null &&
          user.lastSeen.isAfter(
            DateTime.now().subtract(const Duration(seconds: 5)),
          ),
    );

    return Stack(
      children: activeUsers.map((user) {
        final screenPos = canvasState.canvasToScreen(user.cursorPosition!);

        // Check if cursor is within visible area
        final isVisible =
            screenPos.dx >= 0 &&
            screenPos.dy >= 0 &&
            screenPos.dx <= MediaQuery.of(context).size.width &&
            screenPos.dy <= MediaQuery.of(context).size.height;

        if (!isVisible) return const SizedBox.shrink();

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 100),
          left: screenPos.dx,
          top: screenPos.dy,
          child: CollaborativeCursor(user: user),
        );
      }).toList(),
    );
  }
}
