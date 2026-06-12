import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../models/scrum_task_status.dart';
import '../scrum_board_palette.dart';
import 'board_lane_callbacks.dart';

/// Surface that wraps visible board lanes with bulk expand and collapse actions.
class BoardLaneSurface extends StatelessWidget {
  const BoardLaneSurface({
    super.key,
    required this.statuses,
    required this.collapsedStatuses,
    required this.onCollapsedChanged,
    required this.child,
  });

  final List<ScrumTaskStatus> statuses;
  final Set<ScrumTaskStatus> collapsedStatuses;
  final ScrumVisibleColumnsCollapseChanged onCollapsedChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BoardLaneActions(
          statuses: statuses,
          collapsedStatuses: collapsedStatuses,
          onCollapsedChanged: onCollapsedChanged,
        ),
        const SizedBox(height: 10),
        Expanded(child: child),
      ],
    );
  }
}

/// Preview for the board lane surface and bulk collapse controls.
@Preview(group: 'Ky Scrumboard', name: 'Lane surface', size: Size(620, 180))
Widget boardLaneSurfacePreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: BoardLaneSurface(
        statuses: const [
          ScrumTaskStatus.todo,
          ScrumTaskStatus.inProgress,
          ScrumTaskStatus.review,
        ],
        collapsedStatuses: const {ScrumTaskStatus.review},
        onCollapsedChanged: (_, _) {},
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ScrumBoardPalette.border),
          ),
          child: const Center(child: Text('Visible lanes')),
        ),
      ),
    ),
  );
}

/// Bulk expand and collapse controls for the visible lane set.
class BoardLaneActions extends StatelessWidget {
  const BoardLaneActions({
    super.key,
    required this.statuses,
    required this.collapsedStatuses,
    required this.onCollapsedChanged,
  });

  final List<ScrumTaskStatus> statuses;
  final Set<ScrumTaskStatus> collapsedStatuses;
  final ScrumVisibleColumnsCollapseChanged onCollapsedChanged;

  @override
  Widget build(BuildContext context) {
    final canCollapse = statuses.any(
      (status) => !collapsedStatuses.contains(status),
    );
    final canExpand = statuses.any(collapsedStatuses.contains);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton.filledTonal(
          tooltip: 'Expand visible lanes',
          visualDensity: VisualDensity.compact,
          onPressed: canExpand
              ? () => onCollapsedChanged(statuses, false)
              : null,
          icon: const Icon(Icons.unfold_more_rounded),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Collapse visible lanes',
          visualDensity: VisualDensity.compact,
          onPressed: canCollapse
              ? () => onCollapsedChanged(statuses, true)
              : null,
          icon: const Icon(Icons.unfold_less_rounded),
        ),
      ],
    );
  }
}

/// Preview for standalone lane expand and collapse actions.
@Preview(group: 'Ky Scrumboard', name: 'Lane actions', size: Size(220, 90))
Widget boardLaneActionsPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Scaffold(
      backgroundColor: ScrumBoardPalette.background,
      body: Center(
        child: BoardLaneActions(
          statuses: const [ScrumTaskStatus.todo, ScrumTaskStatus.review],
          collapsedStatuses: const {ScrumTaskStatus.review},
          onCollapsedChanged: (_, _) {},
        ),
      ),
    ),
  );
}
