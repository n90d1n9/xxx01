import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_access_governance_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_access_governance_provider.dart';
import 'employee_access_governance_form.dart';
import 'employee_access_governance_tiles.dart';

class EmployeeAccessGovernanceCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeAccessGovernanceCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeAccessGovernanceCenterPanel> createState() =>
      _EmployeeAccessGovernanceCenterPanelState();
}

class _EmployeeAccessGovernanceCenterPanelState
    extends ConsumerState<EmployeeAccessGovernanceCenterPanel> {
  final _systemController = TextEditingController();
  final _roleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _reviewerController = TextEditingController();
  final _justificationController = TextEditingController();

  @override
  void dispose() {
    _systemController.dispose();
    _roleController.dispose();
    _ownerController.dispose();
    _reviewerController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeAccessGovernanceProfileProvider(employeeId),
    );
    final draft = ref.watch(employeeAccessGovernanceDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_systemController, draft.systemName);
    _sync(_roleController, draft.roleName);
    _sync(_ownerController, draft.owner);
    _sync(_reviewerController, draft.reviewer);
    _sync(_justificationController, draft.businessJustification);

    final reviews = [...profile.reviews]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        profile.asOfDate,
      ).compareTo(_attentionRank(b, profile.asOfDate));
      if (attentionCompare != 0) return attentionCompare;
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return a.dueDate.compareTo(b.dueDate);
    });

    return HrisSectionPanel(
      icon: Icons.security_outlined,
      title: 'Access governance',
      subtitle: profile.nextAction,
      children: [
        EmployeeAccessGovernanceSummaryStrip(profile: profile),
        EmployeeAccessGovernanceForm(
          draft: draft,
          systemController: _systemController,
          roleController: _roleController,
          ownerController: _ownerController,
          reviewerController: _reviewerController,
          justificationController: _justificationController,
          onSystemChanged:
              ref
                  .read(
                    employeeAccessGovernanceDraftProvider(employeeId).notifier,
                  )
                  .setSystemName,
          onRoleChanged:
              ref
                  .read(
                    employeeAccessGovernanceDraftProvider(employeeId).notifier,
                  )
                  .setRoleName,
          onOwnerChanged:
              ref
                  .read(
                    employeeAccessGovernanceDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onReviewerChanged:
              ref
                  .read(
                    employeeAccessGovernanceDraftProvider(employeeId).notifier,
                  )
                  .setReviewer,
          onJustificationChanged:
              ref
                  .read(
                    employeeAccessGovernanceDraftProvider(employeeId).notifier,
                  )
                  .setBusinessJustification,
          onScopeChanged:
              ref
                  .read(
                    employeeAccessGovernanceDraftProvider(employeeId).notifier,
                  )
                  .setScope,
          onRiskChanged:
              ref
                  .read(
                    employeeAccessGovernanceDraftProvider(employeeId).notifier,
                  )
                  .setRisk,
          onSelectDueDate: () => _selectDueDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (reviews.isEmpty)
          const HrisListSurface(child: Text('No access reviews recorded.'))
        else
          ...reviews.map(
            (review) => EmployeeAccessGovernanceReviewTile(
              review: review,
              asOfDate: profile.asOfDate,
              onApprove:
                  () => ref
                      .read(
                        employeeAccessGovernanceProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .approveReview(review.id),
              onRequestRevoke:
                  () => ref
                      .read(
                        employeeAccessGovernanceProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .requestRevoke(review.id),
              onCompleteRevoke:
                  () => ref
                      .read(
                        employeeAccessGovernanceProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .completeRevoke(review.id),
              onMarkException:
                  () => ref
                      .read(
                        employeeAccessGovernanceProfileProvider(
                          employeeId,
                        ).notifier,
                      )
                      .markException(review.id),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDueDate(EmployeeAccessGovernanceDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeAccessGovernanceDraftProvider(draft.employeeId).notifier)
        .setDueDate(picked);
  }

  void _submitDraft(EmployeeAccessGovernanceDraft draft) {
    try {
      final review = ref
          .read(
            employeeAccessGovernanceProfileProvider(draft.employeeId).notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            employeeAccessGovernanceDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${review.id} added for ${review.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  int _attentionRank(EmployeeAccessGovernanceReview review, DateTime asOfDate) {
    return review.needsAttention(asOfDate) ? 0 : 1;
  }

  int _statusRank(EmployeeAccessGovernanceStatus status) {
    return switch (status) {
      EmployeeAccessGovernanceStatus.revokeRequested => 0,
      EmployeeAccessGovernanceStatus.dueReview => 1,
      EmployeeAccessGovernanceStatus.exception => 2,
      EmployeeAccessGovernanceStatus.approved => 3,
      EmployeeAccessGovernanceStatus.revoked => 4,
    };
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
