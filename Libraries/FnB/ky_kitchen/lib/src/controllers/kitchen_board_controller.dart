import 'package:flutter/foundation.dart';
import 'package:ky_fnb_core/ky_fnb_core.dart';

import '../models/kitchen_handoff_audit_entry.dart';
import '../models/kitchen_handoff_verification.dart';
import '../models/kitchen_operator_context.dart';
import '../models/kitchen_station_board.dart';
import '../models/kitchen_station_load.dart';
import '../models/kitchen_ticket.dart';
import '../models/kitchen_ticket_action.dart';
import '../models/kitchen_ticket_queue.dart';
import '../models/recipe_production_entry.dart';
import '../models/recipe_production_summary.dart';

/// Coordinates kitchen board filters, selections, and derived ticket visibility.
class KitchenBoardController extends ChangeNotifier {
  KitchenBoardController({
    required Iterable<FnbKitchenStation> stations,
    required KitchenTicketQueue queue,
    FnbKitchenStationFilter initialFilter = FnbKitchenStationFilter.all,
    String? initialStationId,
    String? initialTicketId,
    this.actionHistoryLimit = 20,
    this.handoffAuditLimit = 50,
    String handoffVerifierLabel = 'Expo',
    KitchenOperatorContext? handoffOperatorContext,
    Iterable<FnbRecipe> recipes = const [],
    FnbMenu? menu,
  }) : handoffOperatorContext =
           handoffOperatorContext ??
           KitchenOperatorContext.fromLabel(handoffVerifierLabel),
       _stations = List<FnbKitchenStation>.unmodifiable(stations),
       _recipes = List<FnbRecipe>.unmodifiable(recipes),
       // ignore: prefer_initializing_formals
       _menu = menu,
       _selectedFilter = initialFilter {
    assert(
      actionHistoryLimit > 0,
      'actionHistoryLimit must be greater than zero.',
    );
    assert(
      handoffAuditLimit > 0,
      'handoffAuditLimit must be greater than zero.',
    );
    _queue = queue;
    _rebuildBoard();
    _selectedStationId =
        _validStationId(initialStationId) ?? _preferredStationIdForFilter();
    _selectedTicketId =
        _validVisibleTicketId(initialTicketId) ?? _preferredTicketId();
  }

  late KitchenStationBoard _board;
  late KitchenTicketQueue _queue;
  List<FnbKitchenStation> _stations;
  List<FnbRecipe> _recipes;
  FnbMenu? _menu;
  FnbKitchenStationFilter _selectedFilter;
  String? _selectedStationId;
  String? _selectedTicketId;
  KitchenTicketActionHistoryFilter _selectedActionHistoryFilter =
      KitchenTicketActionHistoryFilter.all;
  KitchenTicketActionResult? _lastActionResult;
  KitchenTicketActionHistory _actionHistory = KitchenTicketActionHistory();
  List<KitchenHandoffAuditEntry> _handoffAuditEntries = const [];
  final Map<String, Map<String, KitchenHandoffVerificationRecord>>
  _handoffVerificationRecordsByTicket = {};

  /// Maximum number of action results retained in [actionHistory].
  final int actionHistoryLimit;

  /// Maximum number of archived handoff audit entries retained locally.
  final int handoffAuditLimit;

  /// Default operator context attached to handoff verification records.
  final KitchenOperatorContext handoffOperatorContext;

  /// Default operator label attached to handoff verification records.
  String get handoffVerifierLabel => handoffOperatorContext.verifierLabel;

  /// Current kitchen station metadata used to derive the board.
  List<FnbKitchenStation> get stations => _stations;

  /// Current kitchen ticket queue used for pressure and priority ordering.
  KitchenTicketQueue get queue => _queue;

  /// Shared recipe catalog used for kitchen production review.
  List<FnbRecipe> get recipes => List<FnbRecipe>.unmodifiable(_recipes);

  /// Shared menu catalog used to link recipes to sellable items.
  FnbMenu? get menu => _menu;

  /// Dashboard-ready station board derived from [stations] and [queue].
  KitchenStationBoard get board => _board;

  /// Active station filter for the station list.
  FnbKitchenStationFilter get selectedFilter => _selectedFilter;

  /// Currently selected station id, or null when all tickets are visible.
  String? get selectedStationId => _selectedStationId;

  /// Currently selected ticket id within [visibleTickets], when available.
  String? get selectedTicketId => _selectedTicketId;

  /// Most recent ticket action result produced by this controller.
  KitchenTicketActionResult? get lastActionResult => _lastActionResult;

  /// Recent ticket action outcomes, newest first.
  KitchenTicketActionHistory get actionHistory => _actionHistory;

  /// Archived handoff verification entries for recently closed tickets.
  List<KitchenHandoffAuditEntry> get handoffAuditEntries {
    return List<KitchenHandoffAuditEntry>.unmodifiable(_handoffAuditEntries);
  }

  /// Active history filter for the recent activity panel.
  KitchenTicketActionHistoryFilter get selectedActionHistoryFilter {
    return _selectedActionHistoryFilter;
  }

  /// Action history results visible under the active activity filter.
  List<KitchenTicketActionResult> get visibleActionHistoryResults {
    return _actionHistory.filtered(
      filter: _selectedActionHistoryFilter,
      ticketId: _selectedTicketId,
    );
  }

  /// Whether the board has recipe catalog data for production review.
  bool get hasRecipeProductionData => _recipes.isNotEmpty;

  /// Recipe production summary scoped to the currently selected station.
  KitchenRecipeProductionSummary get scopedRecipeProductionSummary {
    return KitchenRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu,
      stationId: _selectedStationId,
    );
  }

  /// Recipe production summary across all stations.
  KitchenRecipeProductionSummary get recipeProductionSummary {
    return KitchenRecipeProductionSummary.fromCatalog(
      recipes: _recipes,
      menu: _menu,
    );
  }

  /// Verified handoff checklist steps for [ticketId].
  Set<String> verifiedHandoffStepIdsFor(String ticketId) {
    return Set<String>.unmodifiable(
      _handoffVerificationRecordsByTicket[ticketId]?.keys ?? const {},
    );
  }

  /// Audit records for handoff checklist steps verified on [ticketId].
  Map<String, KitchenHandoffVerificationRecord> handoffVerificationRecordsFor(
    String ticketId,
  ) {
    return Map<String, KitchenHandoffVerificationRecord>.unmodifiable(
      _handoffVerificationRecordsByTicket[ticketId] ?? const {},
    );
  }

  /// Current handoff verification plan for [ticket].
  KitchenHandoffVerificationPlan handoffVerificationPlanFor(
    KitchenTicket ticket,
  ) {
    return KitchenHandoffVerificationPlan.fromTicket(
      ticket: ticket,
      now: _queue.now,
      verifiedStepIds: verifiedHandoffStepIdsFor(ticket.id),
      records: handoffVerificationRecordsFor(ticket.id).values,
    );
  }

  /// Whether [action] can currently be applied to [ticket].
  bool canApplyTicketAction({
    required KitchenTicket ticket,
    required KitchenTicketAction action,
  }) {
    return ticketActionBlockReason(ticket: ticket, action: action) == null;
  }

  /// User-facing reason [action] is blocked for [ticket], when blocked.
  String? ticketActionBlockReason({
    required KitchenTicket ticket,
    required KitchenTicketAction action,
  }) {
    if (action != KitchenTicketAction.serve) return null;

    return handoffVerificationPlanFor(ticket).serveBlockReason;
  }

  /// Whether the last applied action can be restored locally.
  bool get canUndoLastTicketAction {
    final result = _lastActionResult;
    if (result == null || !result.canRestorePreviousTicket) return false;

    final updatedTicket = result.updatedTicket;
    if (updatedTicket == null) return false;

    final currentTicket = _ticketById(updatedTicket.id);
    return currentTicket?.stage == updatedTicket.stage;
  }

  /// Station loads included by the active filter.
  List<KitchenStationLoad> get visibleLoads {
    return _board.filteredLoads(_selectedFilter);
  }

  /// Priority tickets scoped to the selected station, or all stations if none.
  List<KitchenTicket> get visibleTickets {
    final selectedStationId = _selectedStationId;
    final tickets = selectedStationId == null
        ? _queue.priorityTickets
        : _queue.priorityTickets
              .where((ticket) => ticket.stationId == selectedStationId)
              .toList(growable: false);
    return List<KitchenTicket>.unmodifiable(tickets);
  }

  /// Selected station load when the station still exists in the board.
  KitchenStationLoad? get selectedLoad {
    final selectedStationId = _selectedStationId;
    if (selectedStationId == null) return null;
    return _loadByStationId(selectedStationId);
  }

  /// Selected ticket when it is still open and visible.
  KitchenTicket? get selectedTicket {
    final selectedTicketId = _selectedTicketId;
    if (selectedTicketId == null) return null;
    return _visibleTicketById(selectedTicketId);
  }

  /// Number of station loads that would be shown for [filter].
  int loadCountForFilter(FnbKitchenStationFilter filter) {
    return _board.filteredLoads(filter).length;
  }

  /// Replaces station metadata and queue data in a single notification.
  void updateData({
    Iterable<FnbKitchenStation>? stations,
    KitchenTicketQueue? queue,
    Iterable<FnbRecipe>? recipes,
    FnbMenu? menu,
  }) {
    if (stations == null && queue == null && recipes == null && menu == null) {
      return;
    }

    if (stations != null) {
      _stations = List<FnbKitchenStation>.unmodifiable(stations);
    }
    if (queue != null) {
      _queue = queue;
    }
    if (recipes != null) {
      _recipes = List<FnbRecipe>.unmodifiable(recipes);
    }
    if (menu != null) {
      _menu = menu;
    }

    _rebuildBoard();
    _pruneHandoffVerification();
    _normalizeSelection(chooseStationWhenMissing: false);
    notifyListeners();
  }

  /// Replaces recipe and menu catalog data used by production review panels.
  void updateRecipeProductionCatalog({
    Iterable<FnbRecipe>? recipes,
    FnbMenu? menu,
  }) {
    if (recipes == null && menu == null) return;

    if (recipes != null) {
      _recipes = List<FnbRecipe>.unmodifiable(recipes);
    }
    if (menu != null) {
      _menu = menu;
    }
    notifyListeners();
  }

  /// Selects the station associated with a recipe production entry.
  void selectRecipeProductionEntry(KitchenRecipeProductionEntry entry) {
    selectStation(entry.stationId);
  }

  /// Rebuilds queue pressure against a new clock while preserving tickets.
  void updateNow(DateTime now) {
    if (_queue.now == now) return;

    _queue = KitchenTicketQueue(tickets: _queue.tickets, now: now);
    _rebuildBoard();
    _normalizeSelection(chooseStationWhenMissing: false);
    notifyListeners();
  }

  /// Selects the active station filter and keeps selection inside that lens.
  void selectFilter(FnbKitchenStationFilter filter) {
    if (_selectedFilter == filter) return;

    _selectedFilter = filter;
    if (!_selectedStationIsVisibleForFilter()) {
      _selectedStationId = _preferredStationIdForFilter();
    }
    _normalizeTicketSelection(chooseTicketWhenMissing: true);
    notifyListeners();
  }

  /// Selects a station and scopes visible tickets to that station.
  void selectStation(String stationId) {
    final validStationId = _validStationId(stationId);
    if (validStationId == null || validStationId == _selectedStationId) return;

    _selectedStationId = validStationId;
    _normalizeTicketSelection(chooseTicketWhenMissing: true);
    notifyListeners();
  }

  /// Clears the selected station so the ticket queue shows all open tickets.
  void clearStationSelection() {
    if (_selectedStationId == null) return;

    _selectedStationId = null;
    _normalizeTicketSelection(chooseTicketWhenMissing: true);
    notifyListeners();
  }

  /// Selects an open ticket and moves the station selection to its station.
  void selectTicket(String ticketId) {
    final ticket = _openTicketById(ticketId);
    if (ticket == null) return;

    final nextStationId = _validStationId(ticket.stationId);
    final nextTicketId = ticket.id;
    if (_selectedStationId == nextStationId &&
        _selectedTicketId == nextTicketId) {
      return;
    }

    _selectedStationId = nextStationId;
    _selectedTicketId = nextTicketId;
    notifyListeners();
  }

  /// Clears only the selected ticket while keeping the station scope.
  void clearTicketSelection() {
    if (_selectedTicketId == null) return;

    _selectedTicketId = null;
    notifyListeners();
  }

  /// Marks one handoff verification step checked or unchecked for a ticket.
  void setHandoffStepVerified({
    required String ticketId,
    required String stepId,
    required bool verified,
    String? verifiedBy,
    KitchenOperatorContext? verifiedByOperator,
  }) {
    if (_ticketById(ticketId) == null) return;

    final records = Map<String, KitchenHandoffVerificationRecord>.of(
      _handoffVerificationRecordsByTicket[ticketId] ?? const {},
    );
    final changed = verified
        ? _recordVerifiedHandoffStep(
            records: records,
            stepId: stepId,
            verifiedBy: verifiedBy,
            verifiedByOperator: verifiedByOperator,
          )
        : records.remove(stepId) != null;
    if (!changed) return;

    if (records.isEmpty) {
      _handoffVerificationRecordsByTicket.remove(ticketId);
    } else {
      _handoffVerificationRecordsByTicket[ticketId] = records;
    }
    notifyListeners();
  }

  /// Selects the activity history filter used by the board screen.
  void selectActionHistoryFilter(KitchenTicketActionHistoryFilter filter) {
    if (_selectedActionHistoryFilter == filter) return;

    _selectedActionHistoryFilter = filter;
    notifyListeners();
  }

  /// Applies [action] to the selected ticket and updates derived board state.
  bool applySelectedTicketAction(KitchenTicketAction action) {
    return applySelectedTicketActionResult(action).applied;
  }

  /// Applies [action] to a ticket by id and updates derived board state.
  bool applyTicketAction({
    required String ticketId,
    required KitchenTicketAction action,
  }) {
    return applyTicketActionResult(ticketId: ticketId, action: action).applied;
  }

  /// Applies [action] to the selected ticket and returns a detailed result.
  KitchenTicketActionResult applySelectedTicketActionResult(
    KitchenTicketAction action,
  ) {
    final selectedTicketId = _selectedTicketId;
    if (selectedTicketId == null) {
      final result = _storeActionResult(
        KitchenTicketActionResult(
          action: action,
          outcome: KitchenTicketActionOutcome.noSelectedTicket,
          ticketId: null,
          occurredAt: _queue.now,
        ),
      );
      notifyListeners();
      return result;
    }

    return applyTicketActionResult(ticketId: selectedTicketId, action: action);
  }

  /// Applies [action] to a ticket by id and returns a detailed result.
  KitchenTicketActionResult applyTicketActionResult({
    required String ticketId,
    required KitchenTicketAction action,
  }) {
    final ticketIndex = _queue.tickets.indexWhere(
      (ticket) => ticket.id == ticketId,
    );
    if (ticketIndex == -1) {
      final result = _storeActionResult(
        KitchenTicketActionResult(
          action: action,
          outcome: KitchenTicketActionOutcome.ticketNotFound,
          ticketId: ticketId,
          occurredAt: _queue.now,
        ),
      );
      notifyListeners();
      return result;
    }

    final ticket = _queue.tickets[ticketIndex];
    final blockReason = ticketActionBlockReason(ticket: ticket, action: action);
    if (blockReason != null) {
      final result = _storeActionResult(
        KitchenTicketActionResult(
          action: action,
          outcome: KitchenTicketActionOutcome.unavailable,
          ticketId: ticketId,
          occurredAt: _queue.now,
          previousTicket: ticket,
        ),
      );
      notifyListeners();
      return result;
    }

    final updatedTicket = action.applyTo(ticket);
    if (identical(updatedTicket, ticket) ||
        updatedTicket.stage == ticket.stage) {
      final result = _storeActionResult(
        KitchenTicketActionResult(
          action: action,
          outcome: KitchenTicketActionOutcome.unavailable,
          ticketId: ticketId,
          occurredAt: _queue.now,
          previousTicket: ticket,
        ),
      );
      notifyListeners();
      return result;
    }

    final updatedTickets = _queue.tickets.toList(growable: false);
    updatedTickets[ticketIndex] = updatedTicket;
    _archiveHandoffVerificationIfClosed(
      previousTicket: ticket,
      updatedTicket: updatedTicket,
    );
    _queue = KitchenTicketQueue(tickets: updatedTickets, now: _queue.now);
    _rebuildBoard();
    _pruneHandoffVerification();
    _normalizeSelection(chooseStationWhenMissing: false);
    final result = _storeActionResult(
      KitchenTicketActionResult(
        action: action,
        outcome: KitchenTicketActionOutcome.applied,
        ticketId: ticketId,
        occurredAt: _queue.now,
        previousTicket: ticket,
        updatedTicket: updatedTicket,
      ),
    );
    notifyListeners();
    return result;
  }

  /// Restores the previous ticket from the most recent applied action.
  bool undoLastTicketAction() {
    if (!canUndoLastTicketAction) return false;

    final result = _lastActionResult;
    final previousTicket = result?.previousTicket;
    if (previousTicket == null) return false;

    final ticketIndex = _queue.tickets.indexWhere(
      (ticket) => ticket.id == previousTicket.id,
    );
    if (ticketIndex == -1) return false;

    final restoredTickets = _queue.tickets.toList(growable: false);
    restoredTickets[ticketIndex] = previousTicket;
    _queue = KitchenTicketQueue(tickets: restoredTickets, now: _queue.now);
    _lastActionResult = null;
    _rebuildBoard();
    _pruneHandoffVerification();
    _normalizeSelection(chooseStationWhenMissing: false);
    notifyListeners();
    return true;
  }

  /// Clears the stored ticket action result without changing board state.
  void clearLastActionResult() {
    if (_lastActionResult == null) return;

    _lastActionResult = null;
    notifyListeners();
  }

  /// Clears retained ticket action history without changing board state.
  void clearActionHistory() {
    if (_actionHistory.isEmpty) return;

    _actionHistory = _actionHistory.clear();
    _selectedActionHistoryFilter = KitchenTicketActionHistoryFilter.all;
    notifyListeners();
  }

  void _rebuildBoard() {
    _board = KitchenStationBoard.fromQueue(stations: _stations, queue: _queue);
  }

  KitchenTicketActionResult _storeActionResult(
    KitchenTicketActionResult result,
  ) {
    _lastActionResult = result;
    _actionHistory = _actionHistory.record(result, limit: actionHistoryLimit);
    return result;
  }

  void _archiveHandoffVerificationIfClosed({
    required KitchenTicket previousTicket,
    required KitchenTicket updatedTicket,
  }) {
    if (previousTicket.stage != KitchenTicketStage.ready ||
        updatedTicket.stage == KitchenTicketStage.ready) {
      return;
    }

    final records = _handoffVerificationRecordsByTicket[previousTicket.id];
    if (records == null || records.isEmpty) return;

    final entry = KitchenHandoffAuditEntry.fromTicket(
      ticket: updatedTicket,
      archivedAt: _queue.now,
      records: records.values,
    );
    _handoffAuditEntries = [
      entry,
      ..._handoffAuditEntries,
    ].take(handoffAuditLimit).toList(growable: false);
  }

  void _pruneHandoffVerification() {
    final readyTicketIds = _queue.tickets
        .where((ticket) => ticket.stage == KitchenTicketStage.ready)
        .map((ticket) => ticket.id)
        .toSet();
    _handoffVerificationRecordsByTicket.removeWhere(
      (ticketId, _) => !readyTicketIds.contains(ticketId),
    );
  }

  bool _recordVerifiedHandoffStep({
    required Map<String, KitchenHandoffVerificationRecord> records,
    required String stepId,
    required String? verifiedBy,
    required KitchenOperatorContext? verifiedByOperator,
  }) {
    final operatorContext =
        verifiedByOperator ??
        (verifiedBy == null
            ? handoffOperatorContext
            : KitchenOperatorContext.fromLabel(verifiedBy));
    final record = KitchenHandoffVerificationRecord.fromOperator(
      stepId: stepId,
      verifiedAt: _queue.now,
      operatorContext: operatorContext,
    );
    if (records[stepId] == record) return false;

    records[stepId] = record;
    return true;
  }

  void _normalizeSelection({required bool chooseStationWhenMissing}) {
    if (_selectedStationId != null &&
        _loadByStationId(_selectedStationId!) == null) {
      _selectedStationId = null;
    }

    if (!_selectedStationIsVisibleForFilter()) {
      _selectedStationId = null;
    }

    if (_selectedStationId == null && chooseStationWhenMissing) {
      _selectedStationId = _preferredStationIdForFilter();
    }

    _normalizeTicketSelection(chooseTicketWhenMissing: true);
  }

  void _normalizeTicketSelection({required bool chooseTicketWhenMissing}) {
    if (_selectedTicketId != null &&
        _visibleTicketById(_selectedTicketId!) == null) {
      _selectedTicketId = null;
    }

    if (_selectedTicketId == null && chooseTicketWhenMissing) {
      _selectedTicketId = _preferredTicketId();
    }
  }

  String? _preferredStationIdForFilter() {
    final loads = visibleLoads;
    if (loads.isEmpty) return null;

    final topLoad = _board.topLoad;
    if (topLoad != null &&
        loads.any((load) => load.station.id == topLoad.station.id)) {
      return topLoad.station.id;
    }

    return loads.first.station.id;
  }

  String? _preferredTicketId() {
    final tickets = visibleTickets;
    if (tickets.isEmpty) return null;
    return tickets.first.id;
  }

  String? _validStationId(String? stationId) {
    if (stationId == null) return null;
    return _loadByStationId(stationId) == null ? null : stationId;
  }

  String? _validVisibleTicketId(String? ticketId) {
    if (ticketId == null) return null;
    return _visibleTicketById(ticketId) == null ? null : ticketId;
  }

  bool _selectedStationIsVisibleForFilter() {
    final selectedStationId = _selectedStationId;
    if (selectedStationId == null) return true;
    return visibleLoads.any((load) => load.station.id == selectedStationId);
  }

  KitchenStationLoad? _loadByStationId(String stationId) {
    for (final load in _board.loads) {
      if (load.station.id == stationId) return load;
    }
    return null;
  }

  KitchenTicket? _openTicketById(String ticketId) {
    for (final ticket in _queue.priorityTickets) {
      if (ticket.id == ticketId) return ticket;
    }
    return null;
  }

  KitchenTicket? _ticketById(String ticketId) {
    for (final ticket in _queue.tickets) {
      if (ticket.id == ticketId) return ticket;
    }
    return null;
  }

  KitchenTicket? _visibleTicketById(String ticketId) {
    for (final ticket in visibleTickets) {
      if (ticket.id == ticketId) return ticket;
    }
    return null;
  }
}
