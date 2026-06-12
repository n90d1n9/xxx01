import '../accounting_path.dart';
import '../models/accounting_menu_catalog.dart';
import '../models/accounting_menu_search.dart';
import '../models/accounting_workspace_next_action.dart';
import '../models/accounting_workspace_role_preset.dart';

class AccountingWorkspaceNextActionService {
  const AccountingWorkspaceNextActionService();

  List<AccountingWorkspaceNextAction> actionsFor({
    required AccountingWorkspaceRolePreset rolePreset,
    String query = '',
    AccountingMenuSearchScope scope = AccountingMenuSearchScope.all,
    Iterable<AccountingMenuDestination>? destinations,
  }) {
    final effectiveDestinations = destinations ?? accountingMenuDestinations;
    final destinationByPath = {
      for (final destination in effectiveDestinations)
        destination.path: destination,
    };
    final actions = <AccountingWorkspaceNextAction>[];

    for (final template in _templatesForRole(rolePreset)) {
      final destination = destinationByPath[template.path];
      if (destination == null || !_matchesScope(destination, scope)) continue;

      final action = AccountingWorkspaceNextAction(
        id: template.id,
        title: destination.name,
        description: template.description,
        icon: destination.icon,
        path: destination.path,
        registerRoute: destination.registerRoute,
      );
      if (_matchesQuery(action, destination, query)) {
        actions.add(action);
      }
    }

    return List<AccountingWorkspaceNextAction>.unmodifiable(actions);
  }
}

bool _matchesScope(
  AccountingMenuDestination destination,
  AccountingMenuSearchScope scope,
) {
  switch (scope) {
    case AccountingMenuSearchScope.all:
      return true;
    case AccountingMenuSearchScope.screens:
      return destination.registerRoute;
    case AccountingMenuSearchScope.shortcuts:
      return !destination.registerRoute;
  }
}

bool _matchesQuery(
  AccountingWorkspaceNextAction action,
  AccountingMenuDestination destination,
  String query,
) {
  final terms =
      query
          .trim()
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((term) => term.isNotEmpty)
          .toList();
  if (terms.isEmpty) return true;

  final haystack =
      [
        action.title,
        action.description,
        action.path,
        destination.subtitle,
      ].join(' ').toLowerCase();

  return terms.every(haystack.contains);
}

List<_AccountingWorkspaceNextActionTemplate> _templatesForRole(
  AccountingWorkspaceRolePreset rolePreset,
) {
  switch (rolePreset) {
    case AccountingWorkspaceRolePreset.accountant:
      return const [
        _AccountingWorkspaceNextActionTemplate(
          id: 'accountant-ledger',
          path: AccountingPath.gl,
          description: 'Review postings, filters, exports, and bank evidence.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'accountant-close',
          path: AccountingPath.periodClose,
          description:
              'Move through close checklist, gates, and lock controls.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'accountant-payables',
          path: AccountingPath.accPayable,
          description: 'Review supplier bills, payment runs, and AP aging.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'accountant-receivables',
          path: AccountingPath.accReceivable,
          description: 'Review customer invoices, aging, and collections.',
        ),
      ];
    case AccountingWorkspaceRolePreset.controller:
      return const [
        _AccountingWorkspaceNextActionTemplate(
          id: 'controller-close',
          path: AccountingPath.periodClose,
          description: 'Check close status, ownership, and posting locks.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'controller-report-pack',
          path: AccountingPath.reportPack,
          description: 'Review schedules, compliance, and export readiness.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'controller-release',
          path: AccountingPath.reportRelease,
          description:
              'Coordinate sign-off, distribution, archive, and filing.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'controller-reconciliation',
          path: AccountingPath.bankReconciliation,
          description: 'Inspect bank timing differences and cash evidence.',
        ),
      ];
    case AccountingWorkspaceRolePreset.tax:
      return const [
        _AccountingWorkspaceNextActionTemplate(
          id: 'tax-filing',
          path: AccountingPath.reportReleaseStatutoryFiling,
          description: 'Review statutory filing and SPT Tahunan support.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'tax-statements',
          path: AccountingPath.finStatement,
          description: 'Inspect statement period and tax controls.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'tax-report-pack',
          path: AccountingPath.reportPack,
          description: 'Review tax schedules, disclosures, and export package.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'tax-policy',
          path: AccountingPath.policy,
          description: 'Check PPN, framework, currency, and entity setup.',
        ),
      ];
    case AccountingWorkspaceRolePreset.auditor:
      return const [
        _AccountingWorkspaceNextActionTemplate(
          id: 'auditor-release-evidence',
          path: AccountingPath.reportReleaseEvidence,
          description: 'Inspect release manifest coverage and evidence gaps.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'auditor-reconciliation',
          path: AccountingPath.bankReconciliation,
          description: 'Review cash evidence and timing-difference support.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'auditor-notes',
          path: AccountingPath.financialNotes,
          description: 'Review required disclosures and reviewer evidence.',
        ),
        _AccountingWorkspaceNextActionTemplate(
          id: 'auditor-history',
          path: AccountingPath.entryHistory,
          description: 'Trace posted journal evidence and ledger audit lookup.',
        ),
      ];
  }
}

class _AccountingWorkspaceNextActionTemplate {
  const _AccountingWorkspaceNextActionTemplate({
    required this.id,
    required this.path,
    required this.description,
  });

  final String id;
  final String path;
  final String description;
}
