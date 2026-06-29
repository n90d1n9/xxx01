import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_audit_trail_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_audit_trail_provider.dart';
import 'employee_audit_trail_form.dart';
import 'employee_audit_trail_tiles.dart';

class EmployeeAuditTrailCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeAuditTrailCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeAuditTrailCenterPanel> createState() =>
      _EmployeeAuditTrailCenterPanelState();
}

class _EmployeeAuditTrailCenterPanelState
    extends ConsumerState<EmployeeAuditTrailCenterPanel> {
  final _titleController = TextEditingController();
  final _actorController = TextEditingController();
  final _detailController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _actorController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeeAuditTrailProfileProvider(employeeId));
    final draft = ref.watch(employeeAuditTrailDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_actorController, draft.actor);
    _sync(_detailController, draft.detail);

    final entries = [...profile.entries]..sort((a, b) {
      final attentionCompare = _attentionRank(
        a,
        profile.asOfDate,
      ).compareTo(_attentionRank(b, profile.asOfDate));
      if (attentionCompare != 0) return attentionCompare;
      final statusCompare = _statusRank(
        a.reviewStatus,
      ).compareTo(_statusRank(b.reviewStatus));
      if (statusCompare != 0) return statusCompare;
      final severityCompare = _severityRank(
        a.severity,
      ).compareTo(_severityRank(b.severity));
      if (severityCompare != 0) return severityCompare;
      return b.occurredAt.compareTo(a.occurredAt);
    });

    return HrisSectionPanel(
      icon: Icons.manage_history_outlined,
      title: 'Employee audit trail',
      subtitle: profile.nextAction,
      children: [
        EmployeeAuditTrailSummaryStrip(profile: profile),
        EmployeeAuditTrailForm(
          draft: draft,
          titleController: _titleController,
          actorController: _actorController,
          detailController: _detailController,
          onSourceChanged:
              ref
                  .read(employeeAuditTrailDraftProvider(employeeId).notifier)
                  .setSource,
          onActionTypeChanged:
              ref
                  .read(employeeAuditTrailDraftProvider(employeeId).notifier)
                  .setActionType,
          onSeverityChanged:
              ref
                  .read(employeeAuditTrailDraftProvider(employeeId).notifier)
                  .setSeverity,
          onTitleChanged:
              ref
                  .read(employeeAuditTrailDraftProvider(employeeId).notifier)
                  .setTitle,
          onActorChanged:
              ref
                  .read(employeeAuditTrailDraftProvider(employeeId).notifier)
                  .setActor,
          onDetailChanged:
              ref
                  .read(employeeAuditTrailDraftProvider(employeeId).notifier)
                  .setDetail,
          onSensitiveChanged:
              ref
                  .read(employeeAuditTrailDraftProvider(employeeId).notifier)
                  .setContainsSensitiveData,
          onSubmit: () => _addEntry(draft),
        ),
        ...entries.map(
          (entry) => EmployeeAuditTrailEntryTile(
            entry: entry,
            asOfDate: profile.asOfDate,
            onReview: () => _markReviewed(entry),
            onEscalate: () => _escalate(entry),
            onArchive: () => _archive(entry),
          ),
        ),
      ],
    );
  }

  void _addEntry(EmployeeAuditTrailDraft draft) {
    try {
      final entry = ref
          .read(employeeAuditTrailProfileProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(employeeAuditTrailDraftProvider(draft.employeeId).notifier)
          .reset();
      _showMessage('${entry.id} added to ${entry.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _markReviewed(EmployeeAuditTrailEntry entry) {
    ref
        .read(employeeAuditTrailProfileProvider(entry.employeeId).notifier)
        .markReviewed(entry.id);
    _showMessage('${entry.title} marked reviewed');
  }

  void _escalate(EmployeeAuditTrailEntry entry) {
    ref
        .read(employeeAuditTrailProfileProvider(entry.employeeId).notifier)
        .escalate(entry.id);
    _showMessage('${entry.title} escalated');
  }

  void _archive(EmployeeAuditTrailEntry entry) {
    ref
        .read(employeeAuditTrailProfileProvider(entry.employeeId).notifier)
        .archive(entry.id);
    _showMessage('${entry.title} archived');
  }

  int _attentionRank(EmployeeAuditTrailEntry entry, DateTime asOfDate) {
    return entry.needsAttention(asOfDate) ? 0 : 1;
  }

  int _statusRank(EmployeeAuditTrailReviewStatus status) {
    return switch (status) {
      EmployeeAuditTrailReviewStatus.escalated => 0,
      EmployeeAuditTrailReviewStatus.reviewRequired => 1,
      EmployeeAuditTrailReviewStatus.logged => 2,
      EmployeeAuditTrailReviewStatus.reviewed => 3,
      EmployeeAuditTrailReviewStatus.archived => 4,
    };
  }

  int _severityRank(EmployeeAuditTrailSeverity severity) {
    return switch (severity) {
      EmployeeAuditTrailSeverity.critical => 0,
      EmployeeAuditTrailSeverity.warning => 1,
      EmployeeAuditTrailSeverity.notice => 2,
      EmployeeAuditTrailSeverity.info => 3,
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
