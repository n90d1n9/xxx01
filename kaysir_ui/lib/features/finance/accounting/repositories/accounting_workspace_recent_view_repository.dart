import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/accounting_workspace_recent_view.dart';
import '../models/accounting_workspace_role_preset.dart';
import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_detail_section.dart';
import '../models/accounting_workspace_work_queue_focus.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import '../models/work_queue_resolution_filter.dart';
import '../models/work_queue_resolution_state.dart';
import '../models/accounting_workspace_work_queue_sort.dart';
import '../models/work_queue_evidence_link.dart';
import '../models/work_queue_evidence_review_state.dart';
import '../models/work_queue_note.dart';
import '../models/work_queue_saved_view.dart';
import '../models/work_queue_saved_view_manager_audit.dart';

/// Storage contract for persisted accounting workspace navigation snapshots.
abstract class AccountingWorkspaceRecentViewSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

/// Local database-backed snapshot store for accounting workspace state.
class LocalDbAccountingWorkspaceRecentViewSnapshotStore
    implements AccountingWorkspaceRecentViewSnapshotStore {
  static const defaultStorageKey =
      'accounting.workspace_recent_views.snapshot.v1';

  LocalDbAccountingWorkspaceRecentViewSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-accounting-workspace-recent-views-local',
  });

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  @override
  Future<Map<String, Object?>?> read() async {
    final stored = await _tryRead();
    return _asJsonMap(stored);
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    try {
      await _ensureInitialized();
      await LocalDBService.savePreference(key: storageKey, value: snapshot);
    } catch (_) {
      return;
    }
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= LocalDBService.initialize(
      encryptionPassword: encryptionPassword,
    ).then((_) {}).catchError((_) {});
  }

  Future<Object?> _tryRead() async {
    try {
      await _ensureInitialized();
      return LocalDBService.getPreference(key: storageKey);
    } catch (_) {
      return null;
    }
  }
}

/// In-memory snapshot store used by accounting workspace tests.
class MemoryAccountingWorkspaceRecentViewSnapshotStore
    implements AccountingWorkspaceRecentViewSnapshotStore {
  Map<String, Object?>? _snapshot;

  Map<String, Object?>? get snapshot {
    final value = _snapshot;
    if (value == null) return null;

    return Map<String, Object?>.unmodifiable(value);
  }

  @override
  Future<Map<String, Object?>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    _snapshot = Map<String, Object?>.unmodifiable(snapshot);
  }
}

/// Repository that saves and restores accounting workspace navigation state.
class AccountingWorkspaceRecentViewRepository {
  const AccountingWorkspaceRecentViewRepository({required this.store});

  factory AccountingWorkspaceRecentViewRepository.local() {
    return AccountingWorkspaceRecentViewRepository(
      store: LocalDbAccountingWorkspaceRecentViewSnapshotStore(),
    );
  }

  final AccountingWorkspaceRecentViewSnapshotStore store;

  Future<AccountingWorkspaceSnapshot> loadSnapshot() async {
    final snapshot = await store.read();
    if (snapshot == null) return const AccountingWorkspaceSnapshot();

    return AccountingWorkspaceSnapshot.fromJson(snapshot);
  }

  Future<void> saveSnapshot(AccountingWorkspaceSnapshot snapshot) async {
    await store.write(snapshot.toJson());
  }

  Future<List<AccountingWorkspaceRecentView>> load() async {
    return (await loadSnapshot()).views;
  }

  Future<void> save(List<AccountingWorkspaceRecentView> views) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(views: views));
  }

  Future<AccountingWorkspaceRolePreset?> loadRolePreset() async {
    return (await loadSnapshot()).rolePreset;
  }

  Future<void> saveRolePreset(AccountingWorkspaceRolePreset rolePreset) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(rolePreset: rolePreset));
  }

  Future<AccountingWorkspaceWorkQueueFocus?> loadWorkQueueFocus() async {
    return (await loadSnapshot()).workQueueFocus;
  }

  Future<void> saveWorkQueueFocus(
    AccountingWorkspaceWorkQueueFocus workQueueFocus,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(workQueueFocus: workQueueFocus));
  }

  Future<AccountingWorkspaceWorkQueueSort?> loadWorkQueueSort() async {
    return (await loadSnapshot()).workQueueSort;
  }

  Future<void> saveWorkQueueSort(
    AccountingWorkspaceWorkQueueSort workQueueSort,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(workQueueSort: workQueueSort));
  }

  Future<String?> loadWorkQueueOwnerFilter() async {
    return (await loadSnapshot()).workQueueOwnerFilter;
  }

  Future<void> saveWorkQueueOwnerFilter(String? ownerFilter) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(
      AccountingWorkspaceSnapshot(
        rolePreset: snapshot.rolePreset,
        workQueueFocus: snapshot.workQueueFocus,
        workQueueSort: snapshot.workQueueSort,
        workQueueOwnerFilter: _normalizedStringValue(ownerFilter),
        selectedWorkQueueId: snapshot.selectedWorkQueueId,
        selectedWorkQueueDetailSection: snapshot.selectedWorkQueueDetailSection,
        workQueueResolutionFilter: snapshot.workQueueResolutionFilter,
        views: snapshot.views,
        workQueueSavedViews: snapshot.workQueueSavedViews,
        workQueueSavedViewAuditEvents: snapshot.workQueueSavedViewAuditEvents,
        workQueueEvidenceLinks: snapshot.workQueueEvidenceLinks,
        workQueueEvidenceReviewStates: snapshot.workQueueEvidenceReviewStates,
        workQueueNotes: snapshot.workQueueNotes,
        workQueueActivityActionStates: snapshot.workQueueActivityActionStates,
        workQueueReviewerSignOffStates: snapshot.workQueueReviewerSignOffStates,
        workQueueResolutionStates: snapshot.workQueueResolutionStates,
      ),
    );
  }

  Future<AccountingWorkspaceWorkQueueResolutionFilter?>
  loadWorkQueueResolutionFilter() async {
    return (await loadSnapshot()).workQueueResolutionFilter;
  }

  Future<void> saveWorkQueueResolutionFilter(
    AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(
      snapshot.copyWith(workQueueResolutionFilter: resolutionFilter),
    );
  }

  Future<List<AccountingWorkspaceWorkQueueActivityActionState>>
  loadWorkQueueActivityActionStates() async {
    return (await loadSnapshot()).workQueueActivityActionStates;
  }

  Future<void> saveWorkQueueActivityActionStates(
    List<AccountingWorkspaceWorkQueueActivityActionState> actionStates,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(
      snapshot.copyWith(workQueueActivityActionStates: actionStates),
    );
  }

  Future<List<AccountingWorkspaceWorkQueueReviewerSignOffState>>
  loadWorkQueueReviewerSignOffStates() async {
    return (await loadSnapshot()).workQueueReviewerSignOffStates;
  }

  Future<void> saveWorkQueueReviewerSignOffStates(
    List<AccountingWorkspaceWorkQueueReviewerSignOffState> signOffStates,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(
      snapshot.copyWith(workQueueReviewerSignOffStates: signOffStates),
    );
  }

  Future<List<AccountingWorkspaceWorkQueueResolutionState>>
  loadWorkQueueResolutionStates() async {
    return (await loadSnapshot()).workQueueResolutionStates;
  }

  Future<void> saveWorkQueueResolutionStates(
    List<AccountingWorkspaceWorkQueueResolutionState> resolutionStates,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(
      snapshot.copyWith(workQueueResolutionStates: resolutionStates),
    );
  }

  Future<List<AccountingWorkspaceWorkQueueSavedView>>
  loadWorkQueueSavedViews() async {
    return (await loadSnapshot()).workQueueSavedViews;
  }

  Future<void> saveWorkQueueSavedViews(
    List<AccountingWorkspaceWorkQueueSavedView> savedViews,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(workQueueSavedViews: savedViews));
  }

  Future<List<WorkQueueSavedViewManagerAuditEvent>>
  loadWorkQueueSavedViewAuditEvents() async {
    return (await loadSnapshot()).workQueueSavedViewAuditEvents;
  }

  Future<void> saveWorkQueueSavedViewAuditEvents(
    List<WorkQueueSavedViewManagerAuditEvent> auditEvents,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(
      snapshot.copyWith(workQueueSavedViewAuditEvents: auditEvents),
    );
  }

  Future<List<AccountingWorkspaceWorkQueueEvidenceLink>>
  loadWorkQueueEvidenceLinks() async {
    return (await loadSnapshot()).workQueueEvidenceLinks;
  }

  Future<void> saveWorkQueueEvidenceLinks(
    List<AccountingWorkspaceWorkQueueEvidenceLink> links,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(workQueueEvidenceLinks: links));
  }

  Future<List<AccountingWorkspaceWorkQueueEvidenceReviewState>>
  loadWorkQueueEvidenceReviewStates() async {
    return (await loadSnapshot()).workQueueEvidenceReviewStates;
  }

  Future<void> saveWorkQueueEvidenceReviewStates(
    List<AccountingWorkspaceWorkQueueEvidenceReviewState> states,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(
      snapshot.copyWith(workQueueEvidenceReviewStates: states),
    );
  }

  Future<List<AccountingWorkspaceWorkQueueNote>> loadWorkQueueNotes() async {
    return (await loadSnapshot()).workQueueNotes;
  }

  Future<void> saveWorkQueueNotes(
    List<AccountingWorkspaceWorkQueueNote> notes,
  ) async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(workQueueNotes: notes));
  }

  Future<void> clear() async {
    final snapshot = await loadSnapshot();
    await saveSnapshot(snapshot.copyWith(views: const []));
  }
}

/// Persisted accounting workspace state shared across app sessions.
class AccountingWorkspaceSnapshot {
  const AccountingWorkspaceSnapshot({
    this.rolePreset,
    this.workQueueFocus,
    this.workQueueSort,
    this.workQueueOwnerFilter,
    this.selectedWorkQueueId,
    this.selectedWorkQueueDetailSection,
    this.workQueueResolutionFilter,
    this.views = const [],
    this.workQueueSavedViews = const [],
    this.workQueueSavedViewAuditEvents = const [],
    this.workQueueEvidenceLinks = const [],
    this.workQueueEvidenceReviewStates = const [],
    this.workQueueNotes = const [],
    this.workQueueActivityActionStates = const [],
    this.workQueueReviewerSignOffStates = const [],
    this.workQueueResolutionStates = const [],
  });

  factory AccountingWorkspaceSnapshot.fromJson(Map<String, Object?> json) {
    final rawViews = json['views'];
    final rawWorkQueueSavedViews = json['workQueueSavedViews'];
    final rawWorkQueueSavedViewAuditEvents =
        json['workQueueSavedViewAuditEvents'];
    final rawWorkQueueEvidenceLinks = json['workQueueEvidenceLinks'];
    final rawWorkQueueEvidenceReviewStates =
        json['workQueueEvidenceReviewStates'];
    final rawWorkQueueNotes = json['workQueueNotes'];
    final rawWorkQueueActivityActionStates =
        json['workQueueActivityActionStates'];
    final rawWorkQueueReviewerSignOffStates =
        json['workQueueReviewerSignOffStates'];
    final rawWorkQueueResolutionStates = json['workQueueResolutionStates'];
    final hasWorkQueueFocus = json.containsKey('workQueueFocus');
    final hasWorkQueueSort = json.containsKey('workQueueSort');
    final hasWorkQueueResolutionFilter = json.containsKey(
      'workQueueResolutionFilter',
    );
    final selectedWorkQueueId = _normalizedStringValue(
      json['selectedWorkQueueId'],
    );

    return AccountingWorkspaceSnapshot(
      rolePreset: accountingWorkspaceRolePresetFromStorage(json['rolePreset']),
      workQueueFocus:
          hasWorkQueueFocus
              ? accountingWorkspaceWorkQueueFocusFromQuery(
                _stringValue(json['workQueueFocus']),
              )
              : null,
      workQueueSort:
          hasWorkQueueSort
              ? accountingWorkspaceWorkQueueSortFromQuery(
                _stringValue(json['workQueueSort']),
              )
              : null,
      workQueueOwnerFilter: _normalizedStringValue(
        json['workQueueOwnerFilter'],
      ),
      selectedWorkQueueId: selectedWorkQueueId,
      selectedWorkQueueDetailSection:
          selectedWorkQueueId == null
              ? null
              : accountingWorkspaceWorkQueueDetailSectionFromQuery(
                _stringValue(json['selectedWorkQueueDetailSection']),
              ),
      workQueueResolutionFilter:
          hasWorkQueueResolutionFilter
              ? accountingWorkspaceWorkQueueResolutionFilterFromStorage(
                json['workQueueResolutionFilter'],
              )
              : null,
      views: List<AccountingWorkspaceRecentView>.unmodifiable([
        if (rawViews is Iterable)
          for (final rawView in rawViews)
            if (_asJsonMap(rawView) case final viewJson?)
              AccountingWorkspaceRecentView.fromJson(viewJson),
      ]),
      workQueueSavedViews:
          List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable([
            if (rawWorkQueueSavedViews is Iterable)
              for (final rawView in rawWorkQueueSavedViews)
                if (_asJsonMap(rawView) case final viewJson?)
                  if (accountingWorkspaceWorkQueueSavedViewFromJson(viewJson)
                      case final savedView?)
                    if (savedView.isCustom) savedView,
          ]),
      workQueueSavedViewAuditEvents:
          List<WorkQueueSavedViewManagerAuditEvent>.unmodifiable([
            if (rawWorkQueueSavedViewAuditEvents is Iterable)
              for (final rawEvent in rawWorkQueueSavedViewAuditEvents)
                if (_asJsonMap(rawEvent) case final eventJson?)
                  if (workQueueSavedViewManagerAuditEventFromJson(eventJson)
                      case final event?)
                    event,
          ]),
      workQueueEvidenceLinks:
          List<AccountingWorkspaceWorkQueueEvidenceLink>.unmodifiable([
            if (rawWorkQueueEvidenceLinks is Iterable)
              for (final rawLink in rawWorkQueueEvidenceLinks)
                if (_asJsonMap(rawLink) case final linkJson?)
                  if (accountingWorkspaceWorkQueueEvidenceLinkFromJson(linkJson)
                      case final link?)
                    link,
          ]),
      workQueueEvidenceReviewStates:
          List<AccountingWorkspaceWorkQueueEvidenceReviewState>.unmodifiable([
            if (rawWorkQueueEvidenceReviewStates is Iterable)
              for (final rawState in rawWorkQueueEvidenceReviewStates)
                if (_asJsonMap(rawState) case final stateJson?)
                  if (AccountingWorkspaceWorkQueueEvidenceReviewState.fromJson(
                        stateJson,
                      )
                      case final state when state.isPersistable)
                    state,
          ]),
      workQueueNotes: List<AccountingWorkspaceWorkQueueNote>.unmodifiable([
        if (rawWorkQueueNotes is Iterable)
          for (final rawNote in rawWorkQueueNotes)
            if (_asJsonMap(rawNote) case final noteJson?)
              if (accountingWorkspaceWorkQueueNoteFromJson(noteJson)
                  case final note?)
                note,
      ]),
      workQueueActivityActionStates:
          List<AccountingWorkspaceWorkQueueActivityActionState>.unmodifiable([
            if (rawWorkQueueActivityActionStates is Iterable)
              for (final rawActionState in rawWorkQueueActivityActionStates)
                if (_asJsonMap(rawActionState) case final actionStateJson?)
                  if (AccountingWorkspaceWorkQueueActivityActionState.fromJson(
                        actionStateJson,
                      )
                      case final actionState
                      when actionState.queueId.isNotEmpty)
                    actionState,
          ]),
      workQueueReviewerSignOffStates:
          List<AccountingWorkspaceWorkQueueReviewerSignOffState>.unmodifiable([
            if (rawWorkQueueReviewerSignOffStates is Iterable)
              for (final rawSignOffState in rawWorkQueueReviewerSignOffStates)
                if (_asJsonMap(rawSignOffState) case final signOffStateJson?)
                  if (AccountingWorkspaceWorkQueueReviewerSignOffState.fromJson(
                        signOffStateJson,
                      )
                      case final signOffState
                      when signOffState.queueId.isNotEmpty)
                    signOffState,
          ]),
      workQueueResolutionStates:
          List<AccountingWorkspaceWorkQueueResolutionState>.unmodifiable([
            if (rawWorkQueueResolutionStates is Iterable)
              for (final rawResolutionState in rawWorkQueueResolutionStates)
                if (_asJsonMap(rawResolutionState)
                    case final resolutionStateJson?)
                  if (AccountingWorkspaceWorkQueueResolutionState.fromJson(
                        resolutionStateJson,
                      )
                      case final resolutionState
                      when resolutionState.queueId.isNotEmpty)
                    resolutionState,
          ]),
    );
  }

  final AccountingWorkspaceRolePreset? rolePreset;
  final AccountingWorkspaceWorkQueueFocus? workQueueFocus;
  final AccountingWorkspaceWorkQueueSort? workQueueSort;
  final String? workQueueOwnerFilter;
  final String? selectedWorkQueueId;
  final AccountingWorkspaceWorkQueueDetailSection?
  selectedWorkQueueDetailSection;
  final AccountingWorkspaceWorkQueueResolutionFilter? workQueueResolutionFilter;
  final List<AccountingWorkspaceRecentView> views;
  final List<AccountingWorkspaceWorkQueueSavedView> workQueueSavedViews;
  final List<WorkQueueSavedViewManagerAuditEvent> workQueueSavedViewAuditEvents;
  final List<AccountingWorkspaceWorkQueueEvidenceLink> workQueueEvidenceLinks;
  final List<AccountingWorkspaceWorkQueueEvidenceReviewState>
  workQueueEvidenceReviewStates;
  final List<AccountingWorkspaceWorkQueueNote> workQueueNotes;
  final List<AccountingWorkspaceWorkQueueActivityActionState>
  workQueueActivityActionStates;
  final List<AccountingWorkspaceWorkQueueReviewerSignOffState>
  workQueueReviewerSignOffStates;
  final List<AccountingWorkspaceWorkQueueResolutionState>
  workQueueResolutionStates;

  AccountingWorkspaceSnapshot copyWith({
    AccountingWorkspaceRolePreset? rolePreset,
    AccountingWorkspaceWorkQueueFocus? workQueueFocus,
    AccountingWorkspaceWorkQueueSort? workQueueSort,
    String? workQueueOwnerFilter,
    String? selectedWorkQueueId,
    AccountingWorkspaceWorkQueueDetailSection? selectedWorkQueueDetailSection,
    AccountingWorkspaceWorkQueueResolutionFilter? workQueueResolutionFilter,
    List<AccountingWorkspaceRecentView>? views,
    List<AccountingWorkspaceWorkQueueSavedView>? workQueueSavedViews,
    List<WorkQueueSavedViewManagerAuditEvent>? workQueueSavedViewAuditEvents,
    List<AccountingWorkspaceWorkQueueEvidenceLink>? workQueueEvidenceLinks,
    List<AccountingWorkspaceWorkQueueEvidenceReviewState>?
    workQueueEvidenceReviewStates,
    List<AccountingWorkspaceWorkQueueNote>? workQueueNotes,
    List<AccountingWorkspaceWorkQueueActivityActionState>?
    workQueueActivityActionStates,
    List<AccountingWorkspaceWorkQueueReviewerSignOffState>?
    workQueueReviewerSignOffStates,
    List<AccountingWorkspaceWorkQueueResolutionState>?
    workQueueResolutionStates,
  }) {
    return AccountingWorkspaceSnapshot(
      rolePreset: rolePreset ?? this.rolePreset,
      workQueueFocus: workQueueFocus ?? this.workQueueFocus,
      workQueueSort: workQueueSort ?? this.workQueueSort,
      workQueueOwnerFilter:
          _normalizedStringValue(workQueueOwnerFilter) ??
          this.workQueueOwnerFilter,
      selectedWorkQueueId:
          _normalizedStringValue(selectedWorkQueueId) ??
          this.selectedWorkQueueId,
      selectedWorkQueueDetailSection:
          selectedWorkQueueDetailSection ?? this.selectedWorkQueueDetailSection,
      workQueueResolutionFilter:
          workQueueResolutionFilter ?? this.workQueueResolutionFilter,
      views: views ?? this.views,
      workQueueSavedViews: workQueueSavedViews ?? this.workQueueSavedViews,
      workQueueSavedViewAuditEvents:
          workQueueSavedViewAuditEvents ?? this.workQueueSavedViewAuditEvents,
      workQueueEvidenceLinks:
          workQueueEvidenceLinks ?? this.workQueueEvidenceLinks,
      workQueueEvidenceReviewStates:
          workQueueEvidenceReviewStates ?? this.workQueueEvidenceReviewStates,
      workQueueNotes: workQueueNotes ?? this.workQueueNotes,
      workQueueActivityActionStates:
          workQueueActivityActionStates ?? this.workQueueActivityActionStates,
      workQueueReviewerSignOffStates:
          workQueueReviewerSignOffStates ?? this.workQueueReviewerSignOffStates,
      workQueueResolutionStates:
          workQueueResolutionStates ?? this.workQueueResolutionStates,
    );
  }

  Map<String, Object?> toJson() {
    final normalizedOwnerFilter = _normalizedStringValue(workQueueOwnerFilter);
    final normalizedSelectedWorkQueueId = _normalizedStringValue(
      selectedWorkQueueId,
    );

    return {
      'schemaVersion': 16,
      if (rolePreset != null) 'rolePreset': rolePreset!.storageValue,
      if (workQueueFocus != null) 'workQueueFocus': workQueueFocus!.queryValue,
      if (workQueueSort != null) 'workQueueSort': workQueueSort!.queryValue,
      if (normalizedOwnerFilter != null)
        'workQueueOwnerFilter': normalizedOwnerFilter,
      if (normalizedSelectedWorkQueueId != null)
        'selectedWorkQueueId': normalizedSelectedWorkQueueId,
      if (normalizedSelectedWorkQueueId != null &&
          selectedWorkQueueDetailSection != null &&
          selectedWorkQueueDetailSection !=
              AccountingWorkspaceWorkQueueDetailSection.overview)
        'selectedWorkQueueDetailSection':
            selectedWorkQueueDetailSection!.queryValue,
      if (workQueueResolutionFilter != null)
        'workQueueResolutionFilter': workQueueResolutionFilter!.storageValue,
      'views': [for (final view in views) view.toJson()],
      'workQueueSavedViews': [
        for (final view in workQueueSavedViews)
          if (view.isCustom) view.toJson(),
      ],
      'workQueueSavedViewAuditEvents': [
        for (final event in workQueueSavedViewAuditEvents) event.toJson(),
      ],
      'workQueueEvidenceLinks': [
        for (final link in workQueueEvidenceLinks)
          if (link.isPersistable) link.toJson(),
      ],
      'workQueueEvidenceReviewStates': [
        for (final state in workQueueEvidenceReviewStates)
          if (state.isPersistable) state.toJson(),
      ],
      'workQueueNotes': [
        for (final note in workQueueNotes)
          if (note.isPersistable) note.toJson(),
      ],
      'workQueueActivityActionStates': [
        for (final actionState in workQueueActivityActionStates)
          actionState.toJson(),
      ],
      'workQueueReviewerSignOffStates': [
        for (final signOffState in workQueueReviewerSignOffStates)
          signOffState.toJson(),
      ],
      'workQueueResolutionStates': [
        for (final resolutionState in workQueueResolutionStates)
          resolutionState.toJson(),
      ],
    };
  }
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}

String _stringValue(Object? value) => value is String ? value : '';

String? _normalizedStringValue(Object? value) {
  if (value is! String) return null;

  final normalizedValue = value.trim();
  return normalizedValue.isEmpty ? null : normalizedValue;
}
