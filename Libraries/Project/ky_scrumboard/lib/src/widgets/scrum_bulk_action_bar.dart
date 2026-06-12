import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_priority.dart';
import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'bulk_action_buttons.dart';
import 'bulk_selection_summary.dart';

/// Floating toolbar for applying actions to the current task selection.
class ScrumBulkActionBar extends StatelessWidget {
  const ScrumBulkActionBar({
    super.key,
    required this.selectedCount,
    required this.statuses,
    required this.statusLabelFor,
    required this.onMoveToStatus,
    required this.onPriorityChanged,
    required this.onDelete,
    required this.onClearSelection,
  });

  final int selectedCount;
  final List<ScrumTaskStatus> statuses;
  final String Function(ScrumTaskStatus status) statusLabelFor;
  final ValueChanged<ScrumTaskStatus> onMoveToStatus;
  final ValueChanged<ScrumTaskPriority> onPriorityChanged;
  final VoidCallback onDelete;
  final VoidCallback onClearSelection;

  @override
  Widget build(BuildContext context) {
    if (selectedCount <= 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: const Color(0xFF2563EB).withValues(alpha: .2),
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BulkSelectionSummary(
              selectedCount: selectedCount,
              onClearSelection: onClearSelection,
            ),
            BulkStatusMenuButton(
              statuses: statuses,
              statusLabelFor: statusLabelFor,
              onMoveToStatus: onMoveToStatus,
            ),
            BulkPriorityMenuButton(onPriorityChanged: onPriorityChanged),
            BulkDeleteButton(onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

/// Preview for the complete bulk action bar.
@Preview(group: 'Ky Scrumboard', name: 'Bulk action bar', size: Size(820, 140))
Widget scrumBulkActionBarPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: ScrumBulkActionBar(
          selectedCount: 3,
          statuses: const [
            ScrumTaskStatus.todo,
            ScrumTaskStatus.inProgress,
            ScrumTaskStatus.review,
            ScrumTaskStatus.done,
          ],
          statusLabelFor: (status) => status.label,
          onMoveToStatus: (_) {},
          onPriorityChanged: (_) {},
          onDelete: () {},
          onClearSelection: () {},
        ),
      ),
    ),
  );
}
