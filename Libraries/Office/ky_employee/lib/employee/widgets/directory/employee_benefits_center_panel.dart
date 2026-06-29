import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_benefits_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_benefits_provider.dart';
import 'employee_benefits_dependent_form.dart';
import 'employee_benefits_tiles.dart';

class EmployeeBenefitsCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeBenefitsCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeBenefitsCenterPanel> createState() =>
      _EmployeeBenefitsCenterPanelState();
}

class _EmployeeBenefitsCenterPanelState
    extends ConsumerState<EmployeeBenefitsCenterPanel> {
  final _dependentNameController = TextEditingController();

  @override
  void dispose() {
    _dependentNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeBenefitsProfileProvider(employeeId));
    final draft = ref.watch(employeeDependentDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_dependentNameController, draft.fullName);

    final enrollments = [...profile.enrollments]..sort((a, b) {
      final aAttention = a.needsAttention(profile.asOfDate);
      final bAttention = b.needsAttention(profile.asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return a.type.index.compareTo(b.type.index);
    });
    final dependents = [...profile.dependents]..sort((a, b) {
      if (a.needsAttention != b.needsAttention) {
        return a.needsAttention ? -1 : 1;
      }
      return a.fullName.compareTo(b.fullName);
    });

    return HrisSectionPanel(
      icon: Icons.health_and_safety_outlined,
      title: 'Benefits and dependents',
      subtitle: profile.nextAction,
      children: [
        EmployeeBenefitsSummaryStrip(profile: profile),
        EmployeeDependentForm(
          draft: draft,
          nameController: _dependentNameController,
          onNameChanged:
              ref
                  .read(employeeDependentDraftProvider(employeeId).notifier)
                  .setFullName,
          onRelationshipChanged:
              ref
                  .read(employeeDependentDraftProvider(employeeId).notifier)
                  .setRelationship,
          onEligibleChanged:
              ref
                  .read(employeeDependentDraftProvider(employeeId).notifier)
                  .setEligibleForCoverage,
          onSelectBirthDate: () => _selectBirthDate(draft),
          onAdd: () => _addDependent(draft),
        ),
        ...enrollments.map(
          (enrollment) => EmployeeBenefitEnrollmentTile(
            enrollment: enrollment,
            asOfDate: profile.asOfDate,
            onCoverageTierChanged:
                (tier) => ref
                    .read(employeeBenefitsProfileProvider(employeeId).notifier)
                    .changeCoverageTier(enrollment.id, tier),
            onActivate:
                () => ref
                    .read(employeeBenefitsProfileProvider(employeeId).notifier)
                    .updateEnrollmentStatus(
                      enrollment.id,
                      EmployeeBenefitEnrollmentStatus.active,
                    ),
            onWaive:
                () => ref
                    .read(employeeBenefitsProfileProvider(employeeId).notifier)
                    .updateEnrollmentStatus(
                      enrollment.id,
                      EmployeeBenefitEnrollmentStatus.waived,
                    ),
          ),
        ),
        if (dependents.isEmpty)
          const HrisListSurface(child: Text('No dependents recorded yet.'))
        else
          ...dependents.map(
            (dependent) => EmployeeDependentRecordTile(
              dependent: dependent,
              asOfDate: profile.asOfDate,
              onVerify:
                  () => ref
                      .read(
                        employeeBenefitsProfileProvider(employeeId).notifier,
                      )
                      .verifyDependent(dependent.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectBirthDate(EmployeeDependentDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.birthDate ??
          draft.asOfDate.subtract(const Duration(days: 3650)),
      firstDate: draft.asOfDate.subtract(const Duration(days: 365 * 100)),
      lastDate: draft.asOfDate,
    );
    if (picked == null) return;
    ref
        .read(employeeDependentDraftProvider(draft.employeeId).notifier)
        .setBirthDate(picked);
  }

  void _addDependent(EmployeeDependentDraft draft) {
    try {
      final dependent = ref
          .read(employeeBenefitsProfileProvider(draft.employeeId).notifier)
          .addDependent(draft);
      ref
          .read(employeeDependentDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${dependent.fullName} added to ${draft.employeeName}');
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
