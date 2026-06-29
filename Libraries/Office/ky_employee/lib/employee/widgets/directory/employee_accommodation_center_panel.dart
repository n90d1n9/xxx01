import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_accommodation_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_accommodation_provider.dart';
import 'employee_accommodation_form.dart';
import 'employee_accommodation_tiles.dart';

class EmployeeAccommodationCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeAccommodationCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeAccommodationCenterPanel> createState() =>
      _EmployeeAccommodationCenterPanelState();
}

class _EmployeeAccommodationCenterPanelState
    extends ConsumerState<EmployeeAccommodationCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _summaryController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeAccommodationProfileProvider(employeeId));
    final draft = ref.watch(employeeAccommodationDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_summaryController, draft.summary);

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
      return b.requestedAt.compareTo(a.requestedAt);
    });

    return HrisSectionPanel(
      icon: Icons.accessibility_new_outlined,
      title: 'Accommodation support',
      subtitle: profile.nextAction,
      children: [
        EmployeeAccommodationSummaryStrip(profile: profile),
        EmployeeAccommodationForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          summaryController: _summaryController,
          onTypeChanged:
              ref
                  .read(employeeAccommodationDraftProvider(employeeId).notifier)
                  .setType,
          onTitleChanged:
              ref
                  .read(employeeAccommodationDraftProvider(employeeId).notifier)
                  .setTitle,
          onOwnerChanged:
              ref
                  .read(employeeAccommodationDraftProvider(employeeId).notifier)
                  .setOwner,
          onSummaryChanged:
              ref
                  .read(employeeAccommodationDraftProvider(employeeId).notifier)
                  .setSummary,
          onSensitivityChanged:
              ref
                  .read(employeeAccommodationDraftProvider(employeeId).notifier)
                  .setSensitivity,
          onSelectStartDate: () => _selectStartDate(draft),
          onSelectReviewDate: () => _selectReviewDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (records.isEmpty)
          const HrisListSurface(child: Text('No accommodation records yet.'))
        else
          ...records.map(
            (record) => EmployeeAccommodationRecordTile(
              record: record,
              asOfDate: profile.asOfDate,
              onApprove: () {
                ref
                    .read(
                      employeeAccommodationProfileProvider(employeeId).notifier,
                    )
                    .approveRequest(record.id);
              },
              onActivate: () {
                ref
                    .read(
                      employeeAccommodationProfileProvider(employeeId).notifier,
                    )
                    .activateAccommodation(record.id);
              },
              onReview: () => _completeReview(record),
              onExpire: () {
                ref
                    .read(
                      employeeAccommodationProfileProvider(employeeId).notifier,
                    )
                    .expireAccommodation(record.id);
              },
              onDecline: () {
                ref
                    .read(
                      employeeAccommodationProfileProvider(employeeId).notifier,
                    )
                    .declineRequest(record.id);
              },
            ),
          ),
      ],
    );
  }

  Future<void> _selectStartDate(EmployeeAccommodationDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.startDate,
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    ref
        .read(employeeAccommodationDraftProvider(draft.employeeId).notifier)
        .setStartDate(picked);
  }

  Future<void> _selectReviewDate(EmployeeAccommodationDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.reviewDate,
      firstDate: draft.startDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(employeeAccommodationDraftProvider(draft.employeeId).notifier)
        .setReviewDate(picked);
  }

  void _submitDraft(EmployeeAccommodationDraft draft) {
    try {
      final record = ref
          .read(employeeAccommodationProfileProvider(draft.employeeId).notifier)
          .submitDraft(draft);
      ref
          .read(employeeAccommodationDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${record.title} submitted for ${record.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _completeReview(EmployeeAccommodationRecord record) {
    ref
        .read(employeeAccommodationProfileProvider(record.employeeId).notifier)
        .completeReview(record.id);
    _showMessage('${record.title} review completed');
  }

  int _attentionRank(EmployeeAccommodationRecord record, DateTime asOfDate) {
    return record.needsAttention(asOfDate) ? 0 : 1;
  }

  int _statusRank(EmployeeAccommodationStatus status) {
    return switch (status) {
      EmployeeAccommodationStatus.requested => 0,
      EmployeeAccommodationStatus.approved => 1,
      EmployeeAccommodationStatus.reviewDue => 2,
      EmployeeAccommodationStatus.active => 3,
      EmployeeAccommodationStatus.expired => 4,
      EmployeeAccommodationStatus.declined => 5,
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
