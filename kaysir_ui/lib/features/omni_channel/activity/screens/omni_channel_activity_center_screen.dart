import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../widgets/ui/app_content_panel.dart';
import '../models/omni_channel_activity.dart';
import '../models/omni_channel_activity_action.dart';
import '../models/omni_channel_activity_action_execution.dart';
import '../models/omni_channel_activity_action_execution_log.dart';
import '../models/omni_channel_activity_center_query_state.dart';
import '../models/omni_channel_activity_filter.dart';
import '../models/omni_channel_activity_triage.dart';
import '../omni_channel_activity_routes.dart';
import '../states/omni_channel_activity_action_execution_controller_provider.dart';
import '../states/omni_channel_activity_action_execution_log_provider.dart';
import '../states/omni_channel_activity_action_registry_provider.dart';
import '../states/omni_channel_activity_center_filter_provider.dart';
import '../states/omni_channel_activity_provider.dart';
import '../states/omni_channel_activity_registry_diagnostics_provider.dart';
import '../widgets/omni_channel_activity_action_execution_log_panel.dart';
import '../widgets/omni_channel_activity_action_feedback.dart';
import '../widgets/omni_channel_activity_filter_bar.dart';
import '../widgets/omni_channel_activity_insight_banner.dart';
import '../widgets/omni_channel_activity_registry_diagnostics_panel.dart';
import '../widgets/omni_channel_activity_triage_queue_panel.dart';
import '../widgets/omni_channel_activity_workspace.dart';

/// Central workspace for reviewing shared POS and ecommerce activity.
class OmniChannelActivityCenterScreen extends ConsumerStatefulWidget {
  static const routePath = OmniChannelActivityRoutes.activityCenterPath;

  final OmniChannelActivityCenterQueryState? initialQueryState;
  final ValueChanged<String>? onOpenLocation;

  const OmniChannelActivityCenterScreen({
    super.key,
    this.initialQueryState,
    this.onOpenLocation,
  });

  @override
  ConsumerState<OmniChannelActivityCenterScreen> createState() =>
      _OmniChannelActivityCenterScreenState();
}

/// Keeps route query state synchronized with the activity center providers.
class _OmniChannelActivityCenterScreenState
    extends ConsumerState<OmniChannelActivityCenterScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialQueryState != null) {
      _scheduleQueryStateApply(widget.initialQueryState!);
    }
  }

  @override
  void didUpdateWidget(OmniChannelActivityCenterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQueryState != widget.initialQueryState) {
      _scheduleQueryStateApply(
        widget.initialQueryState ?? const OmniChannelActivityCenterQueryState(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(omniChannelActivityCenterFilterProvider);
    final feed = ref.watch(omniChannelActivityFeedProvider);
    final insight = ref.watch(omniChannelActivityInsightProvider);
    final counts = ref.watch(omniChannelActivityFilterCountsProvider(filter));
    final scopeOptions = ref.watch(
      omniChannelActivityScopeOptionsProvider(filter),
    );
    final triageQueue = ref.watch(
      omniChannelActivityTriageQueueProvider(filter),
    );
    final triageQueueExpanded =
        ref.watch(omniChannelActivityTriageQueueLimitProvider) == null;
    final entries = ref.watch(omniChannelFilteredActivityProvider(filter));
    final actionRegistry = ref.watch(omniChannelActivityActionRegistryProvider);
    final registryDiagnostics = ref.watch(
      omniChannelActivityRegistryDiagnosticsProvider,
    );
    final actionExecutionState = ref.watch(
      omniChannelActivityActionExecutionControllerProvider,
    );
    final actionExecutionLog = ref.watch(
      omniChannelActivityActionExecutionLogProvider,
    );
    final actionExecutionLogFilter = ref.watch(
      omniChannelActivityActionExecutionLogFilterProvider,
    );
    final selectedEntryId = ref.watch(
      omniChannelActivityCenterSelectedEntryIdProvider,
    );
    final selectedEntry = _selectedEntry(
      visibleEntries: entries,
      feedEntries: feed.entries,
      selectedEntryId: selectedEntryId,
    );
    final runningActionKeys = actionExecutionState.busyActionKeys;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Omni-channel Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;

            return SingleChildScrollView(
              padding: EdgeInsets.all(compact ? 12 : 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OmniChannelActivityInsightBanner(
                        insight: insight,
                        showNextStep: !compact,
                      ),
                      if (triageQueue.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        OmniChannelActivityTriageQueuePanel(
                          queue: triageQueue,
                          filter: filter,
                          expanded: triageQueueExpanded,
                          onGroupSelected: (group) {
                            final nextFilter = group.toFilter(filter);
                            final selectedEntryId = group.latestEntry?.id;
                            ref
                                .read(
                                  omniChannelActivityCenterFilterProvider
                                      .notifier,
                                )
                                .state = nextFilter;
                            ref
                                .read(
                                  omniChannelActivityCenterSelectedEntryIdProvider
                                      .notifier,
                                )
                                .state = selectedEntryId;
                            _openActivityLocation(
                              filter: nextFilter,
                              selectedEntryId: selectedEntryId,
                            );
                          },
                          onExpandedChanged: (expanded) {
                            ref
                                .read(
                                  omniChannelActivityTriageQueueLimitProvider
                                      .notifier,
                                )
                                .state = expanded
                                    ? null
                                    : defaultOmniChannelActivityTriageGroupLimit;
                          },
                        ),
                      ],
                      if (actionExecutionLog.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        OmniChannelActivityActionExecutionLogPanel(
                          log: actionExecutionLog,
                          filter: actionExecutionLogFilter,
                          selectedEntryId: selectedEntry?.id,
                          busyActionKeys: runningActionKeys,
                          onFilterChanged: (filter) {
                            ref
                                .read(
                                  omniChannelActivityActionExecutionLogFilterProvider
                                      .notifier,
                                )
                                .state = filter;
                          },
                          onRecordSelected: (record) {
                            ref
                                .read(
                                  omniChannelActivityCenterSelectedEntryIdProvider
                                      .notifier,
                                )
                                .state = record.entryId;
                            _openActivityLocation(
                              filter: filter,
                              selectedEntryId: record.entryId,
                            );
                          },
                          onOpenRecord:
                              (record) => _openLocation(record.openLocation),
                          onRetryRecord: (record) {
                            unawaited(
                              _retryActivityAction(
                                feedEntries: feed.entries,
                                filter: filter,
                                record: record,
                              ),
                            );
                          },
                          onRetryAttention: () {
                            unawaited(
                              _retryAttentionActions(
                                feedEntries: feed.entries,
                                filter: filter,
                                records: actionExecutionLog.attentionEntries,
                              ),
                            );
                          },
                          onClearCompleted:
                              ref
                                  .read(
                                    omniChannelActivityActionExecutionLogProvider
                                        .notifier,
                                  )
                                  .clearCompleted,
                          onClear:
                              ref
                                  .read(
                                    omniChannelActivityActionExecutionLogProvider
                                        .notifier,
                                  )
                                  .clear,
                        ),
                      ],
                      const SizedBox(height: 14),
                      AppContentPanel(
                        title: 'Activity controls',
                        subtitle: 'POS, ecommerce, sync, and channel events',
                        leadingIcon: Icons.tune_outlined,
                        child: OmniChannelActivityFilterBar(
                          filter: filter,
                          counts: counts,
                          scopeOptions: scopeOptions,
                          onFilterChanged: (nextFilter) {
                            ref
                                .read(
                                  omniChannelActivityCenterFilterProvider
                                      .notifier,
                                )
                                .state = nextFilter;
                            _openActivityLocation(
                              filter: nextFilter,
                              selectedEntryId: ref.read(
                                omniChannelActivityCenterSelectedEntryIdProvider,
                              ),
                            );
                          },
                        ),
                      ),
                      if (registryDiagnostics.hasContributions) ...[
                        const SizedBox(height: 14),
                        OmniChannelActivityRegistryDiagnosticsPanel(
                          diagnostics: registryDiagnostics,
                        ),
                      ],
                      const SizedBox(height: 14),
                      OmniChannelActivityWorkspace(
                        feed: feed,
                        entries: entries,
                        selectedEntry: selectedEntry,
                        hasActiveFilters: filter.hasConstraints,
                        actionRegistry: actionRegistry,
                        busyActionKeys: runningActionKeys,
                        onEntrySelected: (entry) {
                          ref
                              .read(
                                omniChannelActivityCenterSelectedEntryIdProvider
                                    .notifier,
                              )
                              .state = entry.id;
                          _openActivityLocation(
                            filter: filter,
                            selectedEntryId: entry.id,
                          );
                        },
                        onActionSelected: (entry, action) {
                          unawaited(
                            _runActivityAction(entry: entry, action: action),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _applyInitialQueryState(
    OmniChannelActivityCenterQueryState? queryState,
  ) {
    if (queryState == null) return;

    ref.read(omniChannelActivityCenterFilterProvider.notifier).state =
        queryState.filter;
    ref.read(omniChannelActivityCenterSelectedEntryIdProvider.notifier).state =
        queryState.selectedEntryId;
  }

  void _scheduleQueryStateApply(
    OmniChannelActivityCenterQueryState queryState,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyInitialQueryState(queryState);
    });
  }

  void _openActivityLocation({
    required OmniChannelActivityFilter filter,
    required String? selectedEntryId,
  }) {
    final opener = widget.onOpenLocation;
    if (opener == null) return;

    final queryState = OmniChannelActivityCenterQueryState(
      filter: filter,
      selectedEntryId: selectedEntryId,
    );
    opener(
      queryState.locationForPath(OmniChannelActivityRoutes.activityCenterPath),
    );
  }

  Future<void> _retryActivityAction({
    required List<OmniChannelActivityEntry> feedEntries,
    required OmniChannelActivityFilter filter,
    required OmniChannelActivityActionExecutionRecord record,
  }) async {
    final entry = _entryById(feedEntries, record.entryId);
    if (entry == null) {
      if (!mounted) return;

      showOmniChannelActivityActionFeedback(
        context,
        OmniChannelActivityActionExecutionResult.blocked(
          action: record.result.action,
          message: 'Activity is no longer available for retry.',
          location: record.openLocation,
        ),
      );
      return;
    }

    if (ref
        .read(omniChannelActivityActionExecutionControllerProvider)
        .isActionBusy(entry: entry, action: record.result.action)) {
      return;
    }

    ref.read(omniChannelActivityCenterSelectedEntryIdProvider.notifier).state =
        entry.id;
    _openActivityLocation(filter: filter, selectedEntryId: entry.id);

    await _runActivityAction(entry: entry, action: record.result.action);
  }

  Future<void> _retryAttentionActions({
    required List<OmniChannelActivityEntry> feedEntries,
    required OmniChannelActivityFilter filter,
    required List<OmniChannelActivityActionExecutionRecord> records,
  }) async {
    for (final record in records) {
      if (!mounted) return;

      await _retryActivityAction(
        feedEntries: feedEntries,
        filter: filter,
        record: record,
      );
    }
  }

  Future<void> _runActivityAction({
    required OmniChannelActivityEntry entry,
    required OmniChannelActivityAction action,
  }) async {
    final result = await ref
        .read(omniChannelActivityActionExecutionControllerProvider.notifier)
        .execute(entry: entry, action: action, openLocation: _openLocation);
    if (!mounted || result == null) return;

    showOmniChannelActivityActionFeedback(context, result);
  }

  void _openLocation(String location) {
    final opener = widget.onOpenLocation;
    if (opener != null) {
      opener(location);
      return;
    }

    context.go(location);
  }
}

@Preview(name: 'Omni-channel activity center')
Widget omniChannelActivityCenterScreenPreview() {
  return ProviderScope(
    overrides: [
      omniChannelActivityFeedProvider.overrideWithValue(
        OmniChannelActivityFeed(
          entries: [
            OmniChannelActivityEntry(
              id: 'preview-review',
              kind: OmniChannelActivityKind.order,
              sourceId: 'ecommerce',
              sourceLabel: 'Ecommerce',
              occurredAt: DateTime(2026, 6, 9, 11),
              title: 'Marketplace pickup needs review',
              detail: 'Confirm pickup capacity before accepting handoff.',
              severity: OmniChannelActivitySeverity.review,
              channelId: 'marketplace',
              channelLabel: 'Marketplace',
              orderId: 'ECOM-2026-017',
            ),
            OmniChannelActivityEntry(
              id: 'preview-sync',
              kind: OmniChannelActivityKind.orderSync,
              sourceId: 'point_of_sales',
              sourceLabel: 'Point of sale',
              occurredAt: DateTime(2026, 6, 9, 10, 30),
              title: 'Counter order synced',
              detail: 'POS order reached ecommerce order workspace.',
              channelId: 'web_store',
              channelLabel: 'Web store',
              orderId: 'POS-2026-014',
            ),
          ],
        ),
      ),
    ],
    child: const MaterialApp(home: OmniChannelActivityCenterScreen()),
  );
}

OmniChannelActivityEntry? _selectedEntry({
  required List<OmniChannelActivityEntry> visibleEntries,
  required List<OmniChannelActivityEntry> feedEntries,
  required String? selectedEntryId,
}) {
  for (final entry in visibleEntries) {
    if (entry.id == selectedEntryId) return entry;
  }

  for (final entry in feedEntries) {
    if (entry.id == selectedEntryId) return entry;
  }

  return visibleEntries.isEmpty ? null : visibleEntries.first;
}

OmniChannelActivityEntry? _entryById(
  List<OmniChannelActivityEntry> entries,
  String entryId,
) {
  for (final entry in entries) {
    if (entry.id == entryId) return entry;
  }

  return null;
}
