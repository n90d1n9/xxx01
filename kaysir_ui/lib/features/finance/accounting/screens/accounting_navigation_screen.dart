import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../accounting_path.dart';
import '../models/accounting_menu_catalog.dart';
import '../models/accounting_menu_saved_view.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_close_command_center.dart';
import '../models/accounting_workspace_next_action.dart';
import '../models/accounting_workspace_period_close_execution.dart';
import '../models/accounting_workspace_recent_view.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_close_readiness.dart';
import '../models/accounting_workspace_work_queue_detail.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_owner_summary.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_exception_register.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_evidence_review_state.dart';
import '../models/work_queue_note.dart';
import '../models/work_queue_close_packet_evidence_summary.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_resolution_state.dart';
import '../models/work_queue_resolution_summary.dart';
import '../models/work_queue_saved_view.dart';
import '../models/work_queue_saved_view_manager_audit.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../repositories/accounting_workspace_recent_view_repository.dart';
import '../services/accounting_workspace_close_command_center_service.dart';
import '../services/accounting_workspace_next_action_service.dart';
import '../services/accounting_workspace_overview_service.dart';
import '../services/accounting_workspace_period_close_execution_service.dart';
import '../services/accounting_workspace_recent_view_service.dart';
import '../services/accounting_workspace_route_service.dart';
import '../services/accounting_workspace_work_queue_clearance_action_sync.dart';
import '../services/accounting_workspace_work_queue_owner_brief_composer.dart';
import '../services/work_queue_close_packet_composer.dart';
import '../services/work_queue_evidence_exception_register_service.dart';
import '../services/work_queue_resolution_summary_service.dart';
import '../services/accounting_workspace_work_queue_service.dart';
import '../widgets/accounting_navigation_close_command_center_components.dart';
import '../widgets/accounting_navigation_components.dart';
import '../widgets/accounting_navigation_context_components.dart';
import '../widgets/accounting_navigation_next_action_components.dart';
import '../widgets/accounting_navigation_overview_components.dart';
import '../widgets/accounting_navigation_period_close_execution_components.dart';
import '../widgets/accounting_navigation_recent_view_components.dart';
import '../widgets/accounting_navigation_role_preset_components.dart';
import '../widgets/accounting_navigation_saved_view_components.dart';
import '../widgets/accounting_navigation_search_components.dart';
import '../widgets/accounting_navigation_section_navigator_components.dart';
import '../widgets/accounting_navigation_work_queue_components.dart';
import '../widgets/work_queue_saved_view_manager_dialog.dart';

/// Accounting workspace hub for search, role presets, and close work queues.
class AccountingNavigationScreen extends StatefulWidget {
  const AccountingNavigationScreen({
    this.initialQuery = '',
    this.initialScope = AccountingMenuSearchScope.all,
    this.initialRolePreset = AccountingWorkspaceRolePreset.accountant,
    this.initialWorkQueueFocus = AccountingWorkspaceWorkQueueFocus.all,
    this.initialWorkQueueSort = AccountingWorkspaceWorkQueueSort.workflow,
    this.initialWorkQueueOwnerFilter,
    this.initialSelectedWorkQueueId,
    this.initialSelectedWorkQueueDetailSection =
        AccountingWorkspaceWorkQueueDetailSection.overview,
    this.preferInitialRolePreset = false,
    this.preferInitialWorkQueueFocus = false,
    this.preferInitialWorkQueueSort = false,
    this.recentViewService = const AccountingWorkspaceRecentViewService(),
    this.nextActionService = const AccountingWorkspaceNextActionService(),
    this.workQueueService = const AccountingWorkspaceWorkQueueService(),
    this.closeCommandCenterService =
        const AccountingWorkspaceCloseCommandCenterService(),
    this.periodCloseExecutionService =
        const AccountingWorkspacePeriodCloseExecutionService(),
    this.overviewService = const AccountingWorkspaceOverviewService(),
    this.routeService = const AccountingWorkspaceRouteService(),
    this.recentViewRepository,
    super.key,
  });

  final String initialQuery;
  final AccountingMenuSearchScope initialScope;
  final AccountingWorkspaceRolePreset initialRolePreset;
  final AccountingWorkspaceWorkQueueFocus initialWorkQueueFocus;
  final AccountingWorkspaceWorkQueueSort initialWorkQueueSort;
  final String? initialWorkQueueOwnerFilter;
  final String? initialSelectedWorkQueueId;
  final AccountingWorkspaceWorkQueueDetailSection
  initialSelectedWorkQueueDetailSection;
  final bool preferInitialRolePreset;
  final bool preferInitialWorkQueueFocus;
  final bool preferInitialWorkQueueSort;
  final AccountingWorkspaceRecentViewService recentViewService;
  final AccountingWorkspaceNextActionService nextActionService;
  final AccountingWorkspaceWorkQueueService workQueueService;
  final AccountingWorkspaceCloseCommandCenterService closeCommandCenterService;
  final AccountingWorkspacePeriodCloseExecutionService
  periodCloseExecutionService;
  final AccountingWorkspaceOverviewService overviewService;
  final AccountingWorkspaceRouteService routeService;
  final AccountingWorkspaceRecentViewRepository? recentViewRepository;

  @override
  State<AccountingNavigationScreen> createState() =>
      _AccountingNavigationScreenState();
}

class _AccountingNavigationScreenState
    extends State<AccountingNavigationScreen> {
  static const _clearanceActionSync =
      AccountingWorkspaceWorkQueueClearanceActionSync();
  static const _ownerBriefComposer =
      AccountingWorkspaceWorkQueueOwnerBriefComposer();
  static const _closePacketComposer =
      AccountingWorkspaceWorkQueueClosePacketComposer();
  static const _evidenceExceptionRegisterService =
      AccountingWorkspaceWorkQueueEvidenceExceptionRegisterService();
  static const _resolutionSummaryService =
      AccountingWorkspaceWorkQueueResolutionSummaryService();
  static const _maxWorkQueueSavedViewAuditEvents = 20;
  static const _searchSuggestions = [
    AccountingNavigationSearchSuggestion(
      label: 'Management',
      query: 'management',
      scope: AccountingMenuSearchScope.shortcuts,
      icon: Icons.speed_rounded,
      tooltip: 'Show management-measure focus shortcuts',
    ),
    AccountingNavigationSearchSuggestion(
      label: 'Release',
      query: 'release',
      scope: AccountingMenuSearchScope.shortcuts,
      icon: Icons.verified_user_rounded,
      tooltip: 'Show report-release focus shortcuts',
    ),
    AccountingNavigationSearchSuggestion(
      label: 'SPT filing',
      query: 'spt',
      scope: AccountingMenuSearchScope.shortcuts,
      icon: Icons.account_balance_rounded,
      tooltip: 'Show statutory filing shortcuts for SPT support',
    ),
    AccountingNavigationSearchSuggestion(
      label: 'Evidence',
      query: 'evidence',
      scope: AccountingMenuSearchScope.all,
      icon: Icons.fact_check_rounded,
      tooltip: 'Show evidence-related screens and shortcuts',
    ),
  ];

  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late String _query;
  late AccountingMenuSearchScope _scope;
  late AccountingWorkspaceRolePreset _rolePreset;
  late AccountingWorkspaceWorkQueueFocus _workQueueFocus;
  late AccountingWorkspaceWorkQueueSort _workQueueSort;
  AccountingWorkspaceWorkQueueResolutionFilter _workQueueResolutionFilter =
      AccountingWorkspaceWorkQueueResolutionFilter.all;
  late AccountingWorkspaceWorkQueueDetailSection
  _selectedWorkQueueDetailSection;
  String? _workQueueOwnerFilter;
  String? _selectedWorkQueueId;
  AccountingWorkspaceWorkQueue? _selectedWorkQueue;
  late List<AccountingWorkspaceRecentView> _recentViews;
  late List<AccountingWorkspaceWorkQueueSavedView> _customWorkQueueSavedViews;
  late List<WorkQueueSavedViewManagerAuditEvent> _workQueueSavedViewAuditEvents;
  final Map<String, AccountingWorkspaceWorkQueueActivityActionState>
  _workQueueActivityActionStates = {};
  final Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState>
  _workQueueReviewerSignOffStates = {};
  final Map<String, AccountingWorkspaceWorkQueueResolutionState>
  _workQueueResolutionStates = {};
  final Map<String, List<AccountingWorkspaceWorkQueueEvidenceLink>>
  _workQueueEvidenceLinks = {};
  final Map<String, AccountingWorkspaceWorkQueueEvidenceReviewState>
  _workQueueEvidenceReviewStates = {};
  final Map<String, List<AccountingWorkspaceWorkQueueNote>> _workQueueNotes =
      {};
  final GlobalKey _workQueuePanelKey = GlobalKey();
  final Map<String, GlobalKey> _sectionKeys = {};
  Future<void>? _persistWorkspaceStateFuture;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _scope = widget.initialScope;
    _rolePreset = widget.initialRolePreset;
    _workQueueFocus = widget.initialWorkQueueFocus;
    _workQueueSort = widget.initialWorkQueueSort;
    _selectedWorkQueueDetailSection =
        widget.initialSelectedWorkQueueDetailSection;
    _workQueueOwnerFilter = _normalizedWorkQueueOwnerFilter(
      widget.initialWorkQueueOwnerFilter,
    );
    _selectedWorkQueueId = _normalizedSelectedWorkQueueId(
      widget.initialSelectedWorkQueueId,
    );
    _recentViews = widget.recentViewService.record(
      const [],
      AccountingWorkspaceRecentView.fromSearch(query: _query, scope: _scope),
    );
    _customWorkQueueSavedViews = const [];
    _workQueueSavedViewAuditEvents = const [];
    _searchController = TextEditingController(text: _query);
    _scrollController = ScrollController();
    unawaited(_hydrateRecentViews());
  }

  @override
  void didUpdateWidget(AccountingNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    var routeStateChanged = false;
    if (oldWidget.initialQuery != widget.initialQuery) {
      _query = widget.initialQuery.trim();
      _searchController.text = _query;
      routeStateChanged = true;
    }
    if (oldWidget.initialScope != widget.initialScope) {
      _scope = widget.initialScope;
      routeStateChanged = true;
    }
    if (oldWidget.initialRolePreset != widget.initialRolePreset) {
      _rolePreset = widget.initialRolePreset;
      unawaited(_queuePersistWorkspaceState());
    }
    if (widget.preferInitialWorkQueueFocus &&
        (oldWidget.initialWorkQueueFocus != widget.initialWorkQueueFocus ||
            oldWidget.preferInitialWorkQueueFocus !=
                widget.preferInitialWorkQueueFocus)) {
      _workQueueFocus = widget.initialWorkQueueFocus;
      unawaited(_queuePersistWorkspaceState());
    }
    if (widget.preferInitialWorkQueueSort &&
        (oldWidget.initialWorkQueueSort != widget.initialWorkQueueSort ||
            oldWidget.preferInitialWorkQueueSort !=
                widget.preferInitialWorkQueueSort)) {
      _workQueueSort = widget.initialWorkQueueSort;
      unawaited(_queuePersistWorkspaceState());
    }
    if (oldWidget.initialWorkQueueOwnerFilter !=
        widget.initialWorkQueueOwnerFilter) {
      _workQueueOwnerFilter = _normalizedWorkQueueOwnerFilter(
        widget.initialWorkQueueOwnerFilter,
      );
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    }
    if (oldWidget.initialSelectedWorkQueueId !=
        widget.initialSelectedWorkQueueId) {
      _selectedWorkQueueId = _normalizedSelectedWorkQueueId(
        widget.initialSelectedWorkQueueId,
      );
      _clearWorkQueueSelectionState(keepSelectedId: true);
      unawaited(_queuePersistWorkspaceState());
    }
    if (oldWidget.initialSelectedWorkQueueDetailSection !=
        widget.initialSelectedWorkQueueDetailSection) {
      _selectedWorkQueueDetailSection =
          widget.initialSelectedWorkQueueDetailSection;
    }
    if (routeStateChanged) {
      _rememberRecentView(
        AccountingWorkspaceRecentView.fromSearch(query: _query, scope: _scope),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredSections = filterAccountingMenuSections(
      _query,
      scope: _scope,
    );
    final savedViews = accountingMenuSavedViewsForRole(_rolePreset);
    final customWorkQueueSavedViews =
        accountingWorkspaceWorkQueueSavedViewsForRole(
          _rolePreset,
          views: _customWorkQueueSavedViews,
        );
    final workQueueSavedViews = [
      ...customWorkQueueSavedViews,
      ...accountingWorkspaceWorkQueueSavedViewsForRole(_rolePreset),
    ];
    final workQueueSavedViewAuditEvents =
        workQueueSavedViewManagerAuditEventsForRole(
          events: _workQueueSavedViewAuditEvents,
          rolePreset: _rolePreset,
        );
    final nextActions = widget.nextActionService.actionsFor(
      rolePreset: _rolePreset,
      query: _query,
      scope: _scope,
    );
    final workQueues = widget.workQueueService.queuesFor(
      rolePreset: _rolePreset,
      query: _query,
      scope: _scope,
    );
    final workQueueDetailsById = {
      for (final queue in workQueues)
        queue.id: widget.workQueueService.detailFor(queue),
    };
    final workQueueEvidenceReadinessById = {
      for (final entry in workQueueDetailsById.entries)
        entry.key: _workQueueEvidenceReadinessFor(entry.value),
    };
    final workQueueHealth = widget.workQueueService.summarize(workQueues);
    final workQueueSlaSummary = widget.workQueueService.summarizeSla(
      workQueues,
    );
    final workQueueOwnerSummary = widget.workQueueService.summarizeOwners(
      workQueues,
    );
    final workQueueCloseReadiness = widget.workQueueService
        .summarizeCloseReadiness(workQueues);
    final closeCommandCenter = widget.closeCommandCenterService.summarize(
      health: workQueueHealth,
      slaSummary: workQueueSlaSummary,
      ownerSummary: workQueueOwnerSummary,
      closeReadiness: workQueueCloseReadiness,
    );
    final periodCloseExecution = widget.periodCloseExecutionService.summarize(
      commandCenter: closeCommandCenter,
      closeReadiness: workQueueCloseReadiness,
      ownerSummary: workQueueOwnerSummary,
    );
    final activeCloseGate = _activeCloseGate(closeCommandCenter);
    final activeCloseGateId = activeCloseGate?.id;
    final closeCommandCenterNextQueue = _workQueueById(
      workQueues,
      closeCommandCenter.nextActionQueueId,
    );
    final effectiveWorkQueueOwnerFilter = _effectiveWorkQueueOwnerFilter(
      workQueueOwnerSummary,
    );
    final focusedWorkQueues = widget.workQueueService.filterByFocus(
      workQueues,
      _workQueueFocus,
    );
    final ownerFilteredWorkQueues = widget.workQueueService.filterByOwner(
      focusedWorkQueues,
      effectiveWorkQueueOwnerFilter,
    );
    final workQueueResolutionSummary = _resolutionSummaryService.summarize(
      queues: ownerFilteredWorkQueues,
      detailsByQueueId: workQueueDetailsById,
      actionStates: _workQueueActivityActionStates,
      reviewerSignOffStates: _workQueueReviewerSignOffStates,
      resolutionStates: _workQueueResolutionStates,
      evidenceReadinessByQueueId: workQueueEvidenceReadinessById,
    );
    final resolutionFilteredWorkQueues = _resolutionSummaryService
        .filterByResolution(
          queues: ownerFilteredWorkQueues,
          filter: _workQueueResolutionFilter,
          detailsByQueueId: workQueueDetailsById,
          actionStates: _workQueueActivityActionStates,
          reviewerSignOffStates: _workQueueReviewerSignOffStates,
          resolutionStates: _workQueueResolutionStates,
          evidenceReadinessByQueueId: workQueueEvidenceReadinessById,
        );
    final sortedWorkQueues = widget.workQueueService.sortQueues(
      resolutionFilteredWorkQueues,
      _workQueueSort,
    );
    final workQueueResolutionSnapshotsById = _resolutionSummaryService
        .snapshotsFor(
          queues: sortedWorkQueues,
          detailsByQueueId: workQueueDetailsById,
          actionStates: _workQueueActivityActionStates,
          reviewerSignOffStates: _workQueueReviewerSignOffStates,
          resolutionStates: _workQueueResolutionStates,
          evidenceReadinessByQueueId: workQueueEvidenceReadinessById,
        );
    final workQueueResolutionNextAction = _resolutionSummaryService
        .nextActionFor(
          queues: ownerFilteredWorkQueues,
          filter: _workQueueResolutionFilter,
          detailsByQueueId: workQueueDetailsById,
          actionStates: _workQueueActivityActionStates,
          reviewerSignOffStates: _workQueueReviewerSignOffStates,
          resolutionStates: _workQueueResolutionStates,
          evidenceReadinessByQueueId: workQueueEvidenceReadinessById,
        );
    final workQueueResolutionBriefItems = _resolutionSummaryService
        .briefItemsFor(
          queues: ownerFilteredWorkQueues,
          filter: _workQueueResolutionFilter,
          detailsByQueueId: workQueueDetailsById,
          actionStates: _workQueueActivityActionStates,
          reviewerSignOffStates: _workQueueReviewerSignOffStates,
          resolutionStates: _workQueueResolutionStates,
          evidenceReadinessByQueueId: workQueueEvidenceReadinessById,
        );
    final workQueueClosePacketEvidenceReadiness = [
      for (final queue in resolutionFilteredWorkQueues)
        if (workQueueEvidenceReadinessById[queue.id] case final readiness?)
          readiness,
    ];
    final workQueueClosePacketEvidenceSummary =
        AccountingWorkspaceWorkQueueClosePacketEvidenceSummary.fromReadiness(
          workQueueClosePacketEvidenceReadiness,
        );
    final workQueueEvidenceExceptionRegister = _evidenceExceptionRegisterService
        .build(
          queues: resolutionFilteredWorkQueues,
          evidenceReadinessByQueueId: workQueueEvidenceReadinessById,
        );
    final workQueueClosePacketEvidenceQueueTitlesById = {
      for (final queue in resolutionFilteredWorkQueues) queue.id: queue.title,
    };
    final workQueueResolutionNextQueue = _workQueueById(
      ownerFilteredWorkQueues,
      workQueueResolutionNextAction?.queueId,
    );
    final selectedWorkQueue = _effectiveSelectedWorkQueue(sortedWorkQueues);
    final selectedWorkQueueDetail =
        selectedWorkQueue == null
            ? null
            : workQueueDetailsById[selectedWorkQueue.id];
    final selectedWorkQueueActivityActionState =
        selectedWorkQueue == null
            ? null
            : _activityActionStateFor(selectedWorkQueue.id);
    final selectedWorkQueueReviewerSignOffState =
        selectedWorkQueue == null
            ? null
            : _reviewerSignOffStateFor(selectedWorkQueue.id);
    final selectedWorkQueueResolutionState =
        selectedWorkQueue == null
            ? null
            : _resolutionStateFor(selectedWorkQueue.id);
    final selectedWorkQueueEvidenceLinks =
        selectedWorkQueue == null
            ? const <AccountingWorkspaceWorkQueueEvidenceLink>[]
            : _workQueueEvidenceLinksFor(selectedWorkQueue.id);
    final selectedWorkQueueEvidenceReviewStates =
        selectedWorkQueue == null
            ? const <String, AccountingWorkspaceWorkQueueEvidenceReviewState>{}
            : _workQueueEvidenceReviewStatesFor(selectedWorkQueue.id);
    final selectedWorkQueueExecutionNotes =
        selectedWorkQueue == null
            ? const <AccountingWorkspaceWorkQueueNote>[]
            : _workQueueNotesFor(selectedWorkQueue.id);
    final overview = widget.overviewService.summarize(
      sections: filteredSections,
      savedViews: savedViews,
      priorityActions: nextActions,
    );
    final hasQuery = _query.trim().isNotEmpty;
    final resultCount = accountingMenuDestinationCount(filteredSections);
    final showPeriodCloseExecution =
        _rolePreset == AccountingWorkspaceRolePreset.controller;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Accounting')),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(18),
        children: [
          AccountingNavigationHeader(
            onCopyLink: _copyWorkspaceLink,
            onDestinationSelected: _openMenuDestination,
          ),
          const SizedBox(height: 14),
          AccountingNavigationSearchPanel(
            controller: _searchController,
            onChanged: _updateQuery,
            onClear: _clearQuery,
            onSubmitted: _commitSearch,
            scope: _scope,
            onScopeChanged: _updateScope,
            resultCount: resultCount,
            hasQuery: hasQuery,
            suggestions: _searchSuggestions,
            onSuggestionSelected: _applySearchSuggestion,
          ),
          const SizedBox(height: 12),
          AccountingNavigationRolePresetSelector(
            value: _rolePreset,
            onChanged: _updateRolePreset,
          ),
          const SizedBox(height: 12),
          AccountingNavigationContextStrip(
            rolePreset: _rolePreset,
            scope: _scope,
            query: _query,
            resultCount: resultCount,
            onReset: _resetWorkspace,
          ),
          const SizedBox(height: 12),
          AccountingNavigationSavedViews(
            views: savedViews,
            query: _query,
            scope: _scope,
            onSelected: _applySavedView,
          ),
          if (_recentViews.isNotEmpty) ...[
            const SizedBox(height: 12),
            AccountingNavigationRecentViews(
              views: _recentViews,
              query: _query,
              scope: _scope,
              onSelected: _applyRecentView,
              onClear: _clearRecentViews,
            ),
          ],
          const SizedBox(height: 12),
          AccountingNavigationOverviewStrip(overview: overview),
          const SizedBox(height: 12),
          if (closeCommandCenter.hasQueues) ...[
            AccountingNavigationCloseCommandCenter(
              commandCenter: closeCommandCenter,
              activeGateId: activeCloseGateId,
              onCopyBrief:
                  () => _copyCloseCommandCenterBrief(closeCommandCenter),
              onGateSelected: _reviewCloseGate,
              onReviewNext:
                  closeCommandCenterNextQueue == null
                      ? null
                      : () => _reviewWorkQueue(closeCommandCenterNextQueue),
            ),
            const SizedBox(height: 12),
            if (showPeriodCloseExecution) ...[
              AccountingNavigationPeriodCloseExecution(
                execution: periodCloseExecution,
                onCopyBrief:
                    () => _copyPeriodCloseExecutionBrief(periodCloseExecution),
                onOpenWorkflow: _openPeriodCloseWorkflow,
                onReviewOwner:
                    periodCloseExecution.ownerHandoff == null
                        ? null
                        : () => _reviewOwnerHandoff(
                          periodCloseExecution.ownerHandoff!.ownerLabel,
                        ),
                onCopyOwnerHandoff:
                    periodCloseExecution.ownerHandoff == null
                        ? null
                        : () => _copyPeriodCloseOwnerHandoff(
                          periodCloseExecution.ownerHandoff!,
                        ),
                onReviewNext:
                    closeCommandCenterNextQueue == null
                        ? null
                        : () => _reviewWorkQueue(closeCommandCenterNextQueue),
                onStepSelected:
                    (step) => _reviewPeriodCloseExecutionStep(
                      step,
                      closeCommandCenter,
                    ),
              ),
              const SizedBox(height: 12),
            ],
          ],
          KeyedSubtree(
            key: _workQueuePanelKey,
            child: AccountingNavigationWorkQueues(
              queues: sortedWorkQueues,
              health: workQueueHealth,
              slaSummary: workQueueSlaSummary,
              ownerSummary: workQueueOwnerSummary,
              closeReadiness: workQueueCloseReadiness,
              savedViews: workQueueSavedViews,
              hasManagedSavedViewHistory:
                  workQueueSavedViewAuditEvents.isNotEmpty,
              query: _query,
              scope: _scope,
              rolePreset: _rolePreset,
              activeGateReview: activeCloseGate,
              ownerFilter: effectiveWorkQueueOwnerFilter,
              selectedQueueId: _selectedWorkQueueId,
              selectedQueue: selectedWorkQueue,
              selectedQueueDetail: selectedWorkQueueDetail,
              selectedQueueDetailSection: _selectedWorkQueueDetailSection,
              selectedQueueActivityActionState:
                  selectedWorkQueueActivityActionState,
              selectedQueueReviewerSignOffState:
                  selectedWorkQueueReviewerSignOffState,
              selectedQueueResolutionState: selectedWorkQueueResolutionState,
              selectedQueueEvidenceLinks: selectedWorkQueueEvidenceLinks,
              selectedQueueEvidenceReviewStates:
                  selectedWorkQueueEvidenceReviewStates,
              selectedQueueExecutionNotes: selectedWorkQueueExecutionNotes,
              queueResolutionStates: _workQueueResolutionStates,
              queueResolutionSnapshots: workQueueResolutionSnapshotsById,
              queueEvidenceReadiness: workQueueEvidenceReadinessById,
              evidenceExceptionRegister: workQueueEvidenceExceptionRegister,
              resolutionSummary: workQueueResolutionSummary,
              resolutionFilter: _workQueueResolutionFilter,
              resolutionEvidenceSummary: workQueueClosePacketEvidenceSummary,
              resolutionNextAction: workQueueResolutionNextAction,
              sort: _workQueueSort,
              focus: _workQueueFocus,
              onFocusChanged: _updateWorkQueueFocus,
              onOwnerFilterChanged: _updateWorkQueueOwnerFilter,
              onSortChanged: _updateWorkQueueSort,
              onSavedViewSelected: _applyWorkQueueSavedView,
              onViewReset: _resetWorkQueueViewContext,
              onCurrentViewSaved:
                  () => _saveCurrentWorkQueueView(selectedWorkQueue),
              onSavedViewsManaged: _manageWorkQueueSavedViews,
              onSavedViewDeleted: _deleteWorkQueueSavedView,
              onSelected: _selectWorkQueue,
              onOpenQueue: _openWorkQueue,
              onCopyBrief: _copyWorkQueueBrief,
              onCopyEvidenceRequest: _copyWorkQueueEvidenceRequest,
              onCopyLink: _copyWorkQueueLink,
              onCopyActivityAuditBrief: _copyWorkQueueActivityAuditBrief,
              onCopyClearancePlan: _copyWorkQueueClearancePlan,
              onCopyCloseReadinessBrief: _copyCloseReadinessBrief,
              onCopyEvidenceExceptionRegister:
                  _copyWorkQueueEvidenceExceptionRegister,
              onCopyResolutionSummaryBrief:
                  () => _copyWorkQueueResolutionSummaryBrief(
                    workQueueResolutionSummary,
                    filter: _workQueueResolutionFilter,
                    nextAction: workQueueResolutionNextAction,
                    briefItems: workQueueResolutionBriefItems,
                    evidenceReadiness: workQueueClosePacketEvidenceReadiness,
                    evidenceQueueTitlesById:
                        workQueueClosePacketEvidenceQueueTitlesById,
                  ),
              onResolutionFilterChanged: _updateWorkQueueResolutionFilter,
              onNextResolutionSelected:
                  workQueueResolutionNextQueue == null
                      ? null
                      : () => _reviewWorkQueue(workQueueResolutionNextQueue),
              onDetailSectionChanged: _updateSelectedWorkQueueDetailSection,
              onActivityOwnerAcknowledged: _acknowledgeWorkQueueActivityOwner,
              onActivityEvidenceReceived: _receiveWorkQueueActivityEvidence,
              onActivityEscalationLogged: _logWorkQueueActivityEscalation,
              onEvidenceLinkAdded: _addWorkQueueEvidenceLink,
              onEvidenceLinkReviewDecisionChanged:
                  _updateWorkQueueEvidenceReviewState,
              onCopyEvidenceLinks: _copyWorkQueueEvidenceLinks,
              onExecutionNoteAdded: _addWorkQueueExecutionNote,
              onCopyExecutionNotes: _copyWorkQueueExecutionNotes,
              onReviewerApproved: _approveWorkQueueReviewerSignOff,
              onReviewerReturned: _returnWorkQueueReviewerSignOff,
              onReviewerBlocked: _blockWorkQueueReviewerSignOff,
              onQueueCleared: _clearWorkQueueResolution,
              onGateReviewCleared: _clearCloseGateReview,
              onSelectionCleared: _clearSelectedWorkQueue,
            ),
          ),
          const SizedBox(height: 12),
          AccountingNavigationNextActions(
            actions: nextActions,
            onSelected: _openNextAction,
          ),
          const SizedBox(height: 12),
          if (filteredSections.isNotEmpty) ...[
            AccountingNavigationSectionNavigator(
              sections: filteredSections,
              onSelected: _scrollToSection,
              onDestinationSelected: _openMenuDestination,
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 10),
          if (filteredSections.isEmpty)
            AccountingNavigationEmptyState(query: _query.trim())
          else
            for (final section in filteredSections) ...[
              KeyedSubtree(
                key: _sectionKey(section),
                child: AccountingNavigationSectionGrid(section: section),
              ),
              if (section != filteredSections.last) const SizedBox(height: 22),
            ],
        ],
      ),
    );
  }

  void _updateQuery(String value) {
    setState(() {
      _query = value;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
    });
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() {
      _query = '';
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(query: '');
  }

  void _updateScope(AccountingMenuSearchScope scope) {
    setState(() {
      _scope = scope;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      _rememberRecentView(
        AccountingWorkspaceRecentView.fromSearch(query: _query, scope: _scope),
      );
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(scope: scope);
  }

  void _applySearchSuggestion(AccountingNavigationSearchSuggestion suggestion) {
    _searchController.text = suggestion.query;
    setState(() {
      _query = suggestion.query;
      _scope = suggestion.scope;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      _rememberRecentView(
        AccountingWorkspaceRecentView.fromSearch(query: _query, scope: _scope),
      );
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(query: suggestion.query, scope: suggestion.scope);
  }

  void _updateRolePreset(AccountingWorkspaceRolePreset preset) {
    setState(() {
      _rolePreset = preset;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(rolePreset: preset);
  }

  void _resetWorkspace() {
    setState(() {
      _query = '';
      _scope = AccountingMenuSearchScope.all;
      _rolePreset = AccountingWorkspaceRolePreset.accountant;
      _workQueueFocus = AccountingWorkspaceWorkQueueFocus.all;
      _workQueueSort = AccountingWorkspaceWorkQueueSort.workflow;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      _searchController.clear();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(
      query: '',
      scope: AccountingMenuSearchScope.all,
      rolePreset: AccountingWorkspaceRolePreset.accountant,
      workQueueFocus: AccountingWorkspaceWorkQueueFocus.all,
    );
  }

  void _openNextAction(AccountingWorkspaceNextAction action) {
    context.go(action.path);
  }

  void _openMenuDestination(AccountingMenuDestination destination) {
    context.go(destination.path);
  }

  void _selectWorkQueue(AccountingWorkspaceWorkQueue queue) {
    setState(() {
      _setSelectedWorkQueueState(queue);
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(
      selectedWorkQueueId: queue.id,
      workQueueDetailSection: _selectedWorkQueueDetailSection,
    );
  }

  void _reviewWorkQueue(AccountingWorkspaceWorkQueue queue) {
    setState(() {
      _workQueueFocus = AccountingWorkspaceWorkQueueFocus.all;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _setSelectedWorkQueueState(queue);
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(
      workQueueFocus: AccountingWorkspaceWorkQueueFocus.all,
      selectedWorkQueueId: queue.id,
      workQueueDetailSection: _selectedWorkQueueDetailSection,
    );
    _scrollToWorkQueuePanel();
  }

  void _applyWorkQueueSavedView(AccountingWorkspaceWorkQueueSavedView view) {
    final normalizedOwner = _normalizedWorkQueueOwnerFilter(view.ownerFilter);
    final normalizedQueueId = _normalizedSelectedWorkQueueId(
      view.selectedQueueId,
    );
    final detailSection =
        normalizedQueueId == null
            ? AccountingWorkspaceWorkQueueDetailSection.overview
            : view.detailSection;
    final query = view.query.trim();

    setState(() {
      _query = query;
      _scope = view.scope;
      _rolePreset = view.rolePreset;
      _workQueueFocus = view.focus;
      _workQueueSort = view.sort;
      _workQueueOwnerFilter = normalizedOwner;
      _workQueueResolutionFilter = view.resolutionFilter;
      _selectedWorkQueue = null;
      _selectedWorkQueueId = normalizedQueueId;
      _selectedWorkQueueDetailSection = detailSection;
      if (view.isCustom) {
        _customWorkQueueSavedViews = _promoteWorkQueueSavedView(
          _customWorkQueueSavedViews,
          view,
        );
      }
      _searchController.text = query;
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(
      query: query,
      scope: view.scope,
      rolePreset: view.rolePreset,
      workQueueFocus: view.focus,
      workQueueSort: view.sort,
      workQueueOwnerFilter: normalizedOwner,
      selectedWorkQueueId: normalizedQueueId,
      workQueueDetailSection: detailSection,
    );
    _scrollToWorkQueuePanel();
  }

  void _saveCurrentWorkQueueView(AccountingWorkspaceWorkQueue? selectedQueue) {
    final selectedQueueId = _normalizedSelectedWorkQueueId(
      _selectedWorkQueueId ?? selectedQueue?.id,
    );
    final generatedView = AccountingWorkspaceWorkQueueSavedView.custom(
      query: _query,
      scope: _scope,
      rolePreset: _rolePreset,
      focus: _workQueueFocus,
      sort: _workQueueSort,
      ownerFilter: _workQueueOwnerFilter,
      resolutionFilter: _workQueueResolutionFilter,
      selectedQueueId: selectedQueueId,
      selectedQueueTitle: selectedQueue?.title,
      detailSection: _selectedWorkQueueDetailSection,
    );
    final existingView = _workQueueSavedViewById(
      _customWorkQueueSavedViews,
      generatedView.id,
    );
    final customView =
        existingView == null
            ? generatedView
            : generatedView.copyWith(
              label: existingView.label,
              icon: existingView.icon,
            );

    setState(() {
      _customWorkQueueSavedViews = _upsertWorkQueueSavedView(
        _customWorkQueueSavedViews,
        customView,
      );
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar(
      existingView == null ? 'Queue view saved' : 'Queue view updated',
    );
  }

  void _deleteWorkQueueSavedView(
    AccountingWorkspaceWorkQueueSavedView view, {
    bool showUndoSnackBar = true,
  }) {
    if (!view.isCustom) return;

    final nextViews = [
      for (final customView in _customWorkQueueSavedViews)
        if (customView.id != view.id) customView,
    ];
    if (_sameWorkQueueSavedViews(_customWorkQueueSavedViews, nextViews)) {
      return;
    }

    setState(() {
      _customWorkQueueSavedViews =
          List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(nextViews);
      _recordWorkQueueSavedViewAuditEvent(
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.deleted,
          previousLabel: view.label,
          viewId: view.id,
          rolePreset: view.rolePreset,
          occurredAt: DateTime.now(),
          savedView: view,
        ),
      );
      unawaited(_queuePersistWorkspaceState());
    });
    if (showUndoSnackBar) {
      _showFloatingSnackBar(
        'Queue view deleted',
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _restoreWorkQueueSavedView(view),
        ),
      );
    }
  }

  Future<void> _manageWorkQueueSavedViews() async {
    final roleViews = accountingWorkspaceWorkQueueSavedViewsForRole(
      _rolePreset,
      views: _customWorkQueueSavedViews,
    );
    final roleAuditEvents = workQueueSavedViewManagerAuditEventsForRole(
      events: _workQueueSavedViewAuditEvents,
      rolePreset: _rolePreset,
    );
    if (roleViews.isEmpty && roleAuditEvents.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder:
          (context) => AccountingWorkQueueSavedViewManagerDialog(
            views: roleViews,
            auditEvents: roleAuditEvents,
            onRenamed: _renameWorkQueueSavedView,
            onDeleted:
                (view) =>
                    _deleteWorkQueueSavedView(view, showUndoSnackBar: false),
            onRestored:
                (view) => _restoreWorkQueueSavedView(view, showSnackBar: false),
          ),
    );
  }

  void _renameWorkQueueSavedView(AccountingWorkspaceWorkQueueSavedView view) {
    if (!view.isCustom) return;
    final previousLabel =
        _workQueueSavedViewById(_customWorkQueueSavedViews, view.id)?.label ??
        view.label;

    setState(() {
      _customWorkQueueSavedViews = _upsertWorkQueueSavedView(
        _customWorkQueueSavedViews,
        view,
      );
      _recordWorkQueueSavedViewAuditEvent(
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.renamed,
          previousLabel: previousLabel,
          viewId: view.id,
          rolePreset: view.rolePreset,
          nextLabel: view.label,
          occurredAt: DateTime.now(),
          savedView: view,
        ),
      );
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar('Queue view renamed');
  }

  void _restoreWorkQueueSavedView(
    AccountingWorkspaceWorkQueueSavedView view, {
    bool showSnackBar = true,
  }) {
    if (!view.isCustom) return;

    setState(() {
      _customWorkQueueSavedViews = _upsertWorkQueueSavedView(
        _customWorkQueueSavedViews,
        view,
      );
      _recordWorkQueueSavedViewAuditEvent(
        WorkQueueSavedViewManagerAuditEvent(
          action: WorkQueueSavedViewManagerAuditAction.restored,
          previousLabel: view.label,
          viewId: view.id,
          rolePreset: view.rolePreset,
          occurredAt: DateTime.now(),
          savedView: view,
        ),
      );
      unawaited(_queuePersistWorkspaceState());
    });
    if (showSnackBar) _showFloatingSnackBar('Queue view restored');
  }

  void _recordWorkQueueSavedViewAuditEvent(
    WorkQueueSavedViewManagerAuditEvent event,
  ) {
    _workQueueSavedViewAuditEvents =
        List<WorkQueueSavedViewManagerAuditEvent>.unmodifiable(
          [
            event,
            ..._workQueueSavedViewAuditEvents,
          ].take(_maxWorkQueueSavedViewAuditEvents),
        );
  }

  void _reviewCloseGate(AccountingWorkspaceCloseCommandCenterGateCheck gate) {
    if (gate.status == AccountingWorkspaceCloseCommandCenterGateStatus.clear) {
      return;
    }

    if (gate.id == _activeCloseGateIdForCurrentState()) {
      _clearCloseGateReview();
      return;
    }

    final focus = _workQueueFocusForCloseGate(gate);
    final sort = _workQueueSortForCloseGate(gate);
    setState(() {
      _workQueueFocus = focus;
      _workQueueSort = sort;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(workQueueFocus: focus, workQueueSort: sort);
    _scrollToWorkQueuePanel();
  }

  void _clearCloseGateReview() {
    setState(() {
      _workQueueFocus = AccountingWorkspaceWorkQueueFocus.all;
      _workQueueSort = AccountingWorkspaceWorkQueueSort.workflow;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(
      workQueueFocus: AccountingWorkspaceWorkQueueFocus.all,
      workQueueSort: AccountingWorkspaceWorkQueueSort.workflow,
    );
    _scrollToWorkQueuePanel();
  }

  void _clearSelectedWorkQueue() {
    setState(() {
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute();
  }

  void _setSelectedWorkQueueState(AccountingWorkspaceWorkQueue queue) {
    if (_selectedWorkQueueId != queue.id) {
      _selectedWorkQueueDetailSection =
          AccountingWorkspaceWorkQueueDetailSection.overview;
    }
    _selectedWorkQueue = queue;
    _selectedWorkQueueId = queue.id;
  }

  void _clearWorkQueueSelectionState({bool keepSelectedId = false}) {
    _selectedWorkQueue = null;
    if (!keepSelectedId) {
      _selectedWorkQueueId = null;
      _selectedWorkQueueDetailSection =
          AccountingWorkspaceWorkQueueDetailSection.overview;
    }
  }

  void _resetWorkQueueResolutionFilter() {
    _workQueueResolutionFilter =
        AccountingWorkspaceWorkQueueResolutionFilter.all;
  }

  String? _normalizedWorkQueueOwnerFilter(String? value) {
    final normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) return null;

    return normalizedValue;
  }

  String? _normalizedSelectedWorkQueueId(String? value) {
    final normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) return null;

    return normalizedValue;
  }

  void _updateSelectedWorkQueueDetailSection(
    AccountingWorkspaceWorkQueueDetailSection section,
  ) {
    setState(() {
      _selectedWorkQueueDetailSection = section;
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(workQueueDetailSection: section);
  }

  void _acknowledgeWorkQueueActivityOwner(AccountingWorkspaceWorkQueue queue) {
    _updateWorkQueueActivityActionState(
      queue: queue,
      update: (state) => state.copyWith(ownerAcknowledged: true),
      message: 'Owner acknowledgement captured',
    );
  }

  void _receiveWorkQueueActivityEvidence(AccountingWorkspaceWorkQueue queue) {
    _updateWorkQueueActivityActionState(
      queue: queue,
      update: (state) => state.copyWith(evidenceReceived: true),
      message: 'Evidence receipt captured',
    );
  }

  void _logWorkQueueActivityEscalation(AccountingWorkspaceWorkQueue queue) {
    _updateWorkQueueActivityActionState(
      queue: queue,
      update: (state) => state.copyWith(escalationLogged: true),
      message: 'Escalation outcome logged',
    );
  }

  void _addWorkQueueEvidenceLink(
    AccountingWorkspaceWorkQueue queue,
    AccountingWorkspaceWorkQueueEvidenceLinkDraft draft,
  ) {
    if (!draft.canSubmit) return;

    final link = AccountingWorkspaceWorkQueueEvidenceLink.create(
      queueId: queue.id,
      label: draft.label,
      reference: draft.reference,
      addedByLabel: _rolePreset.label,
      addedAt: DateTime.now(),
      type: draft.type,
    );

    setState(() {
      final nextLinks = [link, ..._workQueueEvidenceLinksFor(queue.id)]
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
      _workQueueEvidenceLinks[queue
          .id] = List<AccountingWorkspaceWorkQueueEvidenceLink>.unmodifiable(
        nextLinks,
      );
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar('Evidence link added');
  }

  void _updateWorkQueueEvidenceReviewState(
    AccountingWorkspaceWorkQueue queue,
    AccountingWorkspaceWorkQueueEvidenceLink link,
    AccountingWorkspaceWorkQueueEvidenceReviewDraft draft,
  ) {
    if (!draft.canSubmit) return;

    setState(() {
      _workQueueEvidenceReviewStates[link
          .id] = AccountingWorkspaceWorkQueueEvidenceReviewState(
        queueId: queue.id,
        linkId: link.id,
        decision: draft.decision,
        reviewNote: draft.normalizedReviewNote,
        reviewedByLabel: _rolePreset.label,
        reviewedAt: DateTime.now(),
      );
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar(
      draft.decision ==
              AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted
          ? 'Evidence link accepted'
          : 'Evidence link marked for rework',
    );
  }

  void _addWorkQueueExecutionNote(
    AccountingWorkspaceWorkQueue queue,
    AccountingWorkspaceWorkQueueNoteDraft draft,
  ) {
    if (!draft.canSubmit) return;

    final note = AccountingWorkspaceWorkQueueNote.create(
      queueId: queue.id,
      authorLabel: _rolePreset.label,
      body: draft.body,
      createdAt: DateTime.now(),
      type: draft.type,
    );

    setState(() {
      final nextNotes = [note, ..._workQueueNotesFor(queue.id)]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _workQueueNotes[queue
          .id] = List<AccountingWorkspaceWorkQueueNote>.unmodifiable(nextNotes);
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar('Execution note added');
  }

  void _approveWorkQueueReviewerSignOff(AccountingWorkspaceWorkQueue queue) {
    _updateWorkQueueReviewerSignOffState(
      queue: queue,
      decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
      message: 'Reviewer approval captured',
    );
  }

  void _returnWorkQueueReviewerSignOff(AccountingWorkspaceWorkQueue queue) {
    _updateWorkQueueReviewerSignOffState(
      queue: queue,
      decision: AccountingWorkspaceWorkQueueReviewerDecision.returned,
      message: 'Reviewer return captured',
    );
  }

  void _blockWorkQueueReviewerSignOff(AccountingWorkspaceWorkQueue queue) {
    _updateWorkQueueReviewerSignOffState(
      queue: queue,
      decision: AccountingWorkspaceWorkQueueReviewerDecision.blocked,
      message: 'Reviewer blocker captured',
    );
  }

  void _clearWorkQueueResolution(AccountingWorkspaceWorkQueue queue) {
    setState(() {
      _workQueueResolutionStates[queue.id] = _resolutionStateFor(
        queue.id,
      ).copyWith(cleared: true);
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar('Work queue cleared');
  }

  void _updateWorkQueueActivityActionState({
    required AccountingWorkspaceWorkQueue queue,
    required AccountingWorkspaceWorkQueueActivityActionState Function(
      AccountingWorkspaceWorkQueueActivityActionState state,
    )
    update,
    required String message,
  }) {
    setState(() {
      final currentState = _activityActionStateFor(queue.id);
      _workQueueActivityActionStates[queue.id] = update(currentState);
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar(message);
  }

  void _updateWorkQueueReviewerSignOffState({
    required AccountingWorkspaceWorkQueue queue,
    required AccountingWorkspaceWorkQueueReviewerDecision decision,
    required String message,
  }) {
    setState(() {
      _workQueueReviewerSignOffStates[queue.id] = _reviewerSignOffStateFor(
        queue.id,
      ).copyWith(decision: decision);
      unawaited(_queuePersistWorkspaceState());
    });
    _showFloatingSnackBar(message);
  }

  void _openWorkQueue(AccountingWorkspaceWorkQueue queue) {
    context.go(queue.path);
  }

  void _openPeriodCloseWorkflow() {
    context.go(AccountingPath.periodClose);
  }

  Future<void> _copyWorkQueueBrief(
    AccountingWorkspaceWorkQueueDetail detail,
  ) async {
    final actionState = _activityActionStateFor(detail.queueId);
    final reviewerSignOffState = _reviewerSignOffStateFor(detail.queueId);
    final resolutionState = _resolutionStateFor(detail.queueId);
    final clearanceChecklist = _clearanceActionSync.sync(
      checklist: detail.clearanceChecklist,
      actionState: actionState,
      reviewerSignOffState: reviewerSignOffState,
      evidenceReadiness: _workQueueEvidenceReadinessFor(detail),
    );
    final ownerBrief = _ownerBriefComposer.compose(
      detail: detail,
      clearanceChecklist: clearanceChecklist,
      actionState: actionState,
      reviewerSignOffState: reviewerSignOffState,
      resolutionState: resolutionState,
    );
    await Clipboard.setData(ClipboardData(text: ownerBrief));
    if (!mounted) return;

    _showFloatingSnackBar('Work queue brief copied');
  }

  Future<void> _copyWorkQueueEvidenceRequest(
    AccountingWorkspaceWorkQueueDetail detail,
  ) async {
    await Clipboard.setData(
      ClipboardData(text: detail.evidenceRequest.requestBody),
    );
    if (!mounted) return;

    _showFloatingSnackBar('Evidence request copied');
  }

  Future<void> _copyWorkQueueLink(AccountingWorkspaceWorkQueue queue) async {
    await Clipboard.setData(
      ClipboardData(text: _workspacePath(selectedWorkQueueId: queue.id)),
    );
    if (!mounted) return;

    _showFloatingSnackBar('Work queue link copied');
  }

  Future<void> _copyWorkQueueActivityAuditBrief(
    AccountingWorkspaceWorkQueueDetail detail,
  ) async {
    final actionState = _activityActionStateFor(detail.queueId);
    final evidenceLinks = _workQueueEvidenceLinksFor(detail.queueId);
    final evidenceReadiness =
        AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
          queueId: detail.queueId,
          request: detail.evidenceRequest,
          links: evidenceLinks,
          reviewStates:
              _workQueueEvidenceReviewStatesFor(detail.queueId).values,
        );
    final notes = _workQueueNotesFor(detail.queueId);
    await Clipboard.setData(
      ClipboardData(
        text: [
          detail.activityTrail.auditTrailBriefFor(actionState),
          evidenceReadiness.briefFor(detail.activityTrail.queueTitle),
          accountingWorkspaceWorkQueueEvidenceLinksBrief(
            queueTitle: detail.activityTrail.queueTitle,
            links: evidenceLinks,
            reviewStates:
                _workQueueEvidenceReviewStatesFor(detail.queueId).values,
          ),
          accountingWorkspaceWorkQueueNotesBrief(
            queueTitle: detail.activityTrail.queueTitle,
            notes: notes,
          ),
        ].join('\n\n'),
      ),
    );
    if (!mounted) return;

    _showFloatingSnackBar('Activity audit brief copied');
  }

  Future<void> _copyWorkQueueEvidenceLinks(
    AccountingWorkspaceWorkQueue queue,
  ) async {
    final detail = widget.workQueueService.detailFor(queue);
    await Clipboard.setData(
      ClipboardData(
        text: accountingWorkspaceWorkQueueEvidenceLinksBrief(
          queueTitle: detail.activityTrail.queueTitle,
          links: _workQueueEvidenceLinksFor(queue.id),
          reviewStates: _workQueueEvidenceReviewStatesFor(queue.id).values,
        ),
      ),
    );
    if (!mounted) return;

    _showFloatingSnackBar('Evidence links copied');
  }

  Future<void> _copyWorkQueueExecutionNotes(
    AccountingWorkspaceWorkQueue queue,
  ) async {
    final detail = widget.workQueueService.detailFor(queue);
    await Clipboard.setData(
      ClipboardData(
        text: accountingWorkspaceWorkQueueNotesBrief(
          queueTitle: detail.activityTrail.queueTitle,
          notes: _workQueueNotesFor(queue.id),
        ),
      ),
    );
    if (!mounted) return;

    _showFloatingSnackBar('Execution notes copied');
  }

  Future<void> _copyWorkQueueClearancePlan(
    AccountingWorkspaceWorkQueueDetail detail,
  ) async {
    final actionState = _activityActionStateFor(detail.queueId);
    final reviewerSignOffState = _reviewerSignOffStateFor(detail.queueId);
    final clearanceChecklist = _clearanceActionSync.sync(
      checklist: detail.clearanceChecklist,
      actionState: actionState,
      reviewerSignOffState: reviewerSignOffState,
      evidenceReadiness: _workQueueEvidenceReadinessFor(detail),
    );
    await Clipboard.setData(
      ClipboardData(text: clearanceChecklist.clearanceBrief),
    );
    if (!mounted) return;

    _showFloatingSnackBar('Clearance plan copied');
  }

  Future<void> _copyCloseReadinessBrief(
    AccountingWorkspaceWorkQueueCloseReadiness readiness,
  ) async {
    await Clipboard.setData(ClipboardData(text: readiness.actionPlanBrief));
    if (!mounted) return;

    _showFloatingSnackBar('Close readiness plan copied');
  }

  Future<void> _copyWorkQueueEvidenceExceptionRegister(
    AccountingWorkspaceWorkQueueEvidenceExceptionRegister register,
  ) async {
    await Clipboard.setData(ClipboardData(text: register.exceptionBrief));
    if (!mounted) return;

    _showFloatingSnackBar('Evidence exception brief copied');
  }

  Future<void> _copyWorkQueueResolutionSummaryBrief(
    AccountingWorkspaceWorkQueueResolutionSummary summary, {
    required AccountingWorkspaceWorkQueueResolutionFilter filter,
    AccountingWorkspaceWorkQueueResolutionNextAction? nextAction,
    Iterable<AccountingWorkspaceWorkQueueResolutionBriefItem> briefItems =
        const [],
    Iterable<AccountingWorkspaceWorkQueueEvidenceReadiness> evidenceReadiness =
        const [],
    Map<String, String> evidenceQueueTitlesById = const {},
  }) async {
    await Clipboard.setData(
      ClipboardData(
        text: _closePacketComposer.compose(
          summary: summary,
          filter: filter,
          rolePreset: _rolePreset,
          scope: _scope,
          query: _query,
          generatedAt: DateTime.now(),
          nextAction: nextAction,
          briefItems: briefItems,
          evidenceReadiness: evidenceReadiness,
          evidenceQueueTitlesById: evidenceQueueTitlesById,
        ),
      ),
    );
    if (!mounted) return;

    _showFloatingSnackBar(
      filter.isDefault
          ? 'Close packet copied'
          : '${filter.label} close packet copied',
    );
  }

  Future<void> _copyCloseCommandCenterBrief(
    AccountingWorkspaceCloseCommandCenter commandCenter,
  ) async {
    await Clipboard.setData(ClipboardData(text: commandCenter.decisionBrief));
    if (!mounted) return;

    _showFloatingSnackBar('Close decision brief copied');
  }

  Future<void> _copyPeriodCloseExecutionBrief(
    AccountingWorkspacePeriodCloseExecution execution,
  ) async {
    await Clipboard.setData(ClipboardData(text: execution.executionBrief));
    if (!mounted) return;

    _showFloatingSnackBar('Period close execution brief copied');
  }

  Future<void> _copyPeriodCloseOwnerHandoff(
    AccountingWorkspacePeriodCloseExecutionOwnerHandoff handoff,
  ) async {
    await Clipboard.setData(ClipboardData(text: handoff.handoffBrief));
    if (!mounted) return;

    _showFloatingSnackBar('Owner handoff brief copied');
  }

  void _updateWorkQueueFocus(AccountingWorkspaceWorkQueueFocus focus) {
    setState(() {
      _workQueueFocus = focus;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(workQueueFocus: focus);
  }

  void _updateWorkQueueSort(AccountingWorkspaceWorkQueueSort sort) {
    setState(() {
      _workQueueSort = sort;
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(workQueueSort: sort);
  }

  void _updateWorkQueueResolutionFilter(
    AccountingWorkspaceWorkQueueResolutionFilter filter,
  ) {
    setState(() {
      _workQueueResolutionFilter = filter;
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _scrollToWorkQueuePanel();
  }

  void _updateWorkQueueOwnerFilter(String? ownerLabel) {
    final normalizedOwner = _normalizedWorkQueueOwnerFilter(ownerLabel);
    setState(() {
      _workQueueOwnerFilter = normalizedOwner;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(workQueueOwnerFilter: normalizedOwner);
  }

  void _resetWorkQueueViewContext() {
    setState(() {
      _workQueueFocus = AccountingWorkspaceWorkQueueFocus.all;
      _workQueueSort = AccountingWorkspaceWorkQueueSort.workflow;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(
      workQueueFocus: AccountingWorkspaceWorkQueueFocus.all,
      workQueueSort: AccountingWorkspaceWorkQueueSort.workflow,
    );
    _scrollToWorkQueuePanel();
  }

  void _reviewOwnerHandoff(String ownerLabel) {
    final normalizedOwner = _normalizedWorkQueueOwnerFilter(ownerLabel);
    if (normalizedOwner == null) return;

    setState(() {
      _workQueueFocus = AccountingWorkspaceWorkQueueFocus.all;
      _workQueueOwnerFilter = normalizedOwner;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(
      workQueueFocus: AccountingWorkspaceWorkQueueFocus.all,
      workQueueOwnerFilter: normalizedOwner,
    );
    _scrollToWorkQueuePanel();
  }

  void _reviewPeriodCloseExecutionStep(
    AccountingWorkspacePeriodCloseExecutionStep step,
    AccountingWorkspaceCloseCommandCenter commandCenter,
  ) {
    switch (step.id) {
      case 'blockers':
      case 'evidence':
      case 'posting':
        final gate = _closeGateById(commandCenter, step.id);
        if (gate == null) return;
        _reviewCloseGate(gate);
      case 'lock-approval':
        _openPeriodCloseWorkflow();
      default:
        return;
    }
  }

  AccountingWorkspaceCloseCommandCenterGateCheck? _closeGateById(
    AccountingWorkspaceCloseCommandCenter commandCenter,
    String gateId,
  ) {
    for (final gate in commandCenter.gateChecks) {
      if (gate.id == gateId) return gate;
    }

    return null;
  }

  void _scrollToSection(AccountingMenuSection section) {
    final sectionContext = _sectionKey(section).currentContext;
    if (sectionContext == null) return;

    unawaited(
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.04,
      ),
    );
  }

  void _scrollToWorkQueuePanel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final panelContext = _workQueuePanelKey.currentContext;
      if (panelContext == null) return;

      unawaited(
        Scrollable.ensureVisible(
          panelContext,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.04,
        ),
      );
    });
  }

  AccountingWorkspaceWorkQueueFocus _workQueueFocusForCloseGate(
    AccountingWorkspaceCloseCommandCenterGateCheck gate,
  ) {
    switch (gate.id) {
      case 'blockers':
        return AccountingWorkspaceWorkQueueFocus.blocked;
      case 'evidence':
      case 'posting':
      default:
        return AccountingWorkspaceWorkQueueFocus.all;
    }
  }

  AccountingWorkspaceWorkQueueSort _workQueueSortForCloseGate(
    AccountingWorkspaceCloseCommandCenterGateCheck gate,
  ) {
    switch (gate.id) {
      case 'posting':
        return AccountingWorkspaceWorkQueueSort.largest;
      case 'blockers':
      case 'evidence':
      default:
        return AccountingWorkspaceWorkQueueSort.urgent;
    }
  }

  AccountingWorkspaceCloseCommandCenterGateCheck? _activeCloseGate(
    AccountingWorkspaceCloseCommandCenter commandCenter,
  ) {
    final candidateGateId = _activeCloseGateIdForCurrentState();
    if (candidateGateId == null) return null;

    for (final gate in commandCenter.gateChecks) {
      if (gate.id == candidateGateId &&
          gate.status !=
              AccountingWorkspaceCloseCommandCenterGateStatus.clear) {
        return gate;
      }
    }

    return null;
  }

  String? _activeCloseGateIdForCurrentState() {
    if (_workQueueFocus == AccountingWorkspaceWorkQueueFocus.blocked &&
        _workQueueSort == AccountingWorkspaceWorkQueueSort.urgent) {
      return 'blockers';
    }
    if (_workQueueFocus == AccountingWorkspaceWorkQueueFocus.all &&
        _workQueueSort == AccountingWorkspaceWorkQueueSort.urgent) {
      return 'evidence';
    }
    if (_workQueueFocus == AccountingWorkspaceWorkQueueFocus.all &&
        _workQueueSort == AccountingWorkspaceWorkQueueSort.largest) {
      return 'posting';
    }

    return null;
  }

  GlobalKey _sectionKey(AccountingMenuSection section) {
    return _sectionKeys.putIfAbsent(section.name, GlobalKey.new);
  }

  void _syncWorkspaceRoute({
    String? query,
    AccountingMenuSearchScope? scope,
    AccountingWorkspaceRolePreset? rolePreset,
    AccountingWorkspaceWorkQueueFocus? workQueueFocus,
    AccountingWorkspaceWorkQueueSort? workQueueSort,
    String? workQueueOwnerFilter,
    String? selectedWorkQueueId,
    AccountingWorkspaceWorkQueueDetailSection? workQueueDetailSection,
  }) {
    final router = GoRouter.maybeOf(context);
    if (router == null) return;

    final effectiveScope = scope ?? _scope;
    router.go(
      _workspacePath(
        query: query ?? _query,
        scope: effectiveScope,
        rolePreset: rolePreset ?? _rolePreset,
        workQueueFocus: workQueueFocus ?? _workQueueFocus,
        workQueueSort: workQueueSort ?? _workQueueSort,
        workQueueOwnerFilter: workQueueOwnerFilter ?? _workQueueOwnerFilter,
        selectedWorkQueueId: selectedWorkQueueId ?? _selectedWorkQueueId,
        workQueueDetailSection:
            workQueueDetailSection ?? _selectedWorkQueueDetailSection,
      ),
    );
  }

  Future<void> _copyWorkspaceLink() async {
    final path = _workspacePath();
    await Clipboard.setData(ClipboardData(text: path));
    if (!mounted) return;

    _showFloatingSnackBar('Accounting workspace link copied');
  }

  void _showFloatingSnackBar(String message, {SnackBarAction? action}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        action: action,
      ),
    );
  }

  String _workspacePath({
    String? query,
    AccountingMenuSearchScope? scope,
    AccountingWorkspaceRolePreset? rolePreset,
    AccountingWorkspaceWorkQueueFocus? workQueueFocus,
    AccountingWorkspaceWorkQueueSort? workQueueSort,
    String? workQueueOwnerFilter,
    String? selectedWorkQueueId,
    AccountingWorkspaceWorkQueueDetailSection? workQueueDetailSection,
  }) {
    return widget.routeService.buildPath(
      query: query ?? _query,
      scope: scope ?? _scope,
      rolePreset: rolePreset ?? _rolePreset,
      workQueueFocus: workQueueFocus ?? _workQueueFocus,
      workQueueSort: workQueueSort ?? _workQueueSort,
      workQueueOwnerFilter: workQueueOwnerFilter ?? _workQueueOwnerFilter,
      selectedWorkQueueId: selectedWorkQueueId ?? _selectedWorkQueueId,
      selectedWorkQueueDetailSection:
          workQueueDetailSection ?? _selectedWorkQueueDetailSection,
    );
  }

  void _applySavedView(AccountingMenuSavedView view) {
    setState(() {
      _query = view.query.trim();
      _scope = view.scope;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      _searchController.text = _query;
      _rememberRecentView(AccountingWorkspaceRecentView.fromSavedView(view));
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(query: view.query, scope: view.scope);
  }

  void _applyRecentView(AccountingWorkspaceRecentView view) {
    setState(() {
      _query = view.query.trim();
      _scope = view.scope;
      _workQueueOwnerFilter = null;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      _searchController.text = _query;
      _rememberRecentView(view);
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(query: view.query, scope: view.scope);
  }

  void _commitSearch(String value) {
    final query = value.trim();
    setState(() {
      _query = query;
      _resetWorkQueueResolutionFilter();
      _clearWorkQueueSelectionState();
      _searchController.text = _query;
      _rememberRecentView(
        AccountingWorkspaceRecentView.fromSearch(query: _query, scope: _scope),
      );
      unawaited(_queuePersistWorkspaceState());
    });
    _syncWorkspaceRoute(query: query);
  }

  void _clearRecentViews() {
    setState(() {
      _recentViews = widget.recentViewService.clear();
      unawaited(_queuePersistWorkspaceState());
    });
  }

  String? _effectiveWorkQueueOwnerFilter(
    AccountingWorkspaceWorkQueueOwnerSummary ownerSummary,
  ) {
    return _validatedWorkQueueOwnerFilter(
      ownerFilter: _workQueueOwnerFilter,
      ownerSummary: ownerSummary,
    );
  }

  String? _validatedWorkQueueOwnerFilter({
    required String? ownerFilter,
    required AccountingWorkspaceWorkQueueOwnerSummary ownerSummary,
  }) {
    final selectedOwner = _normalizedWorkQueueOwnerFilter(ownerFilter);
    if (selectedOwner == null || selectedOwner.isEmpty) return null;

    final hasOwner = ownerSummary.owners.any(
      (owner) =>
          owner.ownerLabel.trim().toLowerCase() == selectedOwner.toLowerCase(),
    );

    return hasOwner ? selectedOwner : null;
  }

  AccountingWorkspaceWorkQueueOwnerSummary _ownerSummaryForRolePreset(
    AccountingWorkspaceRolePreset rolePreset,
  ) {
    return widget.workQueueService.summarizeOwners(
      widget.workQueueService.queuesFor(
        rolePreset: rolePreset,
        query: _query,
        scope: _scope,
      ),
    );
  }

  AccountingWorkspaceWorkQueue? _effectiveSelectedWorkQueue(
    List<AccountingWorkspaceWorkQueue> queues,
  ) {
    final selectedQueueId = _normalizedSelectedWorkQueueId(
      _selectedWorkQueueId ?? _selectedWorkQueue?.id,
    );
    if (selectedQueueId == null) return null;

    for (final queue in queues) {
      if (queue.id == selectedQueueId) return queue;
    }

    return null;
  }

  String? _validatedSelectedWorkQueueId({
    required String? queueId,
    required AccountingWorkspaceRolePreset rolePreset,
    required AccountingWorkspaceWorkQueueFocus workQueueFocus,
    required String? ownerFilter,
    required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
    required Map<String, AccountingWorkspaceWorkQueueActivityActionState>
    actionStates,
    required Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState>
    reviewerSignOffStates,
    required Map<String, AccountingWorkspaceWorkQueueResolutionState>
    resolutionStates,
  }) {
    final selectedQueueId = _normalizedSelectedWorkQueueId(queueId);
    if (selectedQueueId == null) return null;

    final queues = widget.workQueueService.queuesFor(
      rolePreset: rolePreset,
      query: _query,
      scope: _scope,
    );
    final focusedQueues = widget.workQueueService.filterByFocus(
      queues,
      workQueueFocus,
    );
    final ownerFilteredQueues = widget.workQueueService.filterByOwner(
      focusedQueues,
      ownerFilter,
    );
    final detailsByQueueId = {
      for (final queue in queues)
        queue.id: widget.workQueueService.detailFor(queue),
    };
    final resolutionFilteredQueues = _resolutionSummaryService
        .filterByResolution(
          queues: ownerFilteredQueues,
          filter: resolutionFilter,
          detailsByQueueId: detailsByQueueId,
          actionStates: actionStates,
          reviewerSignOffStates: reviewerSignOffStates,
          resolutionStates: resolutionStates,
        );

    for (final queue in resolutionFilteredQueues) {
      if (queue.id == selectedQueueId) return selectedQueueId;
    }

    return null;
  }

  AccountingWorkspaceWorkQueueActivityActionState _activityActionStateFor(
    String queueId,
  ) {
    return _workQueueActivityActionStates[queueId] ??
        AccountingWorkspaceWorkQueueActivityActionState(queueId: queueId);
  }

  AccountingWorkspaceWorkQueueReviewerSignOffState _reviewerSignOffStateFor(
    String queueId,
  ) {
    return _workQueueReviewerSignOffStates[queueId] ??
        AccountingWorkspaceWorkQueueReviewerSignOffState(queueId: queueId);
  }

  AccountingWorkspaceWorkQueueResolutionState _resolutionStateFor(
    String queueId,
  ) {
    return _workQueueResolutionStates[queueId] ??
        AccountingWorkspaceWorkQueueResolutionState(queueId: queueId);
  }

  List<AccountingWorkspaceWorkQueueNote> _workQueueNotesFor(String queueId) {
    final notes = [...?_workQueueNotes[queueId]]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return List<AccountingWorkspaceWorkQueueNote>.unmodifiable(notes);
  }

  List<AccountingWorkspaceWorkQueueEvidenceLink> _workQueueEvidenceLinksFor(
    String queueId,
  ) {
    final links = [...?_workQueueEvidenceLinks[queueId]]
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

    return List<AccountingWorkspaceWorkQueueEvidenceLink>.unmodifiable(links);
  }

  AccountingWorkspaceWorkQueueEvidenceReadiness _workQueueEvidenceReadinessFor(
    AccountingWorkspaceWorkQueueDetail detail,
  ) {
    return AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
      queueId: detail.queueId,
      request: detail.evidenceRequest,
      links: _workQueueEvidenceLinksFor(detail.queueId),
      reviewStates: _workQueueEvidenceReviewStatesFor(detail.queueId).values,
    );
  }

  Map<String, AccountingWorkspaceWorkQueueEvidenceReviewState>
  _workQueueEvidenceReviewStatesFor(String queueId) {
    return Map<
      String,
      AccountingWorkspaceWorkQueueEvidenceReviewState
    >.unmodifiable({
      for (final entry in _workQueueEvidenceReviewStates.entries)
        if (entry.value.queueId == queueId) entry.key: entry.value,
    });
  }

  AccountingWorkspaceWorkQueue? _workQueueById(
    Iterable<AccountingWorkspaceWorkQueue> queues,
    String? queueId,
  ) {
    if (queueId == null) return null;

    for (final queue in queues) {
      if (queue.id == queueId) return queue;
    }

    return null;
  }

  void _rememberRecentView(AccountingWorkspaceRecentView view) {
    final nextViews = widget.recentViewService.record(_recentViews, view);
    if (_sameRecentViews(_recentViews, nextViews)) return;

    _recentViews = nextViews;
    unawaited(_queuePersistWorkspaceState());
  }

  Future<void> _hydrateRecentViews() async {
    final repository = widget.recentViewRepository;
    if (repository == null) return;

    final restoredSnapshot = await repository.loadSnapshot();
    if (!mounted) return;

    final restoredViews = restoredSnapshot.views;
    final restoredWorkQueueSavedViews = restoredSnapshot.workQueueSavedViews;
    final restoredWorkQueueSavedViewAuditEvents =
        restoredSnapshot.workQueueSavedViewAuditEvents;
    var mergedViews = restoredViews;
    for (final view in _recentViews.reversed) {
      mergedViews = widget.recentViewService.record(mergedViews, view);
    }
    final hydratedRolePreset =
        widget.preferInitialRolePreset
            ? _rolePreset
            : restoredSnapshot.rolePreset ?? _rolePreset;
    final hydratedWorkQueueFocus =
        widget.preferInitialWorkQueueFocus
            ? _workQueueFocus
            : restoredSnapshot.workQueueFocus ?? _workQueueFocus;
    final hydratedWorkQueueSort =
        widget.preferInitialWorkQueueSort
            ? _workQueueSort
            : restoredSnapshot.workQueueSort ?? _workQueueSort;
    final hydratedWorkQueueResolutionFilter =
        restoredSnapshot.workQueueResolutionFilter ??
        AccountingWorkspaceWorkQueueResolutionFilter.all;
    final restoredWorkQueueOwnerFilter = _normalizedWorkQueueOwnerFilter(
      restoredSnapshot.workQueueOwnerFilter,
    );
    final restoredActionStatesByQueueId = {
      for (final state in restoredSnapshot.workQueueActivityActionStates)
        state.queueId: state,
    };
    final restoredReviewerSignOffStatesByQueueId = {
      for (final state in restoredSnapshot.workQueueReviewerSignOffStates)
        state.queueId: state,
    };
    final restoredResolutionStatesByQueueId = {
      for (final state in restoredSnapshot.workQueueResolutionStates)
        state.queueId: state,
    };
    final restoredEvidenceLinksByQueueId =
        <String, List<AccountingWorkspaceWorkQueueEvidenceLink>>{};
    for (final link in restoredSnapshot.workQueueEvidenceLinks) {
      final queueLinks =
          restoredEvidenceLinksByQueueId[link.queueId] ??
          <AccountingWorkspaceWorkQueueEvidenceLink>[];
      restoredEvidenceLinksByQueueId[link.queueId] = [...queueLinks, link]
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }
    final restoredEvidenceReviewStatesByLinkId = {
      for (final state in restoredSnapshot.workQueueEvidenceReviewStates)
        state.linkId: state,
    };
    final restoredNotesByQueueId =
        <String, List<AccountingWorkspaceWorkQueueNote>>{};
    for (final note in restoredSnapshot.workQueueNotes) {
      final queueNotes =
          restoredNotesByQueueId[note.queueId] ??
          <AccountingWorkspaceWorkQueueNote>[];
      restoredNotesByQueueId[note.queueId] = [...queueNotes, note]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    final hasInitialWorkQueueOwnerFilter = _workQueueOwnerFilter != null;
    final candidateWorkQueueOwnerFilter =
        hasInitialWorkQueueOwnerFilter || widget.preferInitialRolePreset
            ? _workQueueOwnerFilter
            : restoredWorkQueueOwnerFilter ?? _workQueueOwnerFilter;
    final hydratedWorkQueueOwnerFilter = _validatedWorkQueueOwnerFilter(
      ownerFilter: candidateWorkQueueOwnerFilter,
      ownerSummary: _ownerSummaryForRolePreset(hydratedRolePreset),
    );
    final hasInitialSelectedWorkQueue = _selectedWorkQueueId != null;
    final candidateSelectedWorkQueueId =
        hasInitialSelectedWorkQueue
            ? _selectedWorkQueueId
            : restoredSnapshot.selectedWorkQueueId;
    final hydratedSelectedWorkQueueId = _validatedSelectedWorkQueueId(
      queueId: candidateSelectedWorkQueueId,
      rolePreset: hydratedRolePreset,
      workQueueFocus: hydratedWorkQueueFocus,
      ownerFilter: hydratedWorkQueueOwnerFilter,
      resolutionFilter: hydratedWorkQueueResolutionFilter,
      actionStates: restoredActionStatesByQueueId,
      reviewerSignOffStates: restoredReviewerSignOffStatesByQueueId,
      resolutionStates: restoredResolutionStatesByQueueId,
    );
    final hydratedSelectedWorkQueueDetailSection =
        hydratedSelectedWorkQueueId == null
            ? AccountingWorkspaceWorkQueueDetailSection.overview
            : hasInitialSelectedWorkQueue
            ? _selectedWorkQueueDetailSection
            : restoredSnapshot.selectedWorkQueueDetailSection ??
                AccountingWorkspaceWorkQueueDetailSection.overview;

    setState(() {
      _rolePreset = hydratedRolePreset;
      _workQueueFocus = hydratedWorkQueueFocus;
      _workQueueSort = hydratedWorkQueueSort;
      _workQueueOwnerFilter = hydratedWorkQueueOwnerFilter;
      _workQueueResolutionFilter = hydratedWorkQueueResolutionFilter;
      _selectedWorkQueueId = hydratedSelectedWorkQueueId;
      _selectedWorkQueueDetailSection = hydratedSelectedWorkQueueDetailSection;
      _recentViews = mergedViews;
      _customWorkQueueSavedViews = restoredWorkQueueSavedViews;
      _workQueueSavedViewAuditEvents = restoredWorkQueueSavedViewAuditEvents;
      _workQueueActivityActionStates
        ..clear()
        ..addAll(restoredActionStatesByQueueId);
      _workQueueReviewerSignOffStates
        ..clear()
        ..addAll(restoredReviewerSignOffStatesByQueueId);
      _workQueueResolutionStates
        ..clear()
        ..addAll(restoredResolutionStatesByQueueId);
      _workQueueEvidenceLinks
        ..clear()
        ..addAll({
          for (final entry in restoredEvidenceLinksByQueueId.entries)
            entry.key:
                List<AccountingWorkspaceWorkQueueEvidenceLink>.unmodifiable(
                  entry.value,
                ),
        });
      _workQueueEvidenceReviewStates
        ..clear()
        ..addAll(restoredEvidenceReviewStatesByLinkId);
      _workQueueNotes
        ..clear()
        ..addAll({
          for (final entry in restoredNotesByQueueId.entries)
            entry.key: List<AccountingWorkspaceWorkQueueNote>.unmodifiable(
              entry.value,
            ),
        });
    });

    final restoredWorkQueueFocus =
        restoredSnapshot.workQueueFocus ??
        AccountingWorkspaceWorkQueueFocus.all;
    final restoredWorkQueueSort =
        restoredSnapshot.workQueueSort ??
        AccountingWorkspaceWorkQueueSort.workflow;
    final restoredWorkQueueResolutionFilter =
        restoredSnapshot.workQueueResolutionFilter ??
        AccountingWorkspaceWorkQueueResolutionFilter.all;
    if (restoredSnapshot.rolePreset != hydratedRolePreset ||
        restoredWorkQueueFocus != hydratedWorkQueueFocus ||
        restoredWorkQueueSort != hydratedWorkQueueSort ||
        restoredWorkQueueOwnerFilter != hydratedWorkQueueOwnerFilter ||
        restoredSnapshot.selectedWorkQueueId != hydratedSelectedWorkQueueId ||
        (hydratedSelectedWorkQueueId == null
                ? null
                : restoredSnapshot.selectedWorkQueueDetailSection ??
                    AccountingWorkspaceWorkQueueDetailSection.overview) !=
            (hydratedSelectedWorkQueueId == null
                ? null
                : hydratedSelectedWorkQueueDetailSection) ||
        restoredWorkQueueResolutionFilter !=
            hydratedWorkQueueResolutionFilter ||
        !_sameWorkQueueSavedViews(
          _customWorkQueueSavedViews,
          restoredWorkQueueSavedViews,
        ) ||
        !_sameRecentViews(restoredViews, mergedViews)) {
      unawaited(_queuePersistWorkspaceState());
    }
  }

  Future<void> _queuePersistWorkspaceState() {
    final repository = widget.recentViewRepository;
    if (repository == null) return Future<void>.value();

    final pending =
        _persistWorkspaceStateFuture?.catchError((_) {}) ??
        Future<void>.value();
    final snapshot = AccountingWorkspaceSnapshot(
      rolePreset: _rolePreset,
      workQueueFocus: _workQueueFocus,
      workQueueSort: _workQueueSort,
      workQueueOwnerFilter: _workQueueOwnerFilter,
      selectedWorkQueueId: _selectedWorkQueueId,
      selectedWorkQueueDetailSection: _selectedWorkQueueDetailSection,
      workQueueResolutionFilter: _workQueueResolutionFilter,
      views: _recentViews,
      workQueueSavedViews: _customWorkQueueSavedViews,
      workQueueSavedViewAuditEvents: _workQueueSavedViewAuditEvents,
      workQueueEvidenceLinks: _persistedWorkQueueEvidenceLinks(
        _workQueueEvidenceLinks,
      ),
      workQueueEvidenceReviewStates: _persistedWorkQueueEvidenceReviewStates(
        _workQueueEvidenceReviewStates,
      ),
      workQueueNotes: _persistedWorkQueueNotes(_workQueueNotes),
      workQueueActivityActionStates: _persistedWorkQueueActivityActionStates(
        _workQueueActivityActionStates,
      ),
      workQueueReviewerSignOffStates: _persistedWorkQueueReviewerSignOffStates(
        _workQueueReviewerSignOffStates,
      ),
      workQueueResolutionStates: _persistedWorkQueueResolutionStates(
        _workQueueResolutionStates,
      ),
    );
    return _persistWorkspaceStateFuture = pending.then(
      (_) => repository.saveSnapshot(snapshot),
    );
  }
}

List<AccountingWorkspaceWorkQueueActivityActionState>
_persistedWorkQueueActivityActionStates(
  Map<String, AccountingWorkspaceWorkQueueActivityActionState> states,
) {
  final persistedStates =
      states.values.where((state) => state.completedActionCount > 0).toList()
        ..sort((a, b) => a.queueId.compareTo(b.queueId));

  return List<AccountingWorkspaceWorkQueueActivityActionState>.unmodifiable(
    persistedStates,
  );
}

List<AccountingWorkspaceWorkQueueNote> _persistedWorkQueueNotes(
  Map<String, List<AccountingWorkspaceWorkQueueNote>> notesByQueueId,
) {
  final persistedNotes =
      notesByQueueId.values
          .expand((notes) => notes)
          .where((note) => note.isPersistable)
          .toList()
        ..sort((a, b) {
          final queueOrder = a.queueId.compareTo(b.queueId);
          if (queueOrder != 0) return queueOrder;

          return b.createdAt.compareTo(a.createdAt);
        });

  return List<AccountingWorkspaceWorkQueueNote>.unmodifiable(persistedNotes);
}

List<AccountingWorkspaceWorkQueueEvidenceLink> _persistedWorkQueueEvidenceLinks(
  Map<String, List<AccountingWorkspaceWorkQueueEvidenceLink>> linksByQueueId,
) {
  final persistedLinks =
      linksByQueueId.values
          .expand((links) => links)
          .where((link) => link.isPersistable)
          .toList()
        ..sort((a, b) {
          final queueOrder = a.queueId.compareTo(b.queueId);
          if (queueOrder != 0) return queueOrder;

          return b.addedAt.compareTo(a.addedAt);
        });

  return List<AccountingWorkspaceWorkQueueEvidenceLink>.unmodifiable(
    persistedLinks,
  );
}

List<AccountingWorkspaceWorkQueueEvidenceReviewState>
_persistedWorkQueueEvidenceReviewStates(
  Map<String, AccountingWorkspaceWorkQueueEvidenceReviewState> statesByLinkId,
) {
  final persistedStates =
      statesByLinkId.values.where((state) => state.isPersistable).toList()
        ..sort((a, b) {
          final queueOrder = a.queueId.compareTo(b.queueId);
          if (queueOrder != 0) return queueOrder;

          return a.linkId.compareTo(b.linkId);
        });

  return List<AccountingWorkspaceWorkQueueEvidenceReviewState>.unmodifiable(
    persistedStates,
  );
}

List<AccountingWorkspaceWorkQueueReviewerSignOffState>
_persistedWorkQueueReviewerSignOffStates(
  Map<String, AccountingWorkspaceWorkQueueReviewerSignOffState> states,
) {
  final persistedStates =
      states.values.where((state) => state.hasDecision).toList()
        ..sort((a, b) => a.queueId.compareTo(b.queueId));

  return List<AccountingWorkspaceWorkQueueReviewerSignOffState>.unmodifiable(
    persistedStates,
  );
}

List<AccountingWorkspaceWorkQueueResolutionState>
_persistedWorkQueueResolutionStates(
  Map<String, AccountingWorkspaceWorkQueueResolutionState> states,
) {
  final persistedStates =
      states.values.where((state) => state.hasResolution).toList()
        ..sort((a, b) => a.queueId.compareTo(b.queueId));

  return List<AccountingWorkspaceWorkQueueResolutionState>.unmodifiable(
    persistedStates,
  );
}

bool _sameRecentViews(
  List<AccountingWorkspaceRecentView> previous,
  List<AccountingWorkspaceRecentView> next,
) {
  if (previous.length != next.length) return false;

  for (var index = 0; index < previous.length; index += 1) {
    if (previous[index].id != next[index].id) return false;
  }

  return true;
}

List<AccountingWorkspaceWorkQueueSavedView> _upsertWorkQueueSavedView(
  List<AccountingWorkspaceWorkQueueSavedView> views,
  AccountingWorkspaceWorkQueueSavedView nextView,
) {
  final nextViews = <AccountingWorkspaceWorkQueueSavedView>[];

  for (final view in views) {
    if (view.id != nextView.id) nextViews.add(view);
  }
  nextViews.insert(0, nextView);

  return List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(nextViews);
}

List<AccountingWorkspaceWorkQueueSavedView> _promoteWorkQueueSavedView(
  List<AccountingWorkspaceWorkQueueSavedView> views,
  AccountingWorkspaceWorkQueueSavedView view,
) {
  return _upsertWorkQueueSavedView(views, view);
}

AccountingWorkspaceWorkQueueSavedView? _workQueueSavedViewById(
  List<AccountingWorkspaceWorkQueueSavedView> views,
  String viewId,
) {
  for (final view in views) {
    if (view.id == viewId) return view;
  }

  return null;
}

bool _sameWorkQueueSavedViews(
  List<AccountingWorkspaceWorkQueueSavedView> previous,
  List<AccountingWorkspaceWorkQueueSavedView> next,
) {
  if (previous.length != next.length) return false;

  for (var index = 0; index < previous.length; index += 1) {
    if (previous[index].id != next[index].id) return false;
    if (previous[index].toJson().toString() !=
        next[index].toJson().toString()) {
      return false;
    }
  }

  return true;
}
