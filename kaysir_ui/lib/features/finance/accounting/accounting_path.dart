class AccountingPath {
  static const String workspace = '/accounting';
  static const String workspaceSearchParam = 'q';
  static const String workspaceScopeParam = 'scope';
  static const String workspaceRoleParam = 'role';
  static const String workspaceQueueParam = 'queue';
  static const String workspaceSortParam = 'sort';
  static const String workspaceOwnerParam = 'owner';
  static const String workspaceWorkParam = 'work';
  static const String workspaceWorkDetailParam = 'detail';
  static const String workspaceAccountantRole = 'accountant';
  static const String workspaceControllerRole = 'controller';
  static const String workspaceTaxRole = 'tax';
  static const String workspaceAuditorRole = 'auditor';
  static const String workspaceAccountant =
      '$workspace?$workspaceRoleParam=$workspaceAccountantRole';
  static const String workspaceController =
      '$workspace?$workspaceRoleParam=$workspaceControllerRole';
  static const String workspaceTax =
      '$workspace?$workspaceRoleParam=$workspaceTaxRole';
  static const String workspaceAuditor =
      '$workspace?$workspaceRoleParam=$workspaceAuditorRole';
  static const String chartOfAccounts = '/chart-of-accounts';
  static const String journalApproval = '/journal-approval';
  static const String gl = '/gl';
  static const String policy = '/accounting-policy';
  static const String trialBalance = '/trialbalance';
  static const String budget = '/budget';
  static const String financialReport = '/financialreport';
  static const String jurnalEntry = '/jurnalentry';
  static const String adjustment = '/adjustment';
  static const String entryHistory = '/entryhistory';
  static const String periodClose = '/period-close';
  static const String finStatement = '/finstatement';
  static const String reportPack = '/financial-report-pack';
  static const String managementMeasures = '/management-measures';
  static const String managementMeasuresFocusParam = 'focus';
  static const String managementMeasuresReleaseChecklistFocus =
      'release-checklist';
  static const String managementMeasuresApprovalFocus = 'approval';
  static const String managementMeasuresReconciliationFocus = 'reconciliation';
  static const String managementMeasuresExportEvidenceFocus = 'export-evidence';
  static const String managementMeasuresAuditFocus = 'audit';
  static const String managementMeasuresReleaseChecklist =
      '$managementMeasures?$managementMeasuresFocusParam='
      '$managementMeasuresReleaseChecklistFocus';
  static const String managementMeasuresApproval =
      '$managementMeasures?$managementMeasuresFocusParam='
      '$managementMeasuresApprovalFocus';
  static const String managementMeasuresReconciliation =
      '$managementMeasures?$managementMeasuresFocusParam='
      '$managementMeasuresReconciliationFocus';
  static const String managementMeasuresExportEvidence =
      '$managementMeasures?$managementMeasuresFocusParam='
      '$managementMeasuresExportEvidenceFocus';
  static const String managementMeasuresAudit =
      '$managementMeasures?$managementMeasuresFocusParam='
      '$managementMeasuresAuditFocus';
  static const String financialNotes = '/financial-notes';
  static const String reportRelease = '/financial-report-release';
  static const String reportReleaseFocusParam = 'focus';
  static const String reportReleaseSignOffFocus = 'sign-off';
  static const String reportReleaseEvidenceFocus = 'evidence';
  static const String reportReleaseDistributionFocus = 'distribution';
  static const String reportReleaseArchiveFocus = 'archive';
  static const String reportReleaseRetentionFocus = 'retention';
  static const String reportReleaseStatutoryFilingFocus = 'statutory-filing';
  static const String reportReleaseSignOff =
      '$reportRelease?$reportReleaseFocusParam=$reportReleaseSignOffFocus';
  static const String reportReleaseEvidence =
      '$reportRelease?$reportReleaseFocusParam=$reportReleaseEvidenceFocus';
  static const String reportReleaseDistribution =
      '$reportRelease?$reportReleaseFocusParam=$reportReleaseDistributionFocus';
  static const String reportReleaseArchive =
      '$reportRelease?$reportReleaseFocusParam=$reportReleaseArchiveFocus';
  static const String reportReleaseRetention =
      '$reportRelease?$reportReleaseFocusParam=$reportReleaseRetentionFocus';
  static const String reportReleaseStatutoryFiling =
      '$reportRelease?$reportReleaseFocusParam=$reportReleaseStatutoryFilingFocus';
  static const String profitLoss = '/profit-loss';
  static const String balanceSheet = '/balance-sheet';
  static const String cashFlow = '/cash-flow';
  static const String bankReconciliation = '/bank-reconciliation';
  static const String payableReconciliation = '/payable-reconciliation';
  static const String receivableReconciliation = '/receivable-reconciliation';

  static const String accPayable = '/accpayable';
  static const String vendors = '/vendors';

  static const String accReceivable = '/accreceivable';
  static const String customers = '/customers';

  static String managementMeasuresWithFocus(String focus) {
    return Uri(
      path: managementMeasures,
      queryParameters: {managementMeasuresFocusParam: focus},
    ).toString();
  }

  static String workspaceWithSearch({
    String? query,
    String? scope,
    String? role,
    String? queue,
    String? sort,
    String? owner,
    String? work,
    String? detail,
  }) {
    final queryParameters = {
      if (query != null && query.trim().isNotEmpty)
        workspaceSearchParam: query.trim(),
      if (scope != null && scope.trim().isNotEmpty)
        workspaceScopeParam: scope.trim(),
      if (role != null && role.trim().isNotEmpty)
        workspaceRoleParam: role.trim(),
      if (queue != null && queue.trim().isNotEmpty)
        workspaceQueueParam: queue.trim(),
      if (sort != null && sort.trim().isNotEmpty)
        workspaceSortParam: sort.trim(),
      if (owner != null && owner.trim().isNotEmpty)
        workspaceOwnerParam: owner.trim(),
      if (work != null && work.trim().isNotEmpty)
        workspaceWorkParam: work.trim(),
      if (detail != null && detail.trim().isNotEmpty)
        workspaceWorkDetailParam: detail.trim(),
    };

    return Uri(
      path: workspace,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();
  }

  static String reportReleaseWithFocus(String focus) {
    return Uri(
      path: reportRelease,
      queryParameters: {reportReleaseFocusParam: focus},
    ).toString();
  }
}
