import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_compliance_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_compliance_provider.dart';
import 'employee_compliance_document_form.dart';
import 'employee_compliance_tiles.dart';

class EmployeeComplianceCenterPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeComplianceCenterPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeComplianceCenterPanel> createState() =>
      _EmployeeComplianceCenterPanelState();
}

class _EmployeeComplianceCenterPanelState
    extends ConsumerState<EmployeeComplianceCenterPanel> {
  final _titleController = TextEditingController();
  final _ownerController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _ownerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final records = ref.watch(employeeComplianceRecordsProvider(employeeId));
    final summary = ref.watch(employeeComplianceSummaryProvider(employeeId));
    final draft = ref.watch(
      employeeComplianceDocumentDraftProvider(employeeId),
    );

    if (draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_titleController, draft.title);
    _sync(_ownerController, draft.owner);
    _sync(_notesController, draft.notes);

    final sortedRecords = [...records]..sort((a, b) {
      final aAttention = a.needsAttention(widget.snapshot.asOfDate);
      final bAttention = b.needsAttention(widget.snapshot.asOfDate);
      if (aAttention != bAttention) return aAttention ? -1 : 1;
      return a.dueDate.compareTo(b.dueDate);
    });

    return HrisSectionPanel(
      icon: Icons.folder_copy_outlined,
      title: 'Compliance center',
      subtitle: summary.nextAction,
      children: [
        EmployeeComplianceSummaryStrip(summary: summary),
        EmployeeComplianceDocumentForm(
          draft: draft,
          titleController: _titleController,
          ownerController: _ownerController,
          notesController: _notesController,
          onTitleChanged:
              ref
                  .read(
                    employeeComplianceDocumentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setTitle,
          onTypeChanged:
              ref
                  .read(
                    employeeComplianceDocumentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setType,
          onOwnerChanged:
              ref
                  .read(
                    employeeComplianceDocumentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setOwner,
          onNotesChanged:
              ref
                  .read(
                    employeeComplianceDocumentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setNotes,
          onSelectDueDate: () => _selectDueDate(draft),
          onSelectExpiryDate: () => _selectExpiryDate(draft),
          onClearExpiryDate:
              ref
                  .read(
                    employeeComplianceDocumentDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .clearExpiresAt,
          onAdd: () => _addDocument(draft),
        ),
        if (sortedRecords.isEmpty)
          const HrisListSurface(child: Text('No compliance documents yet.'))
        else
          ...sortedRecords.map(
            (record) => EmployeeComplianceDocumentTile(
              record: record,
              asOfDate: widget.snapshot.asOfDate,
              onVerify:
                  () => ref
                      .read(
                        employeeComplianceRecordsProvider(employeeId).notifier,
                      )
                      .verify(record.id),
              onReject:
                  () => ref
                      .read(
                        employeeComplianceRecordsProvider(employeeId).notifier,
                      )
                      .reject(record.id),
              onWaive:
                  () => ref
                      .read(
                        employeeComplianceRecordsProvider(employeeId).notifier,
                      )
                      .waive(record.id),
              onRenew: () => _renewDocument(record),
            ),
          ),
      ],
    );
  }

  Future<void> _selectDueDate(EmployeeComplianceDocumentDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.dueDate ?? draft.asOfDate.add(const Duration(days: 7)),
      firstDate: draft.asOfDate.subtract(const Duration(days: 365)),
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeComplianceDocumentDraftProvider(draft.employeeId).notifier,
        )
        .setDueDate(picked);
  }

  Future<void> _selectExpiryDate(EmployeeComplianceDocumentDraft draft) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.expiresAt ?? draft.asOfDate.add(const Duration(days: 365)),
      firstDate: draft.dueDate ?? draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeComplianceDocumentDraftProvider(draft.employeeId).notifier,
        )
        .setExpiresAt(picked);
  }

  void _addDocument(EmployeeComplianceDocumentDraft draft) {
    try {
      final record = ref
          .read(employeeComplianceRecordsProvider(draft.employeeId).notifier)
          .addDraft(draft);
      ref
          .read(
            employeeComplianceDocumentDraftProvider(draft.employeeId).notifier,
          )
          .reset();
      _showMessage('${record.title} added to ${draft.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _renewDocument(EmployeeComplianceDocumentRecord record) {
    final nextExpiry = widget.snapshot.asOfDate.add(const Duration(days: 365));
    ref
        .read(employeeComplianceRecordsProvider(record.employeeId).notifier)
        .renew(record.id, nextExpiry);
    _showMessage('${record.title} renewed');
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
