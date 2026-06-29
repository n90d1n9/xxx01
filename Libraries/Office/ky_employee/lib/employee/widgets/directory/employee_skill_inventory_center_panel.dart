import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_skill_inventory_models.dart';
import '../../states/employee_skill_inventory_provider.dart';
import 'employee_skill_evidence_form.dart';
import 'employee_skill_inventory_tiles.dart';

class EmployeeSkillInventoryCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeSkillInventoryCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeSkillInventoryCenterPanel> createState() =>
      _EmployeeSkillInventoryCenterPanelState();
}

class _EmployeeSkillInventoryCenterPanelState
    extends ConsumerState<EmployeeSkillInventoryCenterPanel> {
  final _skillController = TextEditingController();
  final _verifierController = TextEditingController();
  final _evidenceController = TextEditingController();

  @override
  void dispose() {
    _skillController.dispose();
    _verifierController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeSkillInventoryProvider(employeeId));
    final draft = ref.watch(employeeSkillEvidenceDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_skillController, draft.skillName);
    _sync(_verifierController, draft.verifier);
    _sync(_evidenceController, draft.evidenceSummary);

    return HrisSectionPanel(
      icon: Icons.inventory_2_outlined,
      title: 'Skills inventory',
      subtitle: profile.nextAction,
      children: [
        EmployeeSkillInventorySummaryStrip(profile: profile),
        EmployeeSkillEvidenceForm(
          draft: draft,
          skillController: _skillController,
          verifierController: _verifierController,
          evidenceController: _evidenceController,
          onSkillChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setSkillName,
          onCategoryChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setCategory,
          onEvidenceTypeChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setEvidenceType,
          onVerifierChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setVerifier,
          onEvidenceChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setEvidenceSummary,
          onObservedLevelChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setObservedLevel,
          onRequiredLevelChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setRequiredLevel,
          onCriticalityChanged:
              ref
                  .read(employeeSkillEvidenceDraftProvider(employeeId).notifier)
                  .setCriticality,
          onSelectReviewDate: () => _selectReviewDate(draft),
          onAddEvidence: () => _addEvidence(draft),
        ),
        ...profile.priorityRecords.map(
          (record) => EmployeeSkillRecordTile(
            record: record,
            asOfDate: profile.asOfDate,
            onVerify: () => _verifySkill(record),
            onRequestEvidence: () => _requestEvidence(record),
            onWaive: () => _waiveSkill(record),
            onLevelUp: () => _levelUp(record),
          ),
        ),
      ],
    );
  }

  Future<void> _selectReviewDate(EmployeeSkillEvidenceDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.nextReviewDate ?? draft.asOfDate.add(const Duration(days: 30)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeSkillEvidenceDraftProvider(draft.employeeId).notifier)
        .setNextReviewDate(picked);
  }

  void _addEvidence(EmployeeSkillEvidenceDraft draft) {
    try {
      final record = ref
          .read(employeeSkillInventoryProvider(draft.employeeId).notifier)
          .addEvidence(draft);
      ref
          .read(employeeSkillEvidenceDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${record.skillName} evidence added');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _verifySkill(EmployeeSkillRecord record) {
    ref
        .read(employeeSkillInventoryProvider(record.employeeId).notifier)
        .verifySkill(record.id);
    _showMessage('${record.skillName} verified');
  }

  void _requestEvidence(EmployeeSkillRecord record) {
    ref
        .read(employeeSkillInventoryProvider(record.employeeId).notifier)
        .requestEvidence(record.id);
    _showMessage('Evidence requested for ${record.skillName}');
  }

  void _waiveSkill(EmployeeSkillRecord record) {
    ref
        .read(employeeSkillInventoryProvider(record.employeeId).notifier)
        .waiveSkill(record.id);
    _showMessage('${record.skillName} waived');
  }

  void _levelUp(EmployeeSkillRecord record) {
    ref
        .read(employeeSkillInventoryProvider(record.employeeId).notifier)
        .updateObservedLevel(record.id, record.currentLevel + 1);
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
