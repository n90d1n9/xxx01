import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_data_correction_governance_models.dart';
import '../../models/employee_data_correction_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_data_correction_governance_provider.dart';
import 'employee_data_correction_evidence_form.dart';
import 'employee_data_correction_governance_tiles.dart';

class EmployeeDataCorrectionGovernancePanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeDataCorrectionGovernancePanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeDataCorrectionGovernancePanel> createState() =>
      _EmployeeDataCorrectionGovernancePanelState();
}

class _EmployeeDataCorrectionGovernancePanelState
    extends ConsumerState<EmployeeDataCorrectionGovernancePanel> {
  final _authorController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _authorController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeDataCorrectionGovernanceProvider(employeeId),
    );
    final draft = ref.watch(
      employeeDataCorrectionEvidenceDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_authorController, draft.author);
    _sync(_summaryController, draft.summary);

    final requests =
        profile.requests.where((request) => request.isOpen).toList();

    return HrisSectionPanel(
      icon: Icons.policy_outlined,
      title: 'Correction governance',
      subtitle: profile.nextAction,
      children: [
        EmployeeDataCorrectionGovernanceSummaryStrip(profile: profile),
        if (requests.isEmpty)
          const HrisEmptyState(message: 'No open corrections to govern')
        else
          EmployeeDataCorrectionEvidenceForm(
            draft: draft,
            requests: requests,
            authorController: _authorController,
            summaryController: _summaryController,
            onRequestChanged:
                ref
                    .read(
                      employeeDataCorrectionEvidenceDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setRequestId,
            onAuthorChanged:
                ref
                    .read(
                      employeeDataCorrectionEvidenceDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setAuthor,
            onSummaryChanged:
                ref
                    .read(
                      employeeDataCorrectionEvidenceDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setSummary,
            onAdd: () => _addEvidence(draft),
          ),
        if (profile.sortedRules.isEmpty)
          const HrisEmptyState(message: 'No correction governance rules')
        else
          ...profile.sortedRules.map(
            (rule) => EmployeeDataCorrectionGovernanceRuleTile(
              rule: rule,
              onWaive: () => _waive(rule),
              onReinstate: () => _reinstate(rule),
            ),
          ),
        ...profile.latestEvidence.map(
          (evidence) => EmployeeDataCorrectionEvidenceTile(
            evidence: evidence,
            requestField: _requestField(profile.requests, evidence.requestId),
          ),
        ),
      ],
    );
  }

  void _addEvidence(EmployeeDataCorrectionEvidenceDraft draft) {
    try {
      final evidence = ref
          .read(
            employeeDataCorrectionGovernanceProvider(draft.employeeId).notifier,
          )
          .addEvidence(draft);
      ref
          .read(
            employeeDataCorrectionEvidenceDraftProvider(
              draft.employeeId,
            ).notifier,
          )
          .reset();
      _showMessage('${evidence.id} evidence added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _waive(EmployeeDataCorrectionGovernanceRule rule) {
    ref
        .read(
          employeeDataCorrectionGovernanceProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .waiveRule(rule.id);
    _showMessage('${rule.title} waived');
  }

  void _reinstate(EmployeeDataCorrectionGovernanceRule rule) {
    ref
        .read(
          employeeDataCorrectionGovernanceProvider(
            widget.snapshot.member.id,
          ).notifier,
        )
        .reinstateRule(rule.id);
    _showMessage('${rule.title} reinstated');
  }

  String _requestField(
    List<EmployeeDataCorrectionRequest> requests,
    String requestId,
  ) {
    for (final request in requests) {
      if (request.id == requestId) return request.field;
    }
    return 'Correction evidence';
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
