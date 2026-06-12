import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/company_governance_follow_up_cadence.dart';
import '../models/company_governance_follow_up_policy.dart';
import '../models/company_governance_follow_up_policy_impact.dart';
import '../models/company_governance_owner_load.dart';

/// Provides editable SLA timing for governance owner follow-up lanes.
class CompanyGovernanceFollowUpPolicyPanel extends StatefulWidget {
  final CompanyGovernanceFollowUpPolicy policy;
  final CompanyGovernanceFollowUpPolicyDraft draft;
  final CompanyGovernanceFollowUpPolicyImpact? impact;
  final ValueChanged<String> onCriticalChanged;
  final ValueChanged<String> onHighChanged;
  final ValueChanged<String> onSteadyChanged;
  final VoidCallback onReset;
  final VoidCallback onSave;

  const CompanyGovernanceFollowUpPolicyPanel({
    super.key,
    required this.policy,
    required this.draft,
    this.impact,
    required this.onCriticalChanged,
    required this.onHighChanged,
    required this.onSteadyChanged,
    required this.onReset,
    required this.onSave,
  });

  @override
  State<CompanyGovernanceFollowUpPolicyPanel> createState() =>
      _CompanyGovernanceFollowUpPolicyPanelState();
}

/// Synchronizes text controllers with the current SLA draft.
class _CompanyGovernanceFollowUpPolicyPanelState
    extends State<CompanyGovernanceFollowUpPolicyPanel> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _criticalController;
  late final TextEditingController _highController;
  late final TextEditingController _steadyController;

  @override
  void initState() {
    super.initState();
    _criticalController = TextEditingController(
      text: widget.draft.criticalCadenceDaysText,
    );
    _highController = TextEditingController(
      text: widget.draft.highCadenceDaysText,
    );
    _steadyController = TextEditingController(
      text: widget.draft.steadyCadenceDaysText,
    );
  }

  @override
  void didUpdateWidget(
    covariant CompanyGovernanceFollowUpPolicyPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    _sync(_criticalController, widget.draft.criticalCadenceDaysText);
    _sync(_highController, widget.draft.highCadenceDaysText);
    _sync(_steadyController, widget.draft.steadyCadenceDaysText);
  }

  @override
  void dispose() {
    _criticalController.dispose();
    _highController.dispose();
    _steadyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HrisSectionPanel(
      icon: Icons.timer_outlined,
      title: 'Governance Follow-up SLA',
      subtitle: widget.policy.compactLabel,
      children: [
        _PolicySummaryStrip(policy: widget.policy),
        if (widget.impact != null) _PolicyImpactPreview(impact: widget.impact!),
        HrisListSurface(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PolicyInputGrid(
                  criticalController: _criticalController,
                  highController: _highController,
                  steadyController: _steadyController,
                  onCriticalChanged: widget.onCriticalChanged,
                  onHighChanged: widget.onHighChanged,
                  onSteadyChanged: widget.onSteadyChanged,
                ),
                const SizedBox(height: 12),
                _PolicyActions(
                  onReset: widget.onReset,
                  onSave: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      widget.onSave();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows the projected lane impact of an unsaved SLA draft.
class _PolicyImpactPreview extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyImpact impact;

  const _PolicyImpactPreview({required this.impact});

  @override
  Widget build(BuildContext context) {
    final color = _impactColor(impact.severity);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_impactIcon(impact.severity), color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      impact.headline,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      impact.detail,
                      maxLines: 2,
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
          if (impact.isValid) ...[
            const SizedBox(height: 12),
            HrisMetricStrip(
              items: [
                HrisMetricStripItem(
                  label: 'Due now',
                  value: '${impact.dueNowCount}',
                ),
                HrisMetricStripItem(
                  label: 'Overdue',
                  value: '${impact.overdueCount}',
                ),
                HrisMetricStripItem(
                  label: 'Changed',
                  value: '${impact.changedLaneCount}',
                ),
                HrisMetricStripItem(
                  label: 'No handoff',
                  value: '${impact.needsHandoffCount}',
                ),
              ],
            ),
          ],
          if (impact.changedLanes.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final lane in impact.changedLanes)
              _PolicyImpactLaneTile(lane: lane),
          ],
        ],
      ),
    );
  }
}

/// Compact row describing one owner lane shift in the draft preview.
class _PolicyImpactLaneTile extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicyImpactLane lane;

  const _PolicyImpactLaneTile({required this.lane});

  @override
  Widget build(BuildContext context) {
    final color = lane.becomesDueNow ? Colors.orange : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              lane.ownerName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: HrisColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${lane.currentTouchLabel} -> ${lane.previewTouchLabel}',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
            ),
          ),
          const SizedBox(width: 8),
          HrisStatusPill(label: lane.previewState.label, color: color),
        ],
      ),
    );
  }
}

/// Shows the currently saved governance follow-up cadence by risk lane.
class _PolicySummaryStrip extends StatelessWidget {
  final CompanyGovernanceFollowUpPolicy policy;

  const _PolicySummaryStrip({required this.policy});

  @override
  Widget build(BuildContext context) {
    return HrisMetricStrip(
      items: [
        HrisMetricStripItem(
          label: 'Critical',
          value: policy.cadenceLabelFor(
            CompanyGovernanceOwnerLoadRisk.critical,
          ),
        ),
        HrisMetricStripItem(
          label: 'High',
          value: policy.cadenceLabelFor(CompanyGovernanceOwnerLoadRisk.high),
        ),
        HrisMetricStripItem(
          label: 'Steady',
          value: policy.cadenceLabelFor(CompanyGovernanceOwnerLoadRisk.steady),
        ),
      ],
    );
  }
}

/// Lays out follow-up SLA inputs without resizing the surrounding panel.
class _PolicyInputGrid extends StatelessWidget {
  final TextEditingController criticalController;
  final TextEditingController highController;
  final TextEditingController steadyController;
  final ValueChanged<String> onCriticalChanged;
  final ValueChanged<String> onHighChanged;
  final ValueChanged<String> onSteadyChanged;

  const _PolicyInputGrid({
    required this.criticalController,
    required this.highController,
    required this.steadyController,
    required this.onCriticalChanged,
    required this.onHighChanged,
    required this.onSteadyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fieldWidth =
            constraints.maxWidth < 620
                ? constraints.maxWidth
                : (constraints.maxWidth - 24) / 3;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: fieldWidth,
              child: _PolicyDaysInput(
                fieldKey: const Key('company-governance-sla-critical-field'),
                controller: criticalController,
                label: 'Critical',
                icon: Icons.priority_high_outlined,
                onChanged: onCriticalChanged,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: _PolicyDaysInput(
                fieldKey: const Key('company-governance-sla-high-field'),
                controller: highController,
                label: 'High',
                icon: Icons.warning_amber_outlined,
                onChanged: onHighChanged,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: _PolicyDaysInput(
                fieldKey: const Key('company-governance-sla-steady-field'),
                controller: steadyController,
                label: 'Steady',
                icon: Icons.task_alt_outlined,
                onChanged: onSteadyChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Text input for one follow-up SLA day value.
class _PolicyDaysInput extends StatelessWidget {
  final Key fieldKey;
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _PolicyDaysInput({
    required this.fieldKey,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        suffixText: 'days',
      ),
      onChanged: onChanged,
      validator:
          (value) => CompanyGovernanceFollowUpPolicyDraft.validateCadenceDays(
            value,
            label,
          ),
    );
  }
}

/// Contains reset and save actions for the SLA policy form.
class _PolicyActions extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onSave;

  const _PolicyActions({required this.onReset, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          OutlinedButton.icon(
            key: const Key('company-governance-sla-reset-button'),
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt_outlined),
            label: const Text('Reset'),
          ),
          FilledButton.icon(
            key: const Key('company-governance-sla-save-button'),
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save SLA'),
          ),
        ],
      ),
    );
  }
}

void _sync(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.value = TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
  );
}

Color _impactColor(CompanyGovernanceFollowUpPolicyImpactSeverity severity) {
  switch (severity) {
    case CompanyGovernanceFollowUpPolicyImpactSeverity.invalid:
      return Colors.red;
    case CompanyGovernanceFollowUpPolicyImpactSeverity.unchanged:
      return Colors.blueGrey;
    case CompanyGovernanceFollowUpPolicyImpactSeverity.balanced:
      return Colors.green;
    case CompanyGovernanceFollowUpPolicyImpactSeverity.elevated:
      return Colors.orange;
  }
}

IconData _impactIcon(CompanyGovernanceFollowUpPolicyImpactSeverity severity) {
  switch (severity) {
    case CompanyGovernanceFollowUpPolicyImpactSeverity.invalid:
      return Icons.error_outline;
    case CompanyGovernanceFollowUpPolicyImpactSeverity.unchanged:
      return Icons.sync_alt_outlined;
    case CompanyGovernanceFollowUpPolicyImpactSeverity.balanced:
      return Icons.trending_flat_outlined;
    case CompanyGovernanceFollowUpPolicyImpactSeverity.elevated:
      return Icons.trending_up_outlined;
  }
}

@Preview(name: 'Company governance follow-up SLA panel')
Widget companyGovernanceFollowUpPolicyPanelPreview() {
  const policy = CompanyGovernanceFollowUpPolicy(
    criticalCadenceDays: 1,
    highCadenceDays: 2,
    steadyCadenceDays: 4,
  );

  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CompanyGovernanceFollowUpPolicyPanel(
          policy: policy,
          draft: CompanyGovernanceFollowUpPolicyDraft.fromPolicy(policy),
          impact: const CompanyGovernanceFollowUpPolicyImpact(
            isValid: true,
            laneCount: 3,
            needsHandoffCount: 1,
            overdueCount: 0,
            dueTodayCount: 1,
            scheduledCount: 1,
            changedLaneCount: 1,
            newlyDueCount: 1,
            changedLanes: [
              CompanyGovernanceFollowUpPolicyImpactLane(
                ownerName: 'People Operations',
                currentTouchLabel: 'Due tomorrow',
                previewTouchLabel: 'Due today',
                previewState: CompanyGovernanceFollowUpState.dueToday,
                becomesDueNow: true,
              ),
            ],
          ),
          onCriticalChanged: _previewPolicyChanged,
          onHighChanged: _previewPolicyChanged,
          onSteadyChanged: _previewPolicyChanged,
          onReset: _previewPolicyReset,
          onSave: _previewPolicySave,
        ),
      ),
    ),
  );
}

void _previewPolicyChanged(String value) {}

void _previewPolicyReset() {}

void _previewPolicySave() {}
