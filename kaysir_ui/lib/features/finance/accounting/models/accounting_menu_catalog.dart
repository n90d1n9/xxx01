import '../accounting_path.dart';

/// Sidebar and workspace destination metadata for one accounting screen.
class AccountingMenuDestination {
  final String name;
  final String subtitle;
  final String icon;
  final String path;
  final bool registerRoute;

  const AccountingMenuDestination({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.path,
    this.registerRoute = true,
  });

  String get routePath {
    final uri = Uri.parse(path);
    return uri.path.isEmpty ? path : uri.path;
  }
}

/// Group of related accounting destinations shown together in navigation.
class AccountingMenuSection {
  final String name;
  final String subtitle;
  final String icon;
  final List<AccountingMenuDestination> destinations;

  const AccountingMenuSection({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.destinations,
  });

  Iterable<AccountingMenuDestination> get screenDestinations {
    return destinations.where((destination) => destination.registerRoute);
  }

  Iterable<AccountingMenuDestination> get shortcutDestinations {
    return destinations.where((destination) => !destination.registerRoute);
  }
}

const accountingWorkspaceDestination = AccountingMenuDestination(
  name: 'Accounting Workspace',
  subtitle: 'All close, ledger, reporting, reconciliation, AP, and AR screens.',
  icon: 'account_tree',
  path: AccountingPath.workspace,
);

const accountingWorkspaceRoleDestinations = <AccountingMenuDestination>[
  AccountingMenuDestination(
    name: 'Accountant Workspace',
    subtitle: 'Open accounting with ledger, close, AP, AR, and SPT presets.',
    icon: 'menu_book',
    path: AccountingPath.workspaceAccountant,
    registerRoute: false,
  ),
  AccountingMenuDestination(
    name: 'Controller Workspace',
    subtitle:
        'Open accounting with close, reporting, release, and evidence presets.',
    icon: 'verified_user',
    path: AccountingPath.workspaceController,
    registerRoute: false,
  ),
  AccountingMenuDestination(
    name: 'Tax Workspace',
    subtitle:
        'Open accounting with SPT, report pack, filing, and evidence presets.',
    icon: 'account_balance',
    path: AccountingPath.workspaceTax,
    registerRoute: false,
  ),
  AccountingMenuDestination(
    name: 'Auditor Workspace',
    subtitle:
        'Open accounting with evidence, reconciliation, and report pack presets.',
    icon: 'fact_check',
    path: AccountingPath.workspaceAuditor,
    registerRoute: false,
  ),
];

const accountingMenuSections = <AccountingMenuSection>[
  AccountingMenuSection(
    name: 'Close & Ledger',
    subtitle: 'Policy, close controls, ledger work, and journal evidence.',
    icon: 'menu_book',
    destinations: [
      AccountingMenuDestination(
        name: 'Accounting Policy',
        subtitle: 'Framework, entity, currency, close cadence, and tax setup.',
        icon: 'policy',
        path: AccountingPath.policy,
      ),
      AccountingMenuDestination(
        name: 'Chart of Accounts',
        subtitle:
            'CoA setup, posting eligibility, report mapping, and tax tags.',
        icon: 'account_tree',
        path: AccountingPath.chartOfAccounts,
      ),
      AccountingMenuDestination(
        name: 'Journal Approval',
        subtitle: 'Reviewer release, return notes, evidence, and GL posting.',
        icon: 'fact_check',
        path: AccountingPath.journalApproval,
      ),
      AccountingMenuDestination(
        name: 'Period Close',
        subtitle: 'Close checklist, workflow gates, audit trail, and lock.',
        icon: 'lock_clock',
        path: AccountingPath.periodClose,
      ),
      AccountingMenuDestination(
        name: 'General Ledger',
        subtitle: 'Ledger postings, filters, exports, and bank evidence.',
        icon: 'menu_book',
        path: AccountingPath.gl,
      ),
      AccountingMenuDestination(
        name: 'Trial Balance',
        subtitle: 'Debit-credit balance checks and close readiness.',
        icon: 'balance',
        path: AccountingPath.trialBalance,
      ),
      AccountingMenuDestination(
        name: 'Journal Adjustment',
        subtitle: 'Adjustment entry workspace with posting guardrails.',
        icon: 'edit_note',
        path: AccountingPath.adjustment,
      ),
      AccountingMenuDestination(
        name: 'Entry History',
        subtitle: 'Posted entry timeline and ledger audit lookup.',
        icon: 'history',
        path: AccountingPath.entryHistory,
      ),
    ],
  ),
  AccountingMenuSection(
    name: 'Reconciliation',
    subtitle: 'Cash, AP, and AR reconciliation review workspaces.',
    icon: 'sync_alt',
    destinations: [
      AccountingMenuDestination(
        name: 'Bank Reconciliation',
        subtitle: 'Bank statement, timing difference, and GL cash evidence.',
        icon: 'account_balance',
        path: AccountingPath.bankReconciliation,
      ),
      AccountingMenuDestination(
        name: 'Payable Reconciliation',
        subtitle: 'Vendor subledger to AP control account evidence.',
        icon: 'fact_check',
        path: AccountingPath.payableReconciliation,
      ),
      AccountingMenuDestination(
        name: 'Receivable Reconciliation',
        subtitle: 'Customer subledger to AR control account evidence.',
        icon: 'receipt_long',
        path: AccountingPath.receivableReconciliation,
      ),
    ],
  ),
  AccountingMenuSection(
    name: 'Financial Reporting',
    subtitle: 'SAK Indonesia reports, notes, release, and primary statements.',
    icon: 'summarize',
    destinations: [
      AccountingMenuDestination(
        name: 'Financial Statements',
        subtitle: 'Primary statement workspace with period and tax controls.',
        icon: 'summarize',
        path: AccountingPath.finStatement,
      ),
      AccountingMenuDestination(
        name: 'Report Pack',
        subtitle: 'Complete report pack, schedules, compliance, and export.',
        icon: 'inventory',
        path: AccountingPath.reportPack,
      ),
      AccountingMenuDestination(
        name: 'Management Measures',
        subtitle: 'UKTM register, reconciliation, and approval status.',
        icon: 'speed',
        path: AccountingPath.managementMeasures,
      ),
      AccountingMenuDestination(
        name: 'Management Checklist',
        subtitle: 'Jump to UKTM release checklist and unresolved controls.',
        icon: 'checklist',
        path: AccountingPath.managementMeasuresReleaseChecklist,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Management Approval',
        subtitle: 'Jump to approval owners, sign-off state, and return notes.',
        icon: 'approval',
        path: AccountingPath.managementMeasuresApproval,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Management Reconciliation',
        subtitle: 'Jump to UKTM-to-report reconciliation and variance review.',
        icon: 'sync_alt',
        path: AccountingPath.managementMeasuresReconciliation,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Management Export Evidence',
        subtitle: 'Jump to export evidence, reviewer proof, and coverage gaps.',
        icon: 'fact_check',
        path: AccountingPath.managementMeasuresExportEvidence,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Management Audit',
        subtitle: 'Jump to UKTM audit trail and reviewer activity history.',
        icon: 'manage_search',
        path: AccountingPath.managementMeasuresAudit,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Financial Notes',
        subtitle: 'Disclosure review, required notes, and reviewer evidence.',
        icon: 'sticky_note',
        path: AccountingPath.financialNotes,
      ),
      AccountingMenuDestination(
        name: 'Report Release',
        subtitle: 'Sign-off, PSAK 118 readiness, archive, and filing controls.',
        icon: 'verified_user',
        path: AccountingPath.reportRelease,
      ),
      AccountingMenuDestination(
        name: 'Release Sign-off',
        subtitle: 'Jump to approval owners, status, and return resolution.',
        icon: 'verified_user',
        path: AccountingPath.reportReleaseSignOff,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Release Evidence',
        subtitle: 'Jump to manifest coverage and release evidence gaps.',
        icon: 'fact_check',
        path: AccountingPath.reportReleaseEvidence,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Release Distribution',
        subtitle: 'Jump to recipient delivery and acknowledgement controls.',
        icon: 'outbox',
        path: AccountingPath.reportReleaseDistribution,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Release Archive',
        subtitle: 'Jump to immutable release pack custody controls.',
        icon: 'inventory_2',
        path: AccountingPath.reportReleaseArchive,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Release Retention',
        subtitle: 'Jump to archive review, hold, and disposal readiness.',
        icon: 'event_repeat',
        path: AccountingPath.reportReleaseRetention,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Release Filing',
        subtitle: 'Jump to statutory and SPT Tahunan support tracking.',
        icon: 'account_balance',
        path: AccountingPath.reportReleaseStatutoryFiling,
        registerRoute: false,
      ),
      AccountingMenuDestination(
        name: 'Profit & Loss',
        subtitle: 'Profit or loss and OCI statement view.',
        icon: 'trending_up',
        path: AccountingPath.profitLoss,
      ),
      AccountingMenuDestination(
        name: 'Balance Sheet',
        subtitle: 'Financial position statement view.',
        icon: 'account_balance_wallet',
        path: AccountingPath.balanceSheet,
      ),
      AccountingMenuDestination(
        name: 'Cash Flow',
        subtitle: 'Cash flow statement and cash movement evidence.',
        icon: 'waterfall_chart',
        path: AccountingPath.cashFlow,
      ),
    ],
  ),
  AccountingMenuSection(
    name: 'Payables',
    subtitle: 'Supplier bills, vendor records, cash forecast, and payments.',
    icon: 'payments',
    destinations: [
      AccountingMenuDestination(
        name: 'Account Payable',
        subtitle: 'AP dashboard, bills, payment runs, and aging.',
        icon: 'payments',
        path: AccountingPath.accPayable,
      ),
      AccountingMenuDestination(
        name: 'Vendors',
        subtitle: 'Vendor master data and statement controls.',
        icon: 'store',
        path: AccountingPath.vendors,
      ),
    ],
  ),
  AccountingMenuSection(
    name: 'Receivables',
    subtitle: 'Customer invoices, collection aging, and customer records.',
    icon: 'request_quote',
    destinations: [
      AccountingMenuDestination(
        name: 'Account Receivable',
        subtitle: 'AR dashboard, invoices, collection rate, and aging.',
        icon: 'request_quote',
        path: AccountingPath.accReceivable,
      ),
      AccountingMenuDestination(
        name: 'Customers',
        subtitle: 'Customer master data and account drill-down.',
        icon: 'group',
        path: AccountingPath.customers,
      ),
    ],
  ),
];

Iterable<AccountingMenuDestination> get accountingMenuDestinations sync* {
  yield accountingWorkspaceDestination;
  yield* accountingWorkspaceRoleDestinations;
  for (final section in accountingMenuSections) {
    yield* section.destinations;
  }
}

Iterable<AccountingMenuDestination> get accountingMenuScreenDestinations sync* {
  yield accountingWorkspaceDestination;
  for (final section in accountingMenuSections) {
    yield* section.screenDestinations;
  }
}

Iterable<AccountingMenuDestination>
get accountingMenuShortcutDestinations sync* {
  for (final section in accountingMenuSections) {
    yield* section.shortcutDestinations;
  }
}
