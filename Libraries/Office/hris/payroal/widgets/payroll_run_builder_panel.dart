import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';

class PayrollRunBuilderPanel extends StatefulWidget {
  final PayrollRunBuilderDraft draft;
  final PayrollRunBuilderPreview preview;
  final List<PayrollRunBuildRequest> requests;
  final ValueChanged<String> onLabelChanged;
  final VoidCallback onSelectPeriodStart;
  final VoidCallback onSelectPeriodEnd;
  final VoidCallback onSelectPayDate;
  final ValueChanged<PayrollRunScope> onScopeChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSubmit;
  final VoidCallback onReset;
  final ValueChanged<String> onApproveRequest;
  final ValueChanged<String> onActivateRequest;
  final ValueChanged<String> onReopenRequest;

  const PayrollRunBuilderPanel({
    super.key,
    required this.draft,
    required this.preview,
    required this.requests,
    required this.onLabelChanged,
    required this.onSelectPeriodStart,
    required this.onSelectPeriodEnd,
    required this.onSelectPayDate,
    required this.onScopeChanged,
    required this.onNotesChanged,
    required this.onSubmit,
    required this.onReset,
    required this.onApproveRequest,
    required this.onActivateRequest,
    required this.onReopenRequest,
  });

  @override
  State<PayrollRunBuilderPanel> createState() => _PayrollRunBuilderPanelState();
}

class _PayrollRunBuilderPanelState extends State<PayrollRunBuilderPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.draft.label);
    _notesController = TextEditingController(text: widget.draft.notes);
  }

  @override
  void didUpdateWidget(covariant PayrollRunBuilderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_labelController, widget.draft.label);
    _sync(_notesController, widget.draft.notes);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errors = widget.draft.validationErrors;

    return HrisSectionPanel(
      icon: Icons.playlist_add_check_outlined,
      title: 'Payroll run builder',
      subtitle: 'Prepare period, pay date, scope, and run notes',
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Run label',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                onChanged: widget.onLabelChanged,
                validator: PayrollRunBuilderDraft.validateLabel,
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final fields = [
                    _DateField(
                      label: 'Period start',
                      value: widget.draft.periodStart,
                      onTap: widget.onSelectPeriodStart,
                    ),
                    _DateField(
                      label: 'Period end',
                      value: widget.draft.periodEnd,
                      onTap: widget.onSelectPeriodEnd,
                      errorText: PayrollRunBuilderDraft.validatePeriodEnd(
                        widget.draft.periodStart,
                        widget.draft.periodEnd,
                      ),
                    ),
                    _DateField(
                      label: 'Pay date',
                      value: widget.draft.payDate,
                      onTap: widget.onSelectPayDate,
                      errorText: PayrollRunBuilderDraft.validatePayDate(
                        widget.draft.periodEnd,
                        widget.draft.payDate,
                      ),
                    ),
                  ];
                  if (constraints.maxWidth < 760) {
                    return Column(
                      children:
                          fields
                              .map(
                                (field) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: field,
                                ),
                              )
                              .toList(),
                    );
                  }
                  return Row(
                    children: [
                      for (var index = 0; index < fields.length; index++) ...[
                        Expanded(child: fields[index]),
                        if (index < fields.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<PayrollRunScope>(
                initialValue: widget.draft.scope,
                decoration: const InputDecoration(
                  labelText: 'Employee scope',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.groups_outlined),
                ),
                items:
                    PayrollRunScope.values
                        .map(
                          (scope) => DropdownMenuItem(
                            value: scope,
                            child: Text(scope.label),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) widget.onScopeChanged(value);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Preparation notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                onChanged: widget.onNotesChanged,
                validator: PayrollRunBuilderDraft.validateNotes,
              ),
              const SizedBox(height: 12),
              _RunBuilderReadiness(
                completionRatio: widget.draft.completionRatio,
                errors: errors,
              ),
              const SizedBox(height: 12),
              _RunBuilderPreviewCard(preview: widget.preview),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: widget.onReset,
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: widget.preview.canCreateRun ? _submit : null,
                    icon: const Icon(Icons.add_task_outlined),
                    label: const Text('Create run plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.requests.isNotEmpty)
          _RunBuildRequestList(
            requests: widget.requests,
            onApproveRequest: widget.onApproveRequest,
            onActivateRequest: widget.onActivateRequest,
            onReopenRequest: widget.onReopenRequest,
          ),
      ],
    );
  }

  void _submit() {
    final isValid = _formKey.currentState?.validate() == true;
    if (!isValid || !widget.draft.isReadyToSubmit) return;
    widget.onSubmit();
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;
  final String? errorText;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.event_outlined),
          errorText: errorText,
        ),
        child: Text(
          DateFormat('MMM d, yyyy').format(value),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: HrisColors.ink),
        ),
      ),
    );
  }
}

class _RunBuilderReadiness extends StatelessWidget {
  final double completionRatio;
  final List<String> errors;

  const _RunBuilderReadiness({
    required this.completionRatio,
    required this.errors,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = errors.isEmpty;
    final color = isReady ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: completionRatio,
            color: color,
            label:
                isReady
                    ? 'Run builder is ready to create a plan'
                    : errors.first,
          ),
          if (!isReady) ...[
            const SizedBox(height: 8),
            Text(
              errors.first,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFB45309),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RunBuilderPreviewCard extends StatelessWidget {
  final PayrollRunBuilderPreview preview;

  const _RunBuilderPreviewCard({required this.preview});

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisMetricStrip(
            items: [
              HrisMetricStripItem(
                label: 'Included',
                value: '${preview.includedEmployeeCount}',
              ),
              HrisMetricStripItem(
                label: 'Excluded',
                value: '${preview.excludedEmployeeCount}',
              ),
              HrisMetricStripItem(
                label: 'Gross',
                value: NumberFormat.compactCurrency(
                  symbol: r'$',
                ).format(preview.estimatedGross),
              ),
              HrisMetricStripItem(
                label: 'Net',
                value: NumberFormat.compactCurrency(
                  symbol: r'$',
                ).format(preview.estimatedNet),
              ),
              HrisMetricStripItem(
                label: 'Checks',
                value:
                    '${preview.readyChecklistCount}/${preview.readinessItems.length}',
              ),
            ],
          ),
          const SizedBox(height: 10),
          HrisProgressBar(
            value: preview.readinessRatio,
            color:
                preview.blockerCount == 0
                    ? const Color(0xFF15803D)
                    : const Color(0xFFB45309),
            label:
                preview.blockerCount == 0
                    ? 'Run setup checklist is ready'
                    : '${preview.blockerCount} setup checks need attention',
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              for (
                var index = 0;
                index < preview.readinessItems.length;
                index++
              ) ...[
                _RunReadinessRow(item: preview.readinessItems[index]),
                if (index < preview.readinessItems.length - 1)
                  const Divider(height: 18, color: HrisColors.border),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                preview.canCreateRun
                    ? Icons.verified_outlined
                    : Icons.info_outline,
                color:
                    preview.canCreateRun
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB45309),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  preview.nextAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (preview.includedEmployees.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final employee in preview.includedEmployees.take(4))
                  HrisStatusPill(
                    label: employee.name,
                    color: HrisColors.primary,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RunReadinessRow extends StatelessWidget {
  final PayrollRunReadinessItem item;

  const _RunReadinessRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color =
        item.isReady ? const Color(0xFF15803D) : const Color(0xFFB45309);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          item.isReady ? Icons.check_circle_outline : Icons.error_outline,
          color: color,
          size: 19,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              HrisProgressBar(
                value: item.completionRatio,
                color: color,
                label: item.statusLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RunBuildRequestList extends StatelessWidget {
  final List<PayrollRunBuildRequest> requests;
  final ValueChanged<String> onApproveRequest;
  final ValueChanged<String> onActivateRequest;
  final ValueChanged<String> onReopenRequest;

  const _RunBuildRequestList({
    required this.requests,
    required this.onApproveRequest,
    required this.onActivateRequest,
    required this.onReopenRequest,
  });

  @override
  Widget build(BuildContext context) {
    return HrisListSurface(
      child: Column(
        children: [
          for (var index = 0; index < requests.length; index++) ...[
            _RunBuildRequestTile(
              request: requests[index],
              onApproveRequest: onApproveRequest,
              onActivateRequest: onActivateRequest,
              onReopenRequest: onReopenRequest,
            ),
            if (index < requests.length - 1)
              const Divider(height: 20, color: HrisColors.border),
          ],
        ],
      ),
    );
  }
}

class _RunBuildRequestTile extends StatelessWidget {
  final PayrollRunBuildRequest request;
  final ValueChanged<String> onApproveRequest;
  final ValueChanged<String> onActivateRequest;
  final ValueChanged<String> onReopenRequest;

  const _RunBuildRequestTile({
    required this.request,
    required this.onApproveRequest,
    required this.onActivateRequest,
    required this.onReopenRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_statusIcon(request.status), color: _statusColor(request.status)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  HrisStatusPill(
                    label: request.status.label,
                    color: _statusColor(request.status),
                  ),
                  _MetaChip(
                    icon: Icons.confirmation_number_outlined,
                    label: request.id,
                  ),
                  _MetaChip(
                    icon: Icons.event_note_outlined,
                    label: request.periodId,
                  ),
                  _MetaChip(
                    icon: Icons.groups_outlined,
                    label: request.scope.label,
                  ),
                  _MetaChip(
                    icon: Icons.payments_outlined,
                    label: DateFormat('MMM d, yyyy').format(request.payDate),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final artifact in request.artifacts)
                    HrisStatusPill(
                      label: artifact.title,
                      color:
                          artifact.isReady
                              ? const Color(0xFF15803D)
                              : const Color(0xFFB45309),
                    ),
                ],
              ),
              if (request.status != PayrollRunBuildStatus.activated) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (request.status == PayrollRunBuildStatus.approved)
                        OutlinedButton.icon(
                          onPressed: () => onReopenRequest(request.id),
                          icon: const Icon(Icons.undo_outlined, size: 18),
                          label: const Text('Reopen'),
                        ),
                      if (request.status == PayrollRunBuildStatus.draft)
                        OutlinedButton.icon(
                          onPressed:
                              request.isReadyForApproval
                                  ? () => onApproveRequest(request.id)
                                  : null,
                          icon: const Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                          ),
                          label: const Text('Approve plan'),
                        ),
                      if (request.status == PayrollRunBuildStatus.approved)
                        FilledButton.tonalIcon(
                          onPressed: () => onActivateRequest(request.id),
                          icon: const Icon(Icons.play_arrow_outlined, size: 18),
                          label: const Text('Activate'),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollRunBuildStatus status) {
  return switch (status) {
    PayrollRunBuildStatus.draft => const Color(0xFF2563EB),
    PayrollRunBuildStatus.approved => const Color(0xFFB45309),
    PayrollRunBuildStatus.activated => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollRunBuildStatus status) {
  return switch (status) {
    PayrollRunBuildStatus.draft => Icons.task_alt_outlined,
    PayrollRunBuildStatus.approved => Icons.verified_user_outlined,
    PayrollRunBuildStatus.activated => Icons.play_circle_outline,
  };
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: HrisColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
