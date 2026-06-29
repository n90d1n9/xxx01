import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_work_authorization_models.dart';
import '../../states/employee_work_authorization_provider.dart';
import 'employee_work_authorization_form.dart';
import 'employee_work_authorization_tiles.dart';

class EmployeeWorkAuthorizationCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeWorkAuthorizationCenterPanel({
    super.key,
    required this.snapshot,
  });

  @override
  ConsumerState<EmployeeWorkAuthorizationCenterPanel> createState() =>
      _EmployeeWorkAuthorizationCenterPanelState();
}

class _EmployeeWorkAuthorizationCenterPanelState
    extends ConsumerState<EmployeeWorkAuthorizationCenterPanel> {
  final _titleController = TextEditingController();
  final _countryController = TextEditingController();
  final _ownerController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _countryController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(
      employeeWorkAuthorizationProfileProvider(employeeId),
    );
    final draft = ref.watch(employeeWorkAuthorizationDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_countryController, draft.country);
    _sync(_ownerController, draft.owner);
    _sync(_notesController, draft.notes);

    final records = [...profile.records]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        profile.asOfDate,
      ).compareTo(_attentionRank(b, profile.asOfDate));
      if (attentionCompare != 0) return attentionCompare;
      final statusCompare = _statusRank(
        a.status,
      ).compareTo(_statusRank(b.status));
      if (statusCompare != 0) return statusCompare;
      return a.expiryDate.compareTo(b.expiryDate);
    });

    return HrisSectionPanel(
      icon: Icons.assignment_ind_outlined,
      title: 'Work authorization',
      subtitle: profile.nextAction,
      children: [
        EmployeeWorkAuthorizationSummaryStrip(profile: profile),
        EmployeeWorkAuthorizationForm(
          draft: draft,
          titleController: _titleController,
          countryController: _countryController,
          ownerController: _ownerController,
          notesController: _notesController,
          onTypeChanged:
              ref
                  .read(
                    employeeWorkAuthorizationDraftProvider(employeeId).notifier,
                  )
                  .setType,
          onSponsorshipChanged:
              ref
                  .read(
                    employeeWorkAuthorizationDraftProvider(employeeId).notifier,
                  )
                  .setSponsorship,
          onTitleChanged:
              ref
                  .read(
                    employeeWorkAuthorizationDraftProvider(employeeId).notifier,
                  )
                  .setTitle,
          onCountryChanged:
              ref
                  .read(
                    employeeWorkAuthorizationDraftProvider(employeeId).notifier,
                  )
                  .setCountry,
          onOwnerChanged:
              ref
                  .read(
                    employeeWorkAuthorizationDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onNotesChanged:
              ref
                  .read(
                    employeeWorkAuthorizationDraftProvider(employeeId).notifier,
                  )
                  .setNotes,
          onSelectExpiryDate: () => _selectExpiryDate(draft),
          onSelectReviewDate: () => _selectReviewDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (records.isEmpty)
          const HrisListSurface(
            child: Text('No work authorization records yet.'),
          )
        else
          ...records.map(
            (record) => EmployeeWorkAuthorizationRecordTile(
              record: record,
              asOfDate: profile.asOfDate,
              onVerifyEvidence: () => _verifyEvidence(record),
              onStartRenewal: () => _startRenewal(record),
              onMarkValid: () => _markValid(record),
              onSuspend: () => _suspend(record),
            ),
          ),
      ],
    );
  }

  Future<void> _selectExpiryDate(EmployeeWorkAuthorizationDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.expiryDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    ref
        .read(employeeWorkAuthorizationDraftProvider(draft.employeeId).notifier)
        .setExpiryDate(picked);
  }

  Future<void> _selectReviewDate(EmployeeWorkAuthorizationDraft draft) async {
    final lastDate =
        draft.expiryDate.isBefore(draft.asOfDate)
            ? draft.asOfDate
            : draft.expiryDate;
    final initialDate =
        draft.reviewDate.isAfter(lastDate) ? lastDate : draft.reviewDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: draft.asOfDate,
      lastDate: lastDate,
    );
    if (picked == null) return;
    ref
        .read(employeeWorkAuthorizationDraftProvider(draft.employeeId).notifier)
        .setReviewDate(picked);
  }

  void _submitDraft(EmployeeWorkAuthorizationDraft draft) {
    try {
      final record = ref
          .read(
            employeeWorkAuthorizationProfileProvider(draft.employeeId).notifier,
          )
          .submitDraft(draft);
      ref
          .read(
            employeeWorkAuthorizationDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${record.title} submitted for ${record.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _verifyEvidence(EmployeeWorkAuthorizationRecord record) {
    ref
        .read(
          employeeWorkAuthorizationProfileProvider(record.employeeId).notifier,
        )
        .verifyEvidence(record.id);
    _showMessage('${record.title} evidence verified');
  }

  void _startRenewal(EmployeeWorkAuthorizationRecord record) {
    ref
        .read(
          employeeWorkAuthorizationProfileProvider(record.employeeId).notifier,
        )
        .startRenewal(record.id);
    _showMessage('${record.title} renewal started');
  }

  void _markValid(EmployeeWorkAuthorizationRecord record) {
    ref
        .read(
          employeeWorkAuthorizationProfileProvider(record.employeeId).notifier,
        )
        .markValid(record.id);
    _showMessage('${record.title} marked valid');
  }

  void _suspend(EmployeeWorkAuthorizationRecord record) {
    ref
        .read(
          employeeWorkAuthorizationProfileProvider(record.employeeId).notifier,
        )
        .suspend(record.id);
    _showMessage('${record.title} suspended');
  }

  int _attentionRank(
    EmployeeWorkAuthorizationRecord record,
    DateTime asOfDate,
  ) {
    return record.needsAttention(asOfDate) ? 0 : 1;
  }

  int _statusRank(EmployeeWorkAuthorizationStatus status) {
    return switch (status) {
      EmployeeWorkAuthorizationStatus.expired => 0,
      EmployeeWorkAuthorizationStatus.missing => 1,
      EmployeeWorkAuthorizationStatus.renewalDue => 2,
      EmployeeWorkAuthorizationStatus.pendingReview => 3,
      EmployeeWorkAuthorizationStatus.suspended => 4,
      EmployeeWorkAuthorizationStatus.valid => 5,
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
