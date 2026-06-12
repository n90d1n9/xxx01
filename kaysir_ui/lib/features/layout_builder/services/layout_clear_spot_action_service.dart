import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/layout_state_provider.dart';
import '../utils/layout_clear_spot_labels.dart';

/// Runs layout clear-spot moves and reports consistent user-facing feedback.
class LayoutClearSpotActionService {
  const LayoutClearSpotActionService();

  bool moveSelectionToClearSpot(
    BuildContext context,
    WidgetRef ref, {
    String subject = 'selection',
  }) {
    final layoutState = ref.read(layoutStateProvider);
    final notifier = ref.read(layoutStateProvider.notifier);
    final clearSpotAction = LayoutClearSpotActionState.fromSelection(
      hasSelection: layoutState.hasSelection,
      preview: notifier.selectedConflictResolutionPreview(),
    );
    final moved = notifier.resolveSelectedConflict();
    final message =
        moved
            ? clearSpotAction.movedStatusLabel(subject: subject)
            : clearSpotAction.unavailableStatusLabel;

    _showStatus(context, message);
    return moved;
  }

  void _showStatus(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

const layoutClearSpotActionService = LayoutClearSpotActionService();
