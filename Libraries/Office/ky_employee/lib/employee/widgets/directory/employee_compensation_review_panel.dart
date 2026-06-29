import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_compensation_models.dart';
import '../../models/employee_management_models.dart';
import '../../states/employee_compensation_provider.dart';
import 'employee_compensation_package_card.dart';
import 'employee_compensation_review_form.dart';
import 'employee_compensation_tiles.dart';

class EmployeeCompensationReviewPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeeCompensationReviewPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeeCompensationReviewPanel> createState() =>
      _EmployeeCompensationReviewPanelState();
}

class _EmployeeCompensationReviewPanelState
    extends ConsumerState<EmployeeCompensationReviewPanel> {
  final _salaryController = TextEditingController();
  final _justificationController = TextEditingController();

  @override
  void dispose() {
    _salaryController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final package = ref.watch(employeeCompensationPackageProvider(employeeId));
    final draft = ref.watch(
      employeeCompensationReviewDraftProvider(employeeId),
    );
    final requests = ref.watch(
      employeeCompensationReviewsForEmployeeProvider(employeeId),
    );
    final summary = ref.watch(
      employeeCompensationReviewSummaryProvider(employeeId),
    );

    if (package == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(_salaryController, draft.proposedBaseSalary.round().toString());
    _sync(_justificationController, draft.justification);

    return HrisSectionPanel(
      icon: Icons.payments_outlined,
      title: 'Compensation review',
      subtitle: summary.nextAction,
      children: [
        EmployeeCompensationSummaryStrip(package: package, summary: summary),
        EmployeeCompensationPackageCard(
          package: package,
          asOfDate: widget.snapshot.asOfDate,
        ),
        EmployeeCompensationDraftForm(
          draft: draft,
          salaryController: _salaryController,
          justificationController: _justificationController,
          onTypeChanged:
              ref
                  .read(
                    employeeCompensationReviewDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setReviewType,
          onSalaryChanged:
              (value) => ref
                  .read(
                    employeeCompensationReviewDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setProposedBaseSalary(_parseSalary(value)),
          onJustificationChanged:
              ref
                  .read(
                    employeeCompensationReviewDraftProvider(
                      employeeId,
                    ).notifier,
                  )
                  .setJustification,
          onSelectDate: () => _selectEffectiveDate(draft),
          onSubmit: () => _submitDraft(draft),
        ),
        if (requests.isEmpty)
          const HrisListSurface(
            child: Text('No compensation reviews submitted yet.'),
          )
        else
          ...requests.map(
            (request) => EmployeeCompensationReviewRequestTile(
              request: request,
              onApprove:
                  () => ref
                      .read(employeeCompensationReviewRequestsProvider.notifier)
                      .approve(request.id),
              onApply: () => _applyRequest(request),
            ),
          ),
      ],
    );
  }

  Future<void> _selectEffectiveDate(
    EmployeeCompensationReviewDraft draft,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          draft.effectiveDate ?? draft.asOfDate.add(const Duration(days: 30)),
      firstDate: draft.asOfDate,
      lastDate: draft.asOfDate.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref
        .read(
          employeeCompensationReviewDraftProvider(
            draft.package.employeeId,
          ).notifier,
        )
        .setEffectiveDate(picked);
  }

  void _submitDraft(EmployeeCompensationReviewDraft draft) {
    try {
      final request = ref
          .read(employeeCompensationReviewRequestsProvider.notifier)
          .submitDraft(draft);
      ref
          .read(
            employeeCompensationReviewDraftProvider(
              draft.package.employeeId,
            ).notifier,
          )
          .reset();
      _showMessage('${request.id} submitted for ${request.employeeName}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _applyRequest(EmployeeCompensationReviewRequest request) {
    final package = ref.read(
      employeeCompensationPackageProvider(request.employeeId),
    );
    if (package == null) {
      _showMessage('Compensation package is unavailable');
      return;
    }

    ref
        .read(employeeCompensationPackagesProvider.notifier)
        .updatePackage(request.applyTo(package));
    ref
        .read(employeeCompensationReviewRequestsProvider.notifier)
        .markApplied(request.id);
    _showMessage('${request.id} applied to ${request.employeeName}');
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

  double _parseSalary(String value) {
    return double.tryParse(value.replaceAll(RegExp('[^0-9.]'), '')) ?? 0;
  }
}
