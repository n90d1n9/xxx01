import '../accounting_path.dart';
import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_accounting_impact.dart';

class AccountingWorkspaceWorkQueueAccountingImpactResolver {
  const AccountingWorkspaceWorkQueueAccountingImpactResolver();

  AccountingWorkspaceWorkQueueAccountingImpact resolve(
    AccountingWorkspaceWorkQueue queue,
  ) {
    switch (queue.path) {
      case AccountingPath.reportReleaseStatutoryFiling:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Tax and statutory filing package',
          assertionLabel: 'Completeness of filing support and reconciliations',
          taxImpactLabel: 'DJP filing, PPN/PPh bridge, and tax proof exposure',
          closeGateLabel: 'Hold statutory release until filing evidence clears',
          journalActionLabel: 'Tax reconciliation adjustment review',
          ledgerFocusLabel: 'Tax payable/receivable bridge accounts',
          postingGateLabel: 'Post only after filing pack is reconciled',
          requiresPostingGate: true,
        );
      case AccountingPath.reportReleaseEvidence:
      case AccountingPath.reportReleaseSignOff:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Financial statement release package',
          assertionLabel: 'Completeness and authorization of release evidence',
          taxImpactLabel: 'No direct tax posting; indirect filing proof risk',
          closeGateLabel: 'Block report release until evidence is signed off',
          journalActionLabel: 'Disclosure evidence only',
          ledgerFocusLabel: 'No debit/credit entry expected',
          postingGateLabel: 'Do not release until evidence is tied out',
          requiresPostingGate: false,
        );
      case AccountingPath.reportPack:
      case AccountingPath.financialNotes:
      case AccountingPath.finStatement:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Primary statements and disclosure notes',
          assertionLabel: 'Presentation, disclosure, and classification',
          taxImpactLabel: 'May affect tax reconciliation disclosures',
          closeGateLabel: 'Hold report pack approval until mapping is complete',
          journalActionLabel: 'Disclosure or reclass review',
          ledgerFocusLabel: 'Statement mapping and presentation accounts',
          postingGateLabel: 'Post reclass before report pack approval',
          requiresPostingGate: true,
        );
      case AccountingPath.bankReconciliation:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Cash and bank balances',
          assertionLabel: 'Existence, completeness, and cut-off',
          taxImpactLabel: 'May affect payment proof for tax settlements',
          closeGateLabel: 'Block cash tie-out before close lock',
          journalActionLabel: 'Bank adjustment or timing entry review',
          ledgerFocusLabel: 'Cash, bank clearing, and timing differences',
          postingGateLabel: 'Post bank adjustments before cash tie-out',
          requiresPostingGate: true,
        );
      case AccountingPath.accPayable:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Trade payables and supplier liabilities',
          assertionLabel: 'Completeness, obligation, and cut-off',
          taxImpactLabel: 'PPN input and PPh withholding documentation',
          closeGateLabel: 'Hold liability close until supplier support clears',
          journalActionLabel: 'Accrual, reversal, or supplier reclass review',
          ledgerFocusLabel:
              'Payables, expense accruals, PPN input, PPh payable',
          postingGateLabel: 'Post after invoice and tax support is matched',
          requiresPostingGate: true,
        );
      case AccountingPath.accReceivable:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Trade receivables and revenue',
          assertionLabel: 'Existence, valuation, and collectability',
          taxImpactLabel: 'PPN output and faktur pajak completeness',
          closeGateLabel: 'Hold revenue close until aging exceptions clear',
          journalActionLabel: 'Revenue, collection, or impairment review',
          ledgerFocusLabel: 'Receivables, revenue, allowance, PPN output',
          postingGateLabel: 'Post after invoice, tax, and collection evidence',
          requiresPostingGate: true,
        );
      case AccountingPath.periodClose:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Trial balance and close readiness',
          assertionLabel: 'Completeness of close activities',
          taxImpactLabel: 'Tax close dependencies and reconciliation readiness',
          closeGateLabel: 'Block period lock until critical tasks are cleared',
          journalActionLabel: 'Close adjustment review',
          ledgerFocusLabel: 'Trial balance, accruals, reversals, eliminations',
          postingGateLabel: 'Post approved adjustments before period lock',
          requiresPostingGate: true,
        );
      case AccountingPath.entryHistory:
      case AccountingPath.gl:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'General ledger and journal postings',
          assertionLabel: 'Accuracy, authorization, and posting completeness',
          taxImpactLabel: 'May affect tax basis if source coding is wrong',
          closeGateLabel: 'Hold trial balance review until journals are clean',
          journalActionLabel: 'Journal correction or approval review',
          ledgerFocusLabel: 'Source accounts, offset accounts, tax coding',
          postingGateLabel: 'Post only after source and approval are attached',
          requiresPostingGate: true,
        );
      case AccountingPath.policy:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Accounting policy and measurement basis',
          assertionLabel: 'Consistency and appropriateness of policy selection',
          taxImpactLabel: 'May affect book-to-tax treatment decisions',
          closeGateLabel:
              'Hold policy-dependent close judgments until approved',
          journalActionLabel: 'Policy-driven measurement review',
          ledgerFocusLabel: 'Affected measurement and disclosure accounts',
          postingGateLabel: 'Post only after policy memo approval',
          requiresPostingGate: true,
        );
      default:
        return const AccountingWorkspaceWorkQueueAccountingImpact(
          statementAreaLabel: 'Accounting workflow evidence',
          assertionLabel: 'Completeness and reviewer readiness',
          taxImpactLabel: 'Review for tax documentation dependency',
          closeGateLabel: 'Clear before workflow sign-off',
          journalActionLabel: 'Review for posting requirement',
          ledgerFocusLabel: 'Affected source and clearing accounts',
          postingGateLabel: 'Post after reviewer approval',
          requiresPostingGate: true,
        );
    }
  }
}
