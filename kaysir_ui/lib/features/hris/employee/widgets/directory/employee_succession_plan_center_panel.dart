import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_succession_plan_models.dart';
import '../../states/employee_directory_provider.dart';
import '../../states/employee_succession_plan_provider.dart';
import 'employee_succession_candidate_form.dart';
import 'employee_succession_plan_tiles.dart';

class EmployeeSuccessionPlanCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeSuccessionPlanCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeSuccessionPlanCenterPanel> createState() =>
      _EmployeeSuccessionPlanCenterPanelState();
}

class _EmployeeSuccessionPlanCenterPanelState
    extends ConsumerState<EmployeeSuccessionPlanCenterPanel> {
  final _coverageOwnerController = TextEditingController();
  final _candidateNameController = TextEditingController();
  final _candidateCurrentRoleController = TextEditingController();
  final _candidateTargetRoleController = TextEditingController();
  final _candidateOwnerController = TextEditingController();
  final _candidateNotesController = TextEditingController();

  @override
  void dispose() {
    _coverageOwnerController.dispose();
    _candidateNameController.dispose();
    _candidateCurrentRoleController.dispose();
    _candidateTargetRoleController.dispose();
    _candidateOwnerController.dispose();
    _candidateNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeSuccessionProfileProvider(employeeId));
    final draft = ref.watch(
      employeeSuccessionCandidateDraftProvider(employeeId),
    );

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_coverageOwnerController, profile.coverageOwner);
    _sync(_candidateNameController, draft.name);
    _sync(_candidateCurrentRoleController, draft.currentRole);
    _sync(_candidateTargetRoleController, draft.targetRole);
    _sync(_candidateOwnerController, draft.owner);
    _sync(_candidateNotesController, draft.notes);

    return HrisSectionPanel(
      icon: Icons.verified_user_outlined,
      title: 'Succession coverage',
      subtitle: profile.nextAction,
      children: [
        EmployeeSuccessionSummaryStrip(profile: profile),
        EmployeeSuccessionCoverageCard(
          profile: profile,
          ownerController: _coverageOwnerController,
          onCriticalityChanged:
              ref
                  .read(employeeSuccessionProfileProvider(employeeId).notifier)
                  .setCriticality,
          onOwnerChanged:
              ref
                  .read(employeeSuccessionProfileProvider(employeeId).notifier)
                  .setCoverageOwner,
          onSelectReviewDate: () => _selectCoverageReviewDate(profile),
          onMarkReviewed: () {
            ref
                .read(employeeSuccessionProfileProvider(employeeId).notifier)
                .markReviewed();
            _showMessage('Succession coverage review marked current');
          },
          onReset:
              ref
                  .read(employeeSuccessionProfileProvider(employeeId).notifier)
                  .resetToPreset,
        ),
        EmployeeSuccessionCandidateForm(
          draft: draft,
          nameController: _candidateNameController,
          currentRoleController: _candidateCurrentRoleController,
          targetRoleController: _candidateTargetRoleController,
          ownerController: _candidateOwnerController,
          notesController: _candidateNotesController,
          onNameChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setName,
          onCurrentRoleChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setCurrentRole,
          onTargetRoleChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTargetRole,
          onReadinessChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setReadiness,
          onRiskChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setRisk,
          onActionTypeChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setActionType,
          onOwnerChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onBenchScoreChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setBenchScore,
          onNotesChanged:
              ref
                  .read(
                    employeeSuccessionCandidateDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setNotes,
          onSelectReviewDate: () => _selectCandidateReviewDate(draft),
          onAdd: () => _addCandidate(draft),
        ),
        if (profile.candidates.isEmpty)
          const HrisEmptyState(message: 'No successor candidates yet')
        else
          ...profile.sortedCandidates.map(
            (candidate) => EmployeeSuccessionCandidateTile(
              candidate: candidate,
              asOfDate: profile.asOfDate,
              onReadinessChanged:
                  (readiness) => ref
                      .read(
                        employeeSuccessionProfileProvider(employeeId).notifier,
                      )
                      .updateReadiness(candidate.id, readiness),
              onRiskChanged:
                  (risk) => ref
                      .read(
                        employeeSuccessionProfileProvider(employeeId).notifier,
                      )
                      .updateRisk(candidate.id, risk),
              onActionChanged:
                  (action) => ref
                      .read(
                        employeeSuccessionProfileProvider(employeeId).notifier,
                      )
                      .updateActionType(candidate.id, action),
              onScheduleReview: () => _scheduleCandidateReview(candidate),
              onRemove:
                  () => ref
                      .read(
                        employeeSuccessionProfileProvider(employeeId).notifier,
                      )
                      .removeCandidate(candidate.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectCoverageReviewDate(
    EmployeeSuccessionProfile profile,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          profile.reviewDate.isBefore(profile.asOfDate)
              ? profile.asOfDate
              : profile.reviewDate,
      firstDate: profile.asOfDate,
      lastDate: profile.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeSuccessionProfileProvider(profile.employeeId).notifier)
        .setReviewDate(picked);
  }

  Future<void> _selectCandidateReviewDate(
    EmployeeSuccessionCandidateDraft draft,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.reviewDate ?? draft.asOfDate.add(const Duration(days: 30)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeSuccessionCandidateDraftProvider(draft.employeeId).notifier,
        )
        .setReviewDate(picked);
  }

  Future<void> _scheduleCandidateReview(
    EmployeeSuccessionCandidate candidate,
  ) async {
    final asOfDate = ref.read(employeeDirectoryAsOfDateProvider);
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final picked = await showDatePicker(
      context: context,
      initialDate:
          candidate.reviewDate.isBefore(today) ? today : candidate.reviewDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeSuccessionProfileProvider(candidate.employeeId).notifier)
        .scheduleCandidateReview(candidate.id, picked);
  }

  void _addCandidate(EmployeeSuccessionCandidateDraft draft) {
    try {
      final candidate = ref
          .read(employeeSuccessionProfileProvider(draft.employeeId).notifier)
          .addCandidate(draft);
      ref
          .read(
            employeeSuccessionCandidateDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${candidate.name} added as successor candidate');
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
