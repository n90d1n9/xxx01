import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_branch_focus_preview_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_dependency_service.dart';
import 'package:kaysir/features/project_management/gantt/services/gantt_schedule_health_service.dart';
import 'package:kaysir/features/project_management/gantt/widgets/gantt_branch_attention_section.dart';

void main() {
  testWidgets('gantt branch attention section exposes local actions', (
    tester,
  ) async {
    var dependencyToggleCount = 0;
    var attentionToggleCount = 0;
    String? selectedTaskId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GanttBranchAttentionSection(
              preview: _preview,
              isExpanded: false,
              isDependencyFocused: false,
              onToggleDependencyFocus: () => dependencyToggleCount += 1,
              onToggleAttentionItems: () => attentionToggleCount += 1,
              onTaskSelected: (taskId) => selectedTaskId = taskId,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Branch Attention'), findsOneWidget);
    expect(find.text('Top 2'), findsOneWidget);
    expect(find.text('1 dependency risk'), findsOneWidget);
    expect(find.text('1 more in branch'), findsOneWidget);
    expect(find.text('Blocked Work'), findsOneWidget);
    expect(find.text('Active Work'), findsOneWidget);
    expect(find.text('Complete Work'), findsNothing);
    expect(
      find.byTooltip('Show only dependency attention items'),
      findsOneWidget,
    );
    expect(find.byTooltip('Show every branch attention item'), findsOneWidget);
    expect(find.byTooltip('Inspect Blocked Work'), findsOneWidget);

    await tester.tap(
      find.byKey(GanttBranchAttentionSection.dependencyFocusButtonKey),
    );
    await tester.tap(
      find.byKey(GanttBranchAttentionSection.showAllAttentionButtonKey),
    );
    await tester.tap(
      find.byKey(GanttBranchAttentionSection.attentionItemKey('blocked')),
    );
    await tester.pump();

    expect(dependencyToggleCount, 1);
    expect(attentionToggleCount, 1);
    expect(selectedTaskId, 'blocked');
  });

  testWidgets('gantt branch attention section can render expanded state', (
    tester,
  ) async {
    var attentionToggleCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttBranchAttentionSection(
            preview: _expandedPreview,
            isExpanded: true,
            isDependencyFocused: true,
            onToggleDependencyFocus: null,
            onToggleAttentionItems: () => attentionToggleCount += 1,
            onTaskSelected: null,
          ),
        ),
      ),
    );

    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('Show Less'), findsOneWidget);
    expect(find.byTooltip('Collapse branch attention list'), findsOneWidget);
    expect(find.byTooltip('Inspect Blocked Work'), findsNothing);

    await tester.tap(
      find.byKey(GanttBranchAttentionSection.showLessAttentionButtonKey),
    );
    await tester.pump();

    expect(attentionToggleCount, 1);
  });
}

final _preview = GanttBranchFocusPreview(
  items: [_blockedItem, _activeItem],
  totalItemCount: 3,
  dependencyAlertCount: 1,
  waitingDependencyCount: 0,
);

final _expandedPreview = GanttBranchFocusPreview(
  items: [_blockedItem, _activeItem],
  totalItemCount: 2,
  dependencyAlertCount: 1,
  waitingDependencyCount: 0,
);

const _blockedItem = GanttBranchFocusPreviewItem(
  taskId: 'blocked',
  title: 'Blocked Work',
  progress: 0.1,
  health: GanttScheduleHealth.scheduled,
  scheduleDetail: 'Starts in 12 days',
  dependencyHealth: GanttDependencyHealth.blocked,
  dependencyDetail: 'Upstream is incomplete and now blocks this task.',
);

const _activeItem = GanttBranchFocusPreviewItem(
  taskId: 'active',
  title: 'Active Work',
  progress: 0.4,
  health: GanttScheduleHealth.active,
  scheduleDetail: '2 days remaining',
  dependencyHealth: GanttDependencyHealth.independent,
  dependencyDetail: 'No predecessor blocks this task.',
);
