import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_development_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_development_provider.dart';
import 'employee_development_learning_form.dart';
import 'employee_development_tiles.dart';

class EmployeeDevelopmentCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeDevelopmentCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeDevelopmentCenterPanel> createState() =>
      _EmployeeDevelopmentCenterPanelState();
}

class _EmployeeDevelopmentCenterPanelState
    extends ConsumerState<EmployeeDevelopmentCenterPanel> {
  final _titleController = TextEditingController();
  final _providerController = TextEditingController();
  final _skillFocusController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _providerController.dispose();
    _skillFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final plan = ref.watch(employeeDevelopmentPlanProvider(employeeId));
    final draft = ref.watch(
      employeeLearningAssignmentDraftProvider(employeeId),
    );

    if (plan == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_providerController, draft.provider);
    _sync(_skillFocusController, draft.skillFocus);

    final skills = [...plan.skills]..sort((a, b) {
      if (a.needsAttention != b.needsAttention) {
        return a.needsAttention ? -1 : 1;
      }
      return b.levelGap.compareTo(a.levelGap);
    });
    final learning = [...plan.learning]..sort((a, b) {
      final aOverdue = a.isOverdue(plan.asOfDate);
      final bOverdue = b.isOverdue(plan.asOfDate);
      if (aOverdue != bOverdue) return aOverdue ? -1 : 1;
      if (a.isComplete != b.isComplete) return a.isComplete ? 1 : -1;
      return a.dueDate.compareTo(b.dueDate);
    });
    final certifications = [...plan.certifications]..sort((a, b) {
      final aAttention = a.needsAttention(plan.asOfDate);
      final bAttention = b.needsAttention(plan.asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return a.expiryDate.compareTo(b.expiryDate);
    });

    return HrisSectionPanel(
      icon: Icons.school_outlined,
      title: 'Development center',
      subtitle: plan.nextAction,
      children: [
        EmployeeDevelopmentSummaryStrip(plan: plan),
        EmployeeLearningAssignmentForm(
          draft: draft,
          titleController: _titleController,
          providerController: _providerController,
          skillFocusController: _skillFocusController,
          onTitleChanged:
              ref
                  .read(
                    employeeLearningAssignmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTitle,
          onProviderChanged:
              ref
                  .read(
                    employeeLearningAssignmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setProvider,
          onSkillFocusChanged:
              ref
                  .read(
                    employeeLearningAssignmentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setSkillFocus,
          onSelectDueDate: () => _selectDueDate(draft),
          onAdd: () => _addLearning(draft),
        ),
        ...skills.map(
          (skill) => EmployeeSkillTargetTile(
            skill: skill,
            onLevelUp:
                () => ref
                    .read(employeeDevelopmentPlanProvider(employeeId).notifier)
                    .updateSkillLevel(skill.id, skill.currentLevel + 1),
          ),
        ),
        if (learning.isEmpty)
          const HrisListSurface(child: Text('No learning assignments yet.'))
        else
          ...learning.map(
            (item) => EmployeeLearningAssignmentTile(
              item: item,
              asOfDate: plan.asOfDate,
              onAdvance:
                  () => ref
                      .read(
                        employeeDevelopmentPlanProvider(employeeId).notifier,
                      )
                      .advanceLearning(item.id, 0.15),
              onComplete:
                  () => ref
                      .read(
                        employeeDevelopmentPlanProvider(employeeId).notifier,
                      )
                      .completeLearning(item.id),
            ),
          ),
        ...certifications.map(
          (certification) => EmployeeCertificationTargetTile(
            certification: certification,
            asOfDate: plan.asOfDate,
            onRenew: () => _renewCertification(certification),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDueDate(EmployeeLearningAssignmentDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.dueDate ?? draft.asOfDate.add(const Duration(days: 21)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeLearningAssignmentDraftProvider(draft.employeeId).notifier,
        )
        .setDueDate(picked);
  }

  void _addLearning(EmployeeLearningAssignmentDraft draft) {
    try {
      final assignment = ref
          .read(employeeDevelopmentPlanProvider(draft.employeeId).notifier)
          .addLearning(draft);
      ref
          .read(
            employeeLearningAssignmentDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${assignment.title} added to ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _renewCertification(EmployeeCertificationTarget certification) {
    final nextExpiry = widget.snapshot.asOfDate.add(const Duration(days: 365));
    ref
        .read(
          employeeDevelopmentPlanProvider(certification.employeeId).notifier,
        )
        .renewCertification(certification.id, nextExpiry);
    _showMessage('${certification.name} renewed');
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
