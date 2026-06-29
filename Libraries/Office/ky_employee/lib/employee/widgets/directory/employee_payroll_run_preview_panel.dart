import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';

import '../../data/employee_directory_seed_data.dart';
import '../../data/employee_management_seed_data.dart';
import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_payroll_run_models.dart';
import '../../states/employee_directory_provider.dart';
import '../../states/employee_payroll_run_provider.dart';
import 'employee_payroll_run_launch_context_card.dart';
import 'employee_payroll_run_review_form.dart';
import 'employee_payroll_run_tiles.dart';

/// Employee payroll run preview, review, and export surface.
class EmployeePayrollRunPreviewPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePayrollRunPreviewPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePayrollRunPreviewPanel> createState() =>
      _EmployeePayrollRunPreviewPanelState();
}

/// Keeps payroll run review form controllers in sync with provider state.
class _EmployeePayrollRunPreviewPanelState
    extends ConsumerState<EmployeePayrollRunPreviewPanel> {
  final _reviewerController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _reviewerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeePayrollRunProvider(employeeId));
    final draft = ref.watch(employeePayrollRunReviewDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(
      _reviewerController,
      profile.reviewer.isEmpty ? draft.reviewer : profile.reviewer,
    );
    _sync(
      _noteController,
      profile.reviewNote.isEmpty ? draft.note : profile.reviewNote,
    );

    return HrisSectionPanel(
      icon: Icons.request_quote_outlined,
      title: 'Payroll run preview',
      subtitle: profile.nextAction,
      children: [
        EmployeePayrollRunSummaryStrip(profile: profile),
        if (profile.launchContext != null)
          EmployeePayrollRunLaunchContextCard(context: profile.launchContext!),
        EmployeePayrollRunStatusCard(profile: profile),
        if (profile.status != EmployeePayrollRunStatus.exported)
          EmployeePayrollRunReviewForm(
            profile: profile,
            draft: draft,
            reviewerController: _reviewerController,
            noteController: _noteController,
            onReviewerChanged:
                ref
                    .read(
                      employeePayrollRunReviewDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setReviewer,
            onNoteChanged:
                ref
                    .read(
                      employeePayrollRunReviewDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setNote,
            onPayslipVisibleChanged:
                ref
                    .read(
                      employeePayrollRunReviewDraftProvider(
                        employeeId,
                      ).notifier,
                    )
                    .setPayslipVisible,
            onReview: () => _markReviewed(draft),
            onExport: () => _exportRun(profile),
            onReopen: _reopenReview,
          ),
        ...profile.sortedLines.map(
          (line) => EmployeePayrollRunLineTile(line: line),
        ),
      ],
    );
  }

  void _markReviewed(EmployeePayrollRunReviewDraft draft) {
    try {
      ref
          .read(employeePayrollRunProvider(draft.employeeId).notifier)
          .markReviewed(draft);
      _showMessage('Payroll run marked ready');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _exportRun(EmployeePayrollRunProfile profile) {
    try {
      ref
          .read(employeePayrollRunProvider(profile.employeeId).notifier)
          .exportRun(_batchIdFor(profile));
      _showMessage('Payroll run exported');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _reopenReview() {
    ref
        .read(employeePayrollRunProvider(widget.snapshot.member.id).notifier)
        .reopenReview();
    _showMessage('Payroll run review reopened');
  }

  String _batchIdFor(EmployeePayrollRunProfile profile) {
    final launchContext = profile.launchContext;
    if (launchContext != null) return launchContext.runReference;

    final payDate = profile.payDate;
    return 'PAY-${payDate.year}${payDate.month.toString().padLeft(2, '0')}';
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

@Preview(name: 'Employee payroll run preview')
Widget employeePayrollRunPreviewPanelPreview() {
  final asOfDate = DateTime(2026, 5, 30);
  final member = buildEmployeeDirectoryMembers().singleWhere(
    (employee) => employee.id == '3',
  );
  final snapshot = buildEmployeeManagementSnapshot(
    member: member,
    asOfDate: asOfDate,
  );

  return ProviderScope(
    overrides: [employeeDirectoryAsOfDateProvider.overrideWithValue(asOfDate)],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: EmployeePayrollRunPreviewPanel(snapshot: snapshot),
        ),
      ),
    ),
  );
}
