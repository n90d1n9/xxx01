import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_portfolio_models.dart';

class IncomingTalentDevelopmentPortfolioTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentDevelopmentPortfolioTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.validator,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : 4,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class IncomingTalentDevelopmentPortfolioStatusFields extends StatelessWidget {
  final IncomingTalentDevelopmentPortfolioDraft draft;
  final ValueChanged<IncomingTalentDevelopmentPortfolioStage> onStageChanged;
  final ValueChanged<IncomingTalentDevelopmentPortfolioPriority>
  onPriorityChanged;
  final ValueChanged<IncomingTalentDevelopmentPortfolioCadence>
  onCadenceChanged;

  const IncomingTalentDevelopmentPortfolioStatusFields({
    super.key,
    required this.draft,
    required this.onStageChanged,
    required this.onPriorityChanged,
    required this.onCadenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final stageField =
        DropdownButtonFormField<IncomingTalentDevelopmentPortfolioStage>(
          initialValue: draft.stage,
          decoration: const InputDecoration(
            labelText: 'Portfolio stage',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          items:
              IncomingTalentDevelopmentPortfolioStage.values
                  .map(
                    (stage) => DropdownMenuItem(
                      value: stage,
                      child: Text(stage.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onStageChanged(value);
          },
          validator: validateIncomingTalentDevelopmentPortfolioStage,
        );
    final priorityField =
        DropdownButtonFormField<IncomingTalentDevelopmentPortfolioPriority>(
          initialValue: draft.priority,
          decoration: const InputDecoration(
            labelText: 'Priority',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.priority_high_outlined),
          ),
          items:
              IncomingTalentDevelopmentPortfolioPriority.values
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onPriorityChanged(value);
          },
          validator: validateIncomingTalentDevelopmentPortfolioPriority,
        );
    final cadenceField =
        DropdownButtonFormField<IncomingTalentDevelopmentPortfolioCadence>(
          initialValue: draft.reviewCadence,
          decoration: const InputDecoration(
            labelText: 'Review cadence',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.repeat_outlined),
          ),
          items:
              IncomingTalentDevelopmentPortfolioCadence.values
                  .map(
                    (cadence) => DropdownMenuItem(
                      value: cadence,
                      child: Text(cadence.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onCadenceChanged(value);
          },
          validator: validateIncomingTalentDevelopmentPortfolioCadence,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              stageField,
              const SizedBox(height: 12),
              priorityField,
              const SizedBox(height: 12),
              cadenceField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: stageField),
            const SizedBox(width: 12),
            Expanded(child: priorityField),
            const SizedBox(width: 12),
            Expanded(child: cadenceField),
          ],
        );
      },
    );
  }
}

class IncomingTalentDevelopmentPortfolioDateFields extends StatelessWidget {
  final IncomingTalentDevelopmentPortfolioDraft draft;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectNextReviewDate;
  final VoidCallback onSelectTargetDate;

  const IncomingTalentDevelopmentPortfolioDateFields({
    super.key,
    required this.draft,
    required this.onSelectStartDate,
    required this.onSelectNextReviewDate,
    required this.onSelectTargetDate,
  });

  @override
  Widget build(BuildContext context) {
    final fields = [
      _PortfolioDateField(
        label: 'Start date',
        icon: Icons.event_available_outlined,
        value: draft.startDate,
        error: validateIncomingTalentDevelopmentPortfolioStartDate(
          draft.startDate,
          draft.asOfDate,
        ),
        onTap: onSelectStartDate,
      ),
      _PortfolioDateField(
        label: 'Next review',
        icon: Icons.fact_check_outlined,
        value: draft.nextReviewDate,
        error: validateIncomingTalentDevelopmentPortfolioNextReviewDate(
          draft.startDate,
          draft.nextReviewDate,
        ),
        onTap: onSelectNextReviewDate,
      ),
      _PortfolioDateField(
        label: 'Target completion',
        icon: Icons.emoji_events_outlined,
        value: draft.targetCompletionDate,
        error: validateIncomingTalentDevelopmentPortfolioTargetDate(
          draft.startDate,
          draft.targetCompletionDate,
        ),
        onTap: onSelectTargetDate,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              fields[0],
              const SizedBox(height: 12),
              fields[1],
              const SizedBox(height: 12),
              fields[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: fields[0]),
            const SizedBox(width: 12),
            Expanded(child: fields[1]),
            const SizedBox(width: 12),
            Expanded(child: fields[2]),
          ],
        );
      },
    );
  }
}

class _PortfolioDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _PortfolioDateField({
    required this.label,
    required this.icon,
    required this.value,
    required this.error,
    required this.onTap,
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
          prefixIcon: Icon(icon),
          errorText: error,
        ),
        child: Text(
          value == null
              ? 'Select a date'
              : DateFormat('MMM d, yyyy').format(value!),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: value == null ? HrisColors.muted : HrisColors.ink,
          ),
        ),
      ),
    );
  }
}
