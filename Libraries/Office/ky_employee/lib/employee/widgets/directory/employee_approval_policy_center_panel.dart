import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_approval_policy_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_approval_policy_provider.dart';
import 'employee_approval_policy_form.dart';
import 'employee_approval_policy_tiles.dart';

class EmployeeApprovalPolicyCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeApprovalPolicyCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeApprovalPolicyCenterPanel> createState() =>
      _EmployeeApprovalPolicyCenterPanelState();
}

class _EmployeeApprovalPolicyCenterPanelState
    extends ConsumerState<EmployeeApprovalPolicyCenterPanel> {
  final _nameController = TextEditingController();
  final _ownerController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _thresholdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeApprovalPolicyProfileProvider(employeeId),
    );
    final draft = ref.watch(employeeApprovalPolicyDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_nameController, draft.name);
    _sync(_ownerController, draft.owner);
    _sync(_thresholdController, draft.thresholdLabel);
    _sync(_notesController, draft.notes);

    return HrisSectionPanel(
      icon: Icons.rule_folder_outlined,
      title: 'Approval policy rules',
      subtitle: profile.nextAction,
      children: [
        EmployeeApprovalPolicySummaryStrip(profile: profile),
        EmployeeApprovalPolicyStatusCard(profile: profile),
        EmployeeApprovalPolicyRuleForm(
          draft: draft,
          nameController: _nameController,
          ownerController: _ownerController,
          thresholdController: _thresholdController,
          notesController: _notesController,
          onAreaChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setArea,
          onNameChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setName,
          onPrimaryRouteChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setPrimaryRoute,
          onFallbackRouteChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setFallbackRoute,
          onOwnerChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onThresholdChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setThresholdLabel,
          onEscalationHoursChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setEscalationHours,
          onEscalationModeChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setEscalationMode,
          onRiskChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setRisk,
          onNotesChanged:
              ref
                  .read(
                    employeeApprovalPolicyDraftProvider(employeeId).notifier,
                  )
                  .setNotes,
          onSelectExpiry: () => _selectExpiry(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (profile.rules.isEmpty)
          const HrisEmptyState(message: 'No approval policy rules configured')
        else
          ...profile.sortedRules.map(
            (rule) => EmployeeApprovalPolicyRuleTile(
              rule: rule,
              asOfDate: profile.asOfDate,
              onActivate:
                  () => ref
                      .read(
                        employeeApprovalPolicyProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .activate(rule.id),
              onReview:
                  () => ref
                      .read(
                        employeeApprovalPolicyProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .requestReview(rule.id),
              onSuspend:
                  () => ref
                      .read(
                        employeeApprovalPolicyProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .suspend(rule.id),
              onRenew:
                  () => ref
                      .read(
                        employeeApprovalPolicyProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .renew(rule.id),
              onRemove:
                  () => ref
                      .read(
                        employeeApprovalPolicyProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .remove(rule.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectExpiry(EmployeeApprovalPolicyRuleDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.expiresOn ?? draft.asOfDate.add(const Duration(days: 90)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 1825)),
    );
    if (picked == null) return;
    ref
        .read(employeeApprovalPolicyDraftProvider(draft.employeeId).notifier)
        .setExpiresOn(picked);
  }

  void _submitDraft(EmployeeApprovalPolicyRuleDraft draft) {
    try {
      final rule = ref
          .read(
            employeeApprovalPolicyProfileProvider(draft.employeeId).notifier,
          )
          .submitDraft(draft);
      ref
          .read(employeeApprovalPolicyDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${rule.name} added to ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}
