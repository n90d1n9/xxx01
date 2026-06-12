import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/hris_ui.dart';
import '../../models/employee_management_models.dart';
import '../../models/employee_payslip_delivery_models.dart';
import '../../states/employee_payslip_delivery_provider.dart';
import 'employee_payslip_delivery_tiles.dart';
import 'employee_payslip_release_form.dart';

class EmployeePayslipDeliveryPanel extends ConsumerStatefulWidget {
  final EmployeeManagementSnapshot snapshot;

  const EmployeePayslipDeliveryPanel({super.key, required this.snapshot});

  @override
  ConsumerState<EmployeePayslipDeliveryPanel> createState() =>
      _EmployeePayslipDeliveryPanelState();
}

class _EmployeePayslipDeliveryPanelState
    extends ConsumerState<EmployeePayslipDeliveryPanel> {
  final _ownerController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _ownerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = widget.snapshot.member.id;
    final profile = ref.watch(employeePayslipDeliveryProvider(employeeId));
    final draft = ref.watch(employeePayslipReleaseDraftProvider(employeeId));

    if (profile == null || draft == null) {
      return const SizedBox.shrink();
    }

    _sync(
      _ownerController,
      profile.releaseOwner.isEmpty ? draft.owner : profile.releaseOwner,
    );
    _sync(
      _noteController,
      profile.releaseNote.isEmpty ? draft.note : profile.releaseNote,
    );

    return HrisSectionPanel(
      icon: Icons.receipt_long_outlined,
      title: 'Payslip delivery',
      subtitle: profile.nextAction,
      children: [
        EmployeePayslipDeliverySummaryStrip(profile: profile),
        EmployeePayslipDeliveryStatusCard(profile: profile),
        EmployeePayslipPreviewCard(profile: profile),
        EmployeePayslipReleaseForm(
          profile: profile,
          draft: draft,
          ownerController: _ownerController,
          noteController: _noteController,
          onOwnerChanged:
              ref
                  .read(
                    employeePayslipReleaseDraftProvider(employeeId).notifier,
                  )
                  .setOwner,
          onNoteChanged:
              ref
                  .read(
                    employeePayslipReleaseDraftProvider(employeeId).notifier,
                  )
                  .setNote,
          onNotifyEmployeeChanged:
              ref
                  .read(
                    employeePayslipReleaseDraftProvider(employeeId).notifier,
                  )
                  .setNotifyEmployee,
          onArchiveCopyChanged:
              ref
                  .read(
                    employeePayslipReleaseDraftProvider(employeeId).notifier,
                  )
                  .setArchiveCopy,
          onRelease: () => _release(draft),
          onSuppress: _suppress,
          onReopen: _reopen,
        ),
        ...profile.sortedChannels.map(
          (channel) => EmployeePayslipDeliveryChannelTile(channel: channel),
        ),
      ],
    );
  }

  void _release(EmployeePayslipReleaseDraft draft) {
    try {
      ref
          .read(employeePayslipDeliveryProvider(draft.employeeId).notifier)
          .release(draft);
      _showMessage('Payslip released');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _suppress() {
    try {
      ref
          .read(
            employeePayslipDeliveryProvider(widget.snapshot.member.id).notifier,
          )
          .suppress();
      _showMessage('Payslip delivery suppressed');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _reopen() {
    ref
        .read(
          employeePayslipDeliveryProvider(widget.snapshot.member.id).notifier,
        )
        .reopen();
    _showMessage('Payslip delivery reopened');
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
