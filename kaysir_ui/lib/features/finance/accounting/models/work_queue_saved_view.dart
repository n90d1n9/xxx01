import 'accounting_menu_search.dart';
import 'accounting_workspace_role_preset.dart';
import 'accounting_workspace_work_queue_detail_section.dart';
import 'accounting_workspace_work_queue_focus.dart';
import 'accounting_workspace_work_queue_sort.dart';
import 'work_queue_resolution_filter.dart';

/// Reusable accounting work queue view for role-specific operating focus.
class AccountingWorkspaceWorkQueueSavedView {
  const AccountingWorkspaceWorkQueueSavedView({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.rolePreset,
    this.query = '',
    this.scope = AccountingMenuSearchScope.all,
    this.focus = AccountingWorkspaceWorkQueueFocus.all,
    this.sort = AccountingWorkspaceWorkQueueSort.workflow,
    this.ownerFilter,
    this.resolutionFilter = AccountingWorkspaceWorkQueueResolutionFilter.all,
    this.selectedQueueId,
    this.detailSection = AccountingWorkspaceWorkQueueDetailSection.overview,
    this.isCustom = false,
  });

  factory AccountingWorkspaceWorkQueueSavedView.custom({
    required String query,
    required AccountingMenuSearchScope scope,
    required AccountingWorkspaceRolePreset rolePreset,
    required AccountingWorkspaceWorkQueueFocus focus,
    required AccountingWorkspaceWorkQueueSort sort,
    required String? ownerFilter,
    required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
    required String? selectedQueueId,
    required String? selectedQueueTitle,
    required AccountingWorkspaceWorkQueueDetailSection detailSection,
  }) {
    final normalizedQuery = _trimmedText(query) ?? '';
    final normalizedOwner = _trimmedText(ownerFilter);
    final normalizedQueueId = _trimmedText(selectedQueueId);
    final normalizedQueueTitle = _trimmedText(selectedQueueTitle);
    final effectiveDetailSection =
        normalizedQueueId == null
            ? AccountingWorkspaceWorkQueueDetailSection.overview
            : detailSection;
    final label = _customViewLabel(
      selectedQueueTitle: normalizedQueueTitle,
      ownerFilter: normalizedOwner,
      focus: focus,
      sort: sort,
      resolutionFilter: resolutionFilter,
    );

    return AccountingWorkspaceWorkQueueSavedView(
      id: _customViewId(
        query: normalizedQuery,
        scope: scope,
        rolePreset: rolePreset,
        focus: focus,
        sort: sort,
        ownerFilter: normalizedOwner,
        resolutionFilter: resolutionFilter,
        selectedQueueId: normalizedQueueId,
        detailSection: effectiveDetailSection,
      ),
      label: label,
      description: _customViewDescription(
        query: normalizedQuery,
        scope: scope,
        rolePreset: rolePreset,
        focus: focus,
        sort: sort,
        ownerFilter: normalizedOwner,
        resolutionFilter: resolutionFilter,
        selectedQueueTitle: normalizedQueueTitle,
        detailSection: effectiveDetailSection,
      ),
      icon: rolePreset.icon,
      query: normalizedQuery,
      scope: scope,
      rolePreset: rolePreset,
      focus: focus,
      sort: sort,
      ownerFilter: normalizedOwner,
      resolutionFilter: resolutionFilter,
      selectedQueueId: normalizedQueueId,
      detailSection: effectiveDetailSection,
      isCustom: true,
    );
  }

  final String id;
  final String label;
  final String description;
  final String icon;
  final AccountingWorkspaceRolePreset rolePreset;
  final String query;
  final AccountingMenuSearchScope scope;
  final AccountingWorkspaceWorkQueueFocus focus;
  final AccountingWorkspaceWorkQueueSort sort;
  final String? ownerFilter;
  final AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter;
  final String? selectedQueueId;
  final AccountingWorkspaceWorkQueueDetailSection detailSection;
  final bool isCustom;

  /// Returns true when this preset matches the current work queue workspace.
  bool isSelected({
    required String query,
    required AccountingMenuSearchScope scope,
    required AccountingWorkspaceRolePreset rolePreset,
    required AccountingWorkspaceWorkQueueFocus focus,
    required AccountingWorkspaceWorkQueueSort sort,
    required String? ownerFilter,
    required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
    required String? selectedQueueId,
    required AccountingWorkspaceWorkQueueDetailSection detailSection,
  }) {
    final hasMatchingBase =
        _normalizedText(this.query) == _normalizedText(query) &&
        this.scope == scope &&
        this.rolePreset == rolePreset &&
        this.focus == focus &&
        this.sort == sort &&
        _normalizedText(this.ownerFilter) == _normalizedText(ownerFilter) &&
        this.resolutionFilter == resolutionFilter;
    if (!hasMatchingBase) return false;

    final presetQueueId = _normalizedText(this.selectedQueueId);
    if (presetQueueId == null) return true;

    return presetQueueId == _normalizedText(selectedQueueId) &&
        this.detailSection == detailSection;
  }

  Map<String, Object?> toJson() {
    final normalizedQuery = _trimmedText(query);
    final normalizedOwner = _trimmedText(ownerFilter);
    final normalizedQueueId = _trimmedText(selectedQueueId);

    return {
      'id': id,
      'label': label,
      'description': description,
      'icon': icon,
      'rolePreset': rolePreset.storageValue,
      if (normalizedQuery != null) 'query': normalizedQuery,
      if (scope != AccountingMenuSearchScope.all) 'scope': scope.queryValue,
      'focus': focus.queryValue,
      'sort': sort.queryValue,
      if (normalizedOwner != null) 'ownerFilter': normalizedOwner,
      'resolutionFilter': resolutionFilter.storageValue,
      if (normalizedQueueId != null) 'selectedQueueId': normalizedQueueId,
      if (normalizedQueueId != null &&
          detailSection != AccountingWorkspaceWorkQueueDetailSection.overview)
        'detailSection': detailSection.queryValue,
      'isCustom': isCustom,
    };
  }

  /// Returns this saved view with updated presentation fields.
  AccountingWorkspaceWorkQueueSavedView copyWith({
    String? label,
    String? description,
    String? icon,
  }) {
    return AccountingWorkspaceWorkQueueSavedView(
      id: id,
      label: _trimmedText(label) ?? this.label,
      description: _trimmedText(description) ?? this.description,
      icon: _trimmedText(icon) ?? this.icon,
      rolePreset: rolePreset,
      query: query,
      scope: scope,
      focus: focus,
      sort: sort,
      ownerFilter: ownerFilter,
      resolutionFilter: resolutionFilter,
      selectedQueueId: selectedQueueId,
      detailSection: detailSection,
      isCustom: isCustom,
    );
  }
}

/// Restores a persisted custom accounting work queue saved view.
AccountingWorkspaceWorkQueueSavedView?
accountingWorkspaceWorkQueueSavedViewFromJson(Map<String, Object?> json) {
  final rolePreset = accountingWorkspaceRolePresetFromStorage(
    json['rolePreset'],
  );
  final id = _trimmedText(json['id']);
  final label = _trimmedText(json['label']);
  if (rolePreset == null || id == null || label == null) return null;

  final selectedQueueId = _trimmedText(json['selectedQueueId']);

  return AccountingWorkspaceWorkQueueSavedView(
    id: id,
    label: label,
    description: _trimmedText(json['description']) ?? label,
    icon: _trimmedText(json['icon']) ?? rolePreset.icon,
    rolePreset: rolePreset,
    query: _trimmedText(json['query']) ?? '',
    scope: accountingMenuSearchScopeFromQuery(_stringValue(json['scope'])),
    focus: accountingWorkspaceWorkQueueFocusFromQuery(
      _stringValue(json['focus']),
    ),
    sort: accountingWorkspaceWorkQueueSortFromQuery(_stringValue(json['sort'])),
    ownerFilter: _trimmedText(json['ownerFilter']),
    resolutionFilter: accountingWorkspaceWorkQueueResolutionFilterFromStorage(
      json['resolutionFilter'],
    ),
    selectedQueueId: selectedQueueId,
    detailSection:
        selectedQueueId == null
            ? AccountingWorkspaceWorkQueueDetailSection.overview
            : accountingWorkspaceWorkQueueDetailSectionFromQuery(
              _stringValue(json['detailSection']),
            ),
    isCustom: json['isCustom'] is bool ? json['isCustom'] as bool : true,
  );
}

/// Role-scoped shortcuts for common accounting queue operating modes.
const accountingWorkspaceWorkQueueSavedViews =
    <AccountingWorkspaceWorkQueueSavedView>[
      AccountingWorkspaceWorkQueueSavedView(
        id: 'accountant-close-blockers',
        label: 'Close blockers',
        description: 'Blocked accountant queues before period lock.',
        icon: 'lock_clock',
        rolePreset: AccountingWorkspaceRolePreset.accountant,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        selectedQueueId: 'accountant-close-blockers',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'accountant-ap-overdue',
        label: 'AP overdue',
        description: 'Supplier reviews and payment evidence due now.',
        icon: 'payments',
        rolePreset: AccountingWorkspaceRolePreset.accountant,
        focus: AccountingWorkspaceWorkQueueFocus.review,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        ownerFilter: 'AP specialist',
        selectedQueueId: 'accountant-ap-overdue',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.request,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'accountant-ledger-review',
        label: 'Ledger review',
        description: 'GL exceptions with activity and owner follow-up.',
        icon: 'menu_book',
        rolePreset: AccountingWorkspaceRolePreset.accountant,
        focus: AccountingWorkspaceWorkQueueFocus.review,
        selectedQueueId: 'accountant-ledger-exceptions',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.activity,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'controller-close-blockers',
        label: 'Close blockers',
        description: 'Controller blockers sorted by urgency.',
        icon: 'lock_clock',
        rolePreset: AccountingWorkspaceRolePreset.controller,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        selectedQueueId: 'controller-close-blockers',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'controller-report-approver',
        label: 'Report approver',
        description: 'Release approval queue for report sign-off.',
        icon: 'verified_user',
        rolePreset: AccountingWorkspaceRolePreset.controller,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        ownerFilter: 'Report approver',
        selectedQueueId: 'controller-release-approvals',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'controller-posting-review',
        label: 'Posting review',
        description: 'Largest posting gates before period lock.',
        icon: 'playlist_add_check',
        rolePreset: AccountingWorkspaceRolePreset.controller,
        sort: AccountingWorkspaceWorkQueueSort.largest,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'tax-statutory-blockers',
        label: 'SPT blockers',
        description: 'Statutory filing gaps and close evidence.',
        icon: 'account_balance',
        rolePreset: AccountingWorkspaceRolePreset.tax,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        selectedQueueId: 'tax-statutory-filing-gaps',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'tax-reviewer',
        label: 'Tax reviewer',
        description: 'Tax disclosure and reviewer handoff queue.',
        icon: 'fact_check',
        rolePreset: AccountingWorkspaceRolePreset.tax,
        focus: AccountingWorkspaceWorkQueueFocus.review,
        ownerFilter: 'Tax reviewer',
        selectedQueueId: 'tax-disclosure-review',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.request,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'tax-policy-ops',
        label: 'Policy ops',
        description: 'PPN, currency, and entity setup review.',
        icon: 'settings',
        rolePreset: AccountingWorkspaceRolePreset.tax,
        focus: AccountingWorkspaceWorkQueueFocus.review,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        selectedQueueId: 'tax-policy-setup',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.controls,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'auditor-evidence-gaps',
        label: 'Evidence gaps',
        description: 'Release evidence gaps blocking audit readiness.',
        icon: 'fact_check',
        rolePreset: AccountingWorkspaceRolePreset.auditor,
        focus: AccountingWorkspaceWorkQueueFocus.blocked,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        ownerFilter: 'Audit liaison',
        selectedQueueId: 'auditor-evidence-gaps',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.request,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'auditor-reconciliations',
        label: 'Reconciliations',
        description: 'Cash support and timing differences due today.',
        icon: 'sync_alt',
        rolePreset: AccountingWorkspaceRolePreset.auditor,
        focus: AccountingWorkspaceWorkQueueFocus.review,
        sort: AccountingWorkspaceWorkQueueSort.urgent,
        ownerFilter: 'External audit',
        selectedQueueId: 'auditor-reconciliation-exceptions',
        detailSection: AccountingWorkspaceWorkQueueDetailSection.activity,
      ),
      AccountingWorkspaceWorkQueueSavedView(
        id: 'auditor-journal-samples',
        label: 'Journal samples',
        description: 'Posted entries selected for audit lookup.',
        icon: 'receipt_long',
        rolePreset: AccountingWorkspaceRolePreset.auditor,
        focus: AccountingWorkspaceWorkQueueFocus.monitor,
        ownerFilter: 'Audit sampling',
        selectedQueueId: 'auditor-journal-samples',
      ),
    ];

/// Returns the work queue saved views that are relevant for [rolePreset].
List<AccountingWorkspaceWorkQueueSavedView>
accountingWorkspaceWorkQueueSavedViewsForRole(
  AccountingWorkspaceRolePreset rolePreset, {
  List<AccountingWorkspaceWorkQueueSavedView> views =
      accountingWorkspaceWorkQueueSavedViews,
}) {
  return List<AccountingWorkspaceWorkQueueSavedView>.unmodifiable(
    views.where((view) => view.rolePreset == rolePreset),
  );
}

String? _normalizedText(String? value) {
  final normalizedValue = value?.trim().toLowerCase();
  if (normalizedValue == null || normalizedValue.isEmpty) return null;

  return normalizedValue;
}

String _stringValue(Object? value) => value is String ? value : '';

String? _trimmedText(Object? value) {
  if (value is! String) return null;

  final normalizedValue = value.trim();
  return normalizedValue.isEmpty ? null : normalizedValue;
}

String _customViewId({
  required String query,
  required AccountingMenuSearchScope scope,
  required AccountingWorkspaceRolePreset rolePreset,
  required AccountingWorkspaceWorkQueueFocus focus,
  required AccountingWorkspaceWorkQueueSort sort,
  required String? ownerFilter,
  required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
  required String? selectedQueueId,
  required AccountingWorkspaceWorkQueueDetailSection detailSection,
}) {
  return [
    'custom',
    rolePreset.storageValue,
    scope.queryValue,
    _slug(query.isEmpty ? 'all' : query),
    focus.queryValue,
    sort.queryValue,
    _slug(ownerFilter ?? 'all'),
    resolutionFilter.storageValue,
    _slug(selectedQueueId ?? 'all'),
    detailSection.queryValue,
  ].join('-');
}

String _customViewLabel({
  required String? selectedQueueTitle,
  required String? ownerFilter,
  required AccountingWorkspaceWorkQueueFocus focus,
  required AccountingWorkspaceWorkQueueSort sort,
  required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
}) {
  final baseLabel = selectedQueueTitle ?? ownerFilter ?? _focusLabel(focus);
  final qualifier =
      resolutionFilter.isDefault ? sort.label : resolutionFilter.label;

  return '$baseLabel / $qualifier';
}

String _customViewDescription({
  required String query,
  required AccountingMenuSearchScope scope,
  required AccountingWorkspaceRolePreset rolePreset,
  required AccountingWorkspaceWorkQueueFocus focus,
  required AccountingWorkspaceWorkQueueSort sort,
  required String? ownerFilter,
  required AccountingWorkspaceWorkQueueResolutionFilter resolutionFilter,
  required String? selectedQueueTitle,
  required AccountingWorkspaceWorkQueueDetailSection detailSection,
}) {
  final details = [
    rolePreset.label,
    if (query.isNotEmpty) '${scope.label}: $query',
    _focusLabel(focus),
    sort.label,
    if (ownerFilter != null) 'Owner: $ownerFilter',
    if (!resolutionFilter.isDefault) 'Resolution: ${resolutionFilter.label}',
    if (selectedQueueTitle != null) 'Queue: $selectedQueueTitle',
    if (detailSection != AccountingWorkspaceWorkQueueDetailSection.overview)
      'Tab: ${detailSection.queryValue}',
  ];

  return 'Custom queue view for ${details.join(' | ')}.';
}

String _focusLabel(AccountingWorkspaceWorkQueueFocus focus) {
  switch (focus) {
    case AccountingWorkspaceWorkQueueFocus.all:
      return 'All queues';
    case AccountingWorkspaceWorkQueueFocus.blocked:
      return 'Blocked queues';
    case AccountingWorkspaceWorkQueueFocus.review:
      return 'Review queues';
    case AccountingWorkspaceWorkQueueFocus.monitor:
      return 'Monitor queues';
  }
}

String _slug(String value) {
  final slug = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  return slug.isEmpty ? 'all' : slug;
}
