import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/payroll_management_models.dart';
import 'payroll_formatters.dart';

class PayrollScenarioLibraryPanel extends StatefulWidget {
  final PayrollScenarioLibrarySummary summary;
  final PayrollSimulationSummary simulation;
  final ValueChanged<String> onLabelChanged;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onSaveScenario;
  final ValueChanged<String> onApproveScenario;
  final ValueChanged<String> onConvertScenario;
  final ValueChanged<String> onRemoveScenario;

  const PayrollScenarioLibraryPanel({
    super.key,
    required this.summary,
    required this.simulation,
    required this.onLabelChanged,
    required this.onNotesChanged,
    required this.onSaveScenario,
    required this.onApproveScenario,
    required this.onConvertScenario,
    required this.onRemoveScenario,
  });

  @override
  State<PayrollScenarioLibraryPanel> createState() =>
      _PayrollScenarioLibraryPanelState();
}

class _PayrollScenarioLibraryPanelState
    extends State<PayrollScenarioLibraryPanel> {
  late final TextEditingController _labelController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.summary.draftLabel);
    _notesController = TextEditingController(text: widget.summary.draftNotes);
  }

  @override
  void didUpdateWidget(covariant PayrollScenarioLibraryPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_labelController, widget.summary.draftLabel);
    _sync(_notesController, widget.summary.draftNotes);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = widget.simulation.blockerCount == 0;

    return HrisSectionPanel(
      icon: Icons.collections_bookmark_outlined,
      title: 'Scenario library',
      subtitle: 'Save, compare, approve, and convert payroll simulations',
      children: [
        HrisListSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final labelField = TextField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Scenario label',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.drive_file_rename_outline),
                    ),
                    onChanged: widget.onLabelChanged,
                  );
                  final notesField = TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Review notes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    onChanged: widget.onNotesChanged,
                  );

                  if (constraints.maxWidth < 760) {
                    return Column(
                      children: [
                        labelField,
                        const SizedBox(height: 12),
                        notesField,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: labelField),
                      const SizedBox(width: 12),
                      Expanded(child: notesField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              HrisMetricStrip(
                items: [
                  HrisMetricStripItem(
                    label: 'Saved',
                    value: '${widget.summary.savedCount}',
                  ),
                  HrisMetricStripItem(
                    label: 'Approved',
                    value: '${widget.summary.approvedCount}',
                  ),
                  HrisMetricStripItem(
                    label: 'Best net',
                    value: payrollCurrencyFormat.format(
                      widget.summary.bestNetDelta,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    canSave
                        ? Icons.flag_circle_outlined
                        : Icons.warning_amber_outlined,
                    color:
                        canSave ? HrisColors.primary : const Color(0xFFB91C1C),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      canSave
                          ? widget.summary.nextAction
                          : widget.simulation.nextAction,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: canSave ? widget.onSaveScenario : null,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.summary.scenarios.isEmpty)
          const HrisEmptyState(message: 'No saved payroll scenarios yet')
        else
          for (final scenario in widget.summary.scenarios)
            _ScenarioTile(
              scenario: scenario,
              onApproveScenario: widget.onApproveScenario,
              onConvertScenario: widget.onConvertScenario,
              onRemoveScenario: widget.onRemoveScenario,
            ),
      ],
    );
  }

  void _sync(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.text = value;
  }
}

class _ScenarioTile extends StatelessWidget {
  final PayrollScenarioRecord scenario;
  final ValueChanged<String> onApproveScenario;
  final ValueChanged<String> onConvertScenario;
  final ValueChanged<String> onRemoveScenario;

  const _ScenarioTile({
    required this.scenario,
    required this.onApproveScenario,
    required this.onConvertScenario,
    required this.onRemoveScenario,
  });

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(scenario.status);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_statusIcon(scenario.status), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          scenario.label,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: HrisColors.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        HrisStatusPill(
                          label: scenario.status.label,
                          color: color,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.notes.isEmpty
                          ? '${scenario.proposedInputs.length} proposed inputs'
                          : scenario.notes,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.trending_up_outlined,
                label: payrollCurrencyFormat.format(scenario.grossDelta),
              ),
              _MetaChip(
                icon: Icons.payments_outlined,
                label: payrollCurrencyFormat.format(scenario.netDelta),
              ),
              _MetaChip(
                icon: Icons.input_outlined,
                label: '${scenario.proposedInputs.length} inputs',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => onRemoveScenario(scenario.id),
                icon: const Icon(Icons.close_outlined),
                label: const Text('Remove'),
              ),
              const SizedBox(width: 8),
              if (scenario.canApprove)
                FilledButton.tonalIcon(
                  onPressed: () => onApproveScenario(scenario.id),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approve'),
                )
              else
                FilledButton.icon(
                  onPressed:
                      scenario.canConvert
                          ? () => onConvertScenario(scenario.id)
                          : null,
                  icon: const Icon(Icons.playlist_add_check_outlined),
                  label: const Text('Convert'),
                ),
            ],
          ),
        ],
      ),
    );
  }
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
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

Color _statusColor(PayrollScenarioStatus status) {
  return switch (status) {
    PayrollScenarioStatus.saved => const Color(0xFF2563EB),
    PayrollScenarioStatus.approved => const Color(0xFF7C3AED),
    PayrollScenarioStatus.converted => const Color(0xFF15803D),
  };
}

IconData _statusIcon(PayrollScenarioStatus status) {
  return switch (status) {
    PayrollScenarioStatus.saved => Icons.bookmark_outline,
    PayrollScenarioStatus.approved => Icons.verified_user_outlined,
    PayrollScenarioStatus.converted => Icons.task_alt_outlined,
  };
}
