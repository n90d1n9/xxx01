import '../models/project_finance_ledger.dart';

/// Read-only project finance ledger repository backed by seeded demo records.
class ProjectFinanceLedgerRepository {
  const ProjectFinanceLedgerRepository();

  List<ProjectBudgetLine> budgetLinesForProject(String projectId) {
    return List.unmodifiable(
      demoProjectBudgetLines.where((line) => line.projectId == projectId),
    );
  }

  List<ProjectExpenseRequest> expenseRequestsForProject(String projectId) {
    return List.unmodifiable(
      demoProjectExpenseRequests.where(
        (request) => request.projectId == projectId,
      ),
    );
  }

  List<ProjectPettyCashEntry> pettyCashEntriesForProject(String projectId) {
    return List.unmodifiable(
      demoProjectPettyCashEntries.where(
        (entry) => entry.projectId == projectId,
      ),
    );
  }

  List<ProjectApprovalRecord> approvalRecordsForProject(String projectId) {
    return List.unmodifiable(
      demoProjectApprovalRecords.where(
        (record) => record.projectId == projectId,
      ),
    );
  }

  List<ProjectReconciliationEvidence> reconciliationEvidenceForProject(
    String projectId,
  ) {
    return List.unmodifiable(
      demoProjectReconciliationEvidence.where(
        (evidence) => evidence.projectId == projectId,
      ),
    );
  }
}

const demoProjectBudgetLines = [
  ProjectBudgetLine(
    id: 'retail-modernization-store-ops',
    projectId: 'retail-modernization',
    category: ProjectFinanceCategory.labor,
    title: 'Store operations rollout',
    owner: 'Maya Santoso',
    plannedAmount: 120000000,
    committedAmount: 74000000,
    spentAmount: 62000000,
  ),
  ProjectBudgetLine(
    id: 'retail-modernization-systems',
    projectId: 'retail-modernization',
    category: ProjectFinanceCategory.technology,
    title: 'Checkout and inventory systems',
    owner: 'Dian Lestari',
    plannedAmount: 90000000,
    committedAmount: 58000000,
    spentAmount: 51000000,
  ),
  ProjectBudgetLine(
    id: 'retail-modernization-training',
    projectId: 'retail-modernization',
    category: ProjectFinanceCategory.training,
    title: 'Pilot training and adoption',
    owner: 'Iqbal Karim',
    plannedAmount: 45000000,
    committedAmount: 18000000,
    spentAmount: 15000000,
  ),
  ProjectBudgetLine(
    id: 'warehouse-automation-devices',
    projectId: 'warehouse-automation',
    category: ProjectFinanceCategory.material,
    title: 'Sensors and scanners',
    owner: 'Rafi Prakoso',
    plannedAmount: 140000000,
    committedAmount: 125000000,
    spentAmount: 99000000,
  ),
  ProjectBudgetLine(
    id: 'warehouse-automation-integration',
    projectId: 'warehouse-automation',
    category: ProjectFinanceCategory.vendor,
    title: 'Integration vendor',
    owner: 'Laras Amalia',
    plannedAmount: 85000000,
    committedAmount: 76000000,
    spentAmount: 62000000,
  ),
  ProjectBudgetLine(
    id: 'mobile-field-app-engineering',
    projectId: 'mobile-field-app',
    category: ProjectFinanceCategory.labor,
    title: 'Mobile engineering',
    owner: 'Nadia Putri',
    plannedAmount: 160000000,
    committedAmount: 42000000,
    spentAmount: 36000000,
  ),
  ProjectBudgetLine(
    id: 'finance-close-suite-controls',
    projectId: 'finance-close-suite',
    category: ProjectFinanceCategory.governance,
    title: 'Controls and audit evidence',
    owner: 'Bagas Wicaksono',
    plannedAmount: 110000000,
    committedAmount: 82000000,
    spentAmount: 76000000,
  ),
];

const demoProjectExpenseRequests = [
  ProjectExpenseRequest(
    id: 'retail-modernization-store-training-claim',
    projectId: 'retail-modernization',
    category: ProjectFinanceCategory.training,
    title: 'Pilot branch training materials',
    requestedBy: 'Dian Lestari',
    requestedAmount: 8500000,
    status: ProjectFinanceRecordStatus.approved,
    evidenceLabel: 'Invoice, delivery note, branch receipt',
  ),
  ProjectExpenseRequest(
    id: 'warehouse-automation-sensor-freight',
    projectId: 'warehouse-automation',
    category: ProjectFinanceCategory.logistics,
    title: 'Sensor freight acceleration',
    requestedBy: 'Tomi Nugraha',
    requestedAmount: 12000000,
    status: ProjectFinanceRecordStatus.blocked,
    evidenceLabel: 'Freight quote and sponsor exception',
  ),
  ProjectExpenseRequest(
    id: 'mobile-field-app-device-lab',
    projectId: 'mobile-field-app',
    category: ProjectFinanceCategory.technology,
    title: 'Device testing lab',
    requestedBy: 'Arman Yusuf',
    requestedAmount: 6000000,
    status: ProjectFinanceRecordStatus.submitted,
    evidenceLabel: 'Vendor quote and test plan',
  ),
];

final demoProjectPettyCashEntries = [
  ProjectPettyCashEntry(
    id: 'retail-modernization-store-float',
    projectId: 'retail-modernization',
    title: 'Pilot store project float',
    custodian: 'Maya Santoso',
    amount: 5000000,
    status: ProjectFinanceRecordStatus.paid,
    reconciliationDueDate: DateTime(2026, 6, 28),
  ),
  ProjectPettyCashEntry(
    id: 'warehouse-automation-site-float',
    projectId: 'warehouse-automation',
    title: 'Fulfillment floor float',
    custodian: 'Rafi Prakoso',
    amount: 7500000,
    status: ProjectFinanceRecordStatus.blocked,
    reconciliationDueDate: DateTime(2026, 6, 24),
  ),
];

const demoProjectApprovalRecords = [
  ProjectApprovalRecord(
    id: 'retail-modernization-training-approval',
    projectId: 'retail-modernization',
    title: 'Training materials approval',
    approver: 'Retail Operations',
    amount: 8500000,
    status: ProjectFinanceRecordStatus.approved,
    thresholdLabel: 'Store rollout approval threshold',
  ),
  ProjectApprovalRecord(
    id: 'warehouse-automation-freight-exception',
    projectId: 'warehouse-automation',
    title: 'Freight acceleration exception',
    approver: 'Supply Chain Sponsor',
    amount: 12000000,
    status: ProjectFinanceRecordStatus.blocked,
    thresholdLabel: 'Budget exception route',
  ),
  ProjectApprovalRecord(
    id: 'mobile-field-app-device-approval',
    projectId: 'mobile-field-app',
    title: 'Device lab approval',
    approver: 'Customer Service Sponsor',
    amount: 6000000,
    status: ProjectFinanceRecordStatus.submitted,
    thresholdLabel: 'Software spend approval threshold',
  ),
];

const demoProjectReconciliationEvidence = [
  ProjectReconciliationEvidence(
    id: 'retail-modernization-training-evidence',
    projectId: 'retail-modernization',
    title: 'Training delivery proof',
    owner: 'Iqbal Karim',
    status: ProjectFinanceRecordStatus.submitted,
    evidenceLabel: 'Attendance sheet and receipt bundle',
  ),
  ProjectReconciliationEvidence(
    id: 'warehouse-automation-freight-evidence',
    projectId: 'warehouse-automation',
    title: 'Freight exception evidence',
    owner: 'Rafi Prakoso',
    status: ProjectFinanceRecordStatus.blocked,
    evidenceLabel: 'Sponsor approval and supplier invoice',
  ),
  ProjectReconciliationEvidence(
    id: 'finance-close-suite-audit-export',
    projectId: 'finance-close-suite',
    title: 'Audit export sample',
    owner: 'Citra Maheswari',
    status: ProjectFinanceRecordStatus.reconciled,
    evidenceLabel: 'Reviewer sample and export receipt',
  ),
];
