import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_governance_execution_models.dart';
import 'incoming_talent_development_program_form_widgets.dart';
import 'talent_meta_label.dart';

/// Picker for governance execution actions ready for closure.
class IncomingTalentGovernanceExecutionClosureActionPicker
    extends StatelessWidget {
  final IncomingTalentGovernanceExecutionClosureDraft draft;
  final List<IncomingTalentGovernanceExecutionAction> actions;
  final ValueChanged<String?> onChanged;

  const IncomingTalentGovernanceExecutionClosureActionPicker({
    super.key,
    required this.draft,
    required this.actions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected =
        actions.any((action) => action.id == draft.actionId)
            ? draft.actionId
            : null;

    return DropdownButtonFormField<String>(
      key: ValueKey('governance-execution-closure-${draft.actionId}'),
      isExpanded: true,
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Execution action',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.playlist_add_check_outlined),
      ),
      items:
          actions
              .map(
                (action) => DropdownMenuItem(
                  value: action.id,
                  child: Text(
                    '${action.ownerName} - ${action.type.label}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: actions.isEmpty ? null : onChanged,
      validator:
          (value) => validateIncomingTalentGovernanceExecutionClosureRequired(
            value,
            'a governance execution action',
          ),
    );
  }
}

/// Date controls for governance execution closure reviews.
class IncomingTalentGovernanceExecutionClosureDateFields
    extends StatelessWidget {
  final IncomingTalentGovernanceExecutionClosureDraft draft;
  final VoidCallback onSelectClosureDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentGovernanceExecutionClosureDateFields({
    super.key,
    required this.draft,
    required this.onSelectClosureDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Closure',
          date: draft.closureDate,
          onTap: onSelectClosureDate,
          error: validateIncomingTalentGovernanceExecutionClosureDate(
            draft.closureDate,
            draft.asOfDate,
          ),
        ),
        IncomingTalentDevelopmentProgramDateButton(
          label: 'Next review',
          date: draft.nextReviewDate,
          onTap: onSelectNextReviewDate,
          error: validateIncomingTalentGovernanceExecutionClosureNextReviewDate(
            draft.closureDate,
            draft.nextReviewDate,
          ),
        ),
      ],
    );
  }
}

/// Outcome and residual-risk controls for governance execution closures.
class IncomingTalentGovernanceExecutionClosureSignalFields
    extends StatelessWidget {
  final IncomingTalentGovernanceExecutionClosureDraft draft;
  final ValueChanged<IncomingTalentGovernanceExecutionClosureOutcome>
  onOutcomeChanged;
  final ValueChanged<int> onResidualRiskChanged;

  const IncomingTalentGovernanceExecutionClosureSignalFields({
    super.key,
    required this.draft,
    required this.onOutcomeChanged,
    required this.onResidualRiskChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IncomingTalentDevelopmentProgramResponsiveRow(
      children: [
        DropdownButtonFormField<
          IncomingTalentGovernanceExecutionClosureOutcome
        >(
          initialValue: draft.outcome,
          decoration: const InputDecoration(
            labelText: 'Outcome',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.rule_outlined),
          ),
          items:
              IncomingTalentGovernanceExecutionClosureOutcome.values
                  .map(
                    (outcome) => DropdownMenuItem(
                      value: outcome,
                      child: Text(outcome.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onOutcomeChanged(value);
          },
          validator: validateIncomingTalentGovernanceExecutionClosureOutcome,
        ),
        DropdownButtonFormField<int>(
          initialValue:
              draft.residualRiskCount >= 0 && draft.residualRiskCount <= 5
                  ? draft.residualRiskCount
                  : null,
          decoration: const InputDecoration(
            labelText: 'Residual risk',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.report_problem_outlined),
          ),
          items:
              [0, 1, 2, 3, 4, 5]
                  .map(
                    (count) => DropdownMenuItem(
                      value: count,
                      child: Text(count == 0 ? 'None' : '$count risks'),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onResidualRiskChanged(value);
          },
          validator:
              (value) =>
                  validateIncomingTalentGovernanceExecutionClosureResidualRisk(
                    value ?? 0,
                  ),
        ),
      ],
    );
  }
}

/// Readiness panel for governance execution closure draft completeness.
class IncomingTalentGovernanceExecutionClosureReadiness
    extends StatelessWidget {
  final IncomingTalentGovernanceExecutionClosureDraft draft;

  const IncomingTalentGovernanceExecutionClosureReadiness({
    super.key,
    required this.draft,
  });

  @override
  Widget build(BuildContext context) {
    final errors = draft.validationErrors;
    final ready = errors.isEmpty;

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HrisProgressBar(
            value: draft.completionRatio,
            color: ready ? const Color(0xFF15803D) : HrisColors.primary,
            label: ready ? 'Closure ready' : 'Closure draft',
          ),
          if (draft.actionId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                TalentMetaLabel(
                  icon: Icons.flag_outlined,
                  label: draft.actionType?.label ?? 'Action',
                ),
                TalentMetaLabel(
                  icon: Icons.priority_high_outlined,
                  label: draft.actionPriority?.label ?? 'Priority',
                ),
                TalentMetaLabel(
                  icon: Icons.warning_amber_outlined,
                  label: '${draft.signalCount} active signals',
                ),
                TalentMetaLabel(
                  icon: Icons.gavel_outlined,
                  label: '${draft.decisionCount} governance decisions',
                ),
              ],
            ),
          ],
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final error in errors.take(3))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Submit controls for governance execution closure reviews.
class IncomingTalentGovernanceExecutionClosureFormActions
    extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  const IncomingTalentGovernanceExecutionClosureFormActions({
    super.key,
    required this.canSubmit,
    required this.onClear,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onClear, child: const Text('Clear')),
        const SizedBox(width: 10),
        FilledButton.icon(
          key: const Key('incoming-talent-governance-execution-closure-submit'),
          onPressed: canSubmit ? onSubmit : null,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Submit closure'),
        ),
      ],
    );
  }
}

@Preview(name: 'Talent governance execution closure picker')
Widget incomingTalentGovernanceExecutionClosurePickerPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionClosureActionPicker(
          draft: _previewDraft,
          actions: [_previewAction],
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent governance execution closure signals')
Widget incomingTalentGovernanceExecutionClosureSignalsPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionClosureSignalFields(
          draft: _previewDraft,
          onOutcomeChanged: (_) {},
          onResidualRiskChanged: (_) {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Talent governance execution closure readiness')
Widget incomingTalentGovernanceExecutionClosureReadinessPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentGovernanceExecutionClosureReadiness(
          draft: _previewDraft,
        ),
      ),
    ),
  );
}

final _previewAction = IncomingTalentGovernanceExecutionAction(
  id: 'talent-governance-execution-action-preview',
  trackId: 'talent-governance-execution-preview',
  type: IncomingTalentGovernanceExecutionActionType.recoverOverdue,
  priority: IncomingTalentGovernanceExecutionActionPriority.critical,
  title: 'People Risk and Assurance - recover overdue',
  detail: 'Execute assurance approval decision',
  nextAction:
      'Ask People Risk and Assurance to recover overdue follow-through for execute assurance approval decision.',
  playbook:
      'Reconfirm due date, capture recovery evidence, and mark owner acceptance.',
  evidenceExpectation:
      'Attach assurance approval evidence, owner confirmation, and recovery note.',
  ownerName: 'People Risk and Assurance',
  dueDate: DateTime(2026, 6, 11),
  progressRatio: 0.1,
  signalCount: 5,
  decisionCount: 3,
  readinessTaskCount: 1,
  overdue: true,
);

final _previewDraft = IncomingTalentGovernanceExecutionClosureDraft.fromAction(
  action: _previewAction,
  asOfDate: DateTime(2026, 6, 12),
);
