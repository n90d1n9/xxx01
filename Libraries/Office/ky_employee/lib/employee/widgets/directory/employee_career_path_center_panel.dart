import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_career_path_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_career_path_provider.dart';
import 'employee_career_move_form.dart';
import 'employee_career_path_tiles.dart';

class EmployeeCareerPathCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeCareerPathCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeCareerPathCenterPanel> createState() =>
      _EmployeeCareerPathCenterPanelState();
}

class _EmployeeCareerPathCenterPanelState
    extends ConsumerState<EmployeeCareerPathCenterPanel> {
  final _titleController = TextEditingController();
  final _sponsorController = TextEditingController();
  final _targetRoleController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _sponsorController.dispose();
    _targetRoleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeCareerPathProfileProvider(employeeId));
    final draft = ref.watch(employeeCareerMoveDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_sponsorController, draft.sponsor);
    _sync(_targetRoleController, draft.targetRole);
    _sync(_summaryController, draft.summary);

    final moves = [...profile.moves]..sort((a, b) {
      final statusCompare = _moveRank(a.status).compareTo(_moveRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return a.targetDate.compareTo(b.targetDate);
    });

    return HrisSectionPanel(
      icon: Icons.account_tree_outlined,
      title: 'Career and succession',
      subtitle: profile.nextAction,
      children: [
        EmployeeCareerPathSummaryStrip(profile: profile),
        EmployeeCareerPathCard(
          path: profile.path,
          asOfDate: profile.asOfDate,
          onReadinessChanged:
              ref
                  .read(employeeCareerPathProfileProvider(employeeId).notifier)
                  .setReadiness,
          onCoverageChanged:
              ref
                  .read(employeeCareerPathProfileProvider(employeeId).notifier)
                  .setSuccessionCoverage,
          onMarkReviewed: () {
            ref
                .read(employeeCareerPathProfileProvider(employeeId).notifier)
                .markReviewed();
            _showMessage('Talent review marked current');
          },
        ),
        EmployeeCareerMoveForm(
          draft: draft,
          titleController: _titleController,
          sponsorController: _sponsorController,
          targetRoleController: _targetRoleController,
          summaryController: _summaryController,
          onTypeChanged:
              ref
                  .read(employeeCareerMoveDraftProvider(employeeId).notifier)
                  .setType,
          onTitleChanged:
              ref
                  .read(employeeCareerMoveDraftProvider(employeeId).notifier)
                  .setTitle,
          onSponsorChanged:
              ref
                  .read(employeeCareerMoveDraftProvider(employeeId).notifier)
                  .setSponsor,
          onTargetRoleChanged:
              ref
                  .read(employeeCareerMoveDraftProvider(employeeId).notifier)
                  .setTargetRole,
          onSummaryChanged:
              ref
                  .read(employeeCareerMoveDraftProvider(employeeId).notifier)
                  .setSummary,
          onSelectTargetDate: () => _selectTargetDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (moves.isEmpty)
          const HrisListSurface(child: Text('No career moves proposed.'))
        else
          ...moves.map(
            (move) => EmployeeCareerMoveRequestTile(
              move: move,
              onApprove: () {
                ref
                    .read(
                      employeeCareerPathProfileProvider(employeeId).notifier,
                    )
                    .approveMove(move.id);
              },
              onActivate: () {
                ref
                    .read(
                      employeeCareerPathProfileProvider(employeeId).notifier,
                    )
                    .activateMove(move.id);
              },
              onComplete: () => _completeMove(move),
              onDecline: () {
                ref
                    .read(
                      employeeCareerPathProfileProvider(employeeId).notifier,
                    )
                    .declineMove(move.id);
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectTargetDate(EmployeeCareerMoveDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.targetDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeCareerMoveDraftProvider(draft.employeeId).notifier)
        .setTargetDate(picked);
  }

  void _submitDraft(EmployeeCareerMoveDraft draft) {
    try {
      final request = ref
          .read(employeeCareerPathProfileProvider(draft.employeeId).notifier)
          .submitDraft(draft);
      ref
          .read(employeeCareerMoveDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${request.title} proposed for ${request.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _completeMove(EmployeeCareerMoveRequest move) {
    ref
        .read(employeeCareerPathProfileProvider(move.employeeId).notifier)
        .completeMove(move.id);
    _showMessage('${move.title} completed');
  }

  int _moveRank(EmployeeCareerMoveStatus status) {
    return switch (status) {
      EmployeeCareerMoveStatus.proposed => 0,
      EmployeeCareerMoveStatus.approved => 1,
      EmployeeCareerMoveStatus.active => 2,
      EmployeeCareerMoveStatus.completed => 3,
      EmployeeCareerMoveStatus.declined => 4,
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
