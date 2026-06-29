import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/compliance_provider.dart';
import '../widgets/compliance_audit_panel.dart';
import '../widgets/compliance_control_panel.dart';
import '../widgets/compliance_document_panel.dart';
import '../widgets/compliance_policy_panel.dart';
import '../widgets/compliance_summary_grid.dart';

class ComplianceScreen extends ConsumerWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final departments = ref.watch(complianceDepartmentsProvider);
    final selectedDepartment = ref.watch(complianceDepartmentProvider);
    final attentionOnly = ref.watch(complianceAttentionOnlyProvider);
    final summary = ref.watch(complianceSummaryProvider);
    final controls = ref.watch(filteredComplianceControlsProvider);
    final policies = ref.watch(filteredPolicyAcknowledgementsProvider);
    final documents = ref.watch(filteredComplianceDocumentsProvider);
    final findings = ref.watch(filteredAuditFindingsProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Compliance & Risk'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(complianceControlsProvider);
              ref.invalidate(policyAcknowledgementsProvider);
              ref.invalidate(complianceDocumentsProvider);
              ref.invalidate(auditFindingsProvider);
            },
          ),
          IconButton(
            tooltip: 'Create control',
            icon: const Icon(Icons.add_task_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compliance control drafted')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HrisCommandHeader(
                icon: Icons.gpp_maybe_outlined,
                title: 'Compliance Command Center',
                subtitle: 'Controls, policies, documents, and remediation',
                departments: departments,
                selectedDepartment: selectedDepartment,
                attentionOnly: attentionOnly,
                onDepartmentChanged: (value) {
                  if (value != null) {
                    ref.read(complianceDepartmentProvider.notifier).state =
                        value;
                  }
                },
                onAttentionChanged: (value) {
                  ref.read(complianceAttentionOnlyProvider.notifier).state =
                      value;
                },
              ),
              const SizedBox(height: 16),
              ComplianceSummaryGrid(summary: summary),
              const SizedBox(height: 16),
              HrisResponsivePanelGrid(
                panels: [
                  ComplianceControlPanel(controls: controls),
                  CompliancePolicyPanel(policies: policies),
                  ComplianceDocumentPanel(documents: documents),
                  ComplianceAuditPanel(findings: findings),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
