import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/leave_request.dart';
import '../states/leave_provider.dart';
import '../widgets/leave_request_form.dart';
import '../widgets/leave_request_list.dart';
import '../widgets/leave_summary_panel.dart';

class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  ConsumerState<LeaveManagementScreen> createState() =>
      _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends ConsumerState<LeaveManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFormVisible = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests = ref.watch(leaveRequestsProvider);
    final selectedLeaveType = ref.watch(selectedLeaveTypeProvider);
    final summary = ref.watch(leaveSummaryProvider);

    return Scaffold(
      backgroundColor: HrisColors.pageBackground,
      appBar: AppBar(
        title: const Text('Leave Management'),
        actions: [
          IconButton(
            tooltip: 'Request leave',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => setState(() => _isFormVisible = true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LeaveSummaryPanel(
                summary: summary,
                onRequestLeave: () => setState(() => _isFormVisible = true),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child:
                    _isFormVisible
                        ? Padding(
                          key: const ValueKey('leave-form'),
                          padding: const EdgeInsets.only(top: 16),
                          child: LeaveRequestForm(
                            formKey: _formKey,
                            selectedLeaveType: selectedLeaveType,
                            startDate: _startDate,
                            endDate: _endDate,
                            reasonController: _reasonController,
                            onLeaveTypeChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(selectedLeaveTypeProvider.notifier)
                                    .state = value;
                              }
                            },
                            onStartDateChanged:
                                (date) => setState(() {
                                  _startDate = date;
                                  if (_endDate != null &&
                                      _endDate!.isBefore(date)) {
                                    _endDate = date;
                                  }
                                }),
                            onEndDateChanged:
                                (date) => setState(() => _endDate = date),
                            onCancel: _resetForm,
                            onSubmit: () => _submitRequest(selectedLeaveType),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              LeaveRequestList(requests: requests, onCancel: _cancelRequest),
            ],
          ),
        ),
      ),
    );
  }

  void _submitRequest(String selectedLeaveType) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = LeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: _startDate!,
      endDate: _endDate!,
      reason: _reasonController.text.trim(),
      status: LeaveStatus.pending,
      leaveType: selectedLeaveType,
    );

    ref.read(leaveRequestsProvider.notifier).addLeaveRequest(request);
    _resetForm();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leave request submitted successfully')),
    );
  }

  void _cancelRequest(LeaveRequest request) {
    ref.read(leaveRequestsProvider.notifier).deleteLeaveRequest(request.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Leave request cancelled')));
  }

  void _resetForm() {
    setState(() {
      _isFormVisible = false;
      _startDate = null;
      _endDate = null;
      _reasonController.clear();
    });
  }
}
