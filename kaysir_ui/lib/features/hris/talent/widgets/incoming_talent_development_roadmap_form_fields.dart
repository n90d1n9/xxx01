import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_development_roadmap_models.dart';

class IncomingTalentDevelopmentRoadmapTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentDevelopmentRoadmapTextInput({
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

class IncomingTalentDevelopmentRoadmapDateFields extends StatelessWidget {
  final IncomingTalentDevelopmentRoadmapDraft draft;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectTargetDate;

  const IncomingTalentDevelopmentRoadmapDateFields({
    super.key,
    required this.draft,
    required this.onSelectStartDate,
    required this.onSelectTargetDate,
  });

  @override
  Widget build(BuildContext context) {
    final startField = _RoadmapDateField(
      label: 'Start date',
      icon: Icons.event_available_outlined,
      value: draft.startDate,
      error: IncomingTalentDevelopmentRoadmapDraft.validateStartDate(
        draft.startDate,
        draft.asOfDate,
      ),
      onTap: onSelectStartDate,
    );
    final targetField = _RoadmapDateField(
      label: 'Target completion',
      icon: Icons.flag_outlined,
      value: draft.targetCompletionDate,
      error: IncomingTalentDevelopmentRoadmapDraft.validateTargetCompletionDate(
        draft.startDate,
        draft.targetCompletionDate,
      ),
      onTap: onSelectTargetDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [startField, const SizedBox(height: 12), targetField],
          );
        }

        return Row(
          children: [
            Expanded(child: startField),
            const SizedBox(width: 12),
            Expanded(child: targetField),
          ],
        );
      },
    );
  }
}

class IncomingTalentDevelopmentRoadmapStatusFields extends StatelessWidget {
  final IncomingTalentDevelopmentRoadmapDraft draft;
  final ValueChanged<IncomingTalentDevelopmentRoadmapCadence> onCadenceChanged;
  final ValueChanged<IncomingTalentDevelopmentRoadmapStatus> onStatusChanged;

  const IncomingTalentDevelopmentRoadmapStatusFields({
    super.key,
    required this.draft,
    required this.onCadenceChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cadenceField =
        DropdownButtonFormField<IncomingTalentDevelopmentRoadmapCadence>(
          initialValue: draft.cadence,
          decoration: const InputDecoration(
            labelText: 'Review cadence',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.repeat_outlined),
          ),
          items:
              IncomingTalentDevelopmentRoadmapCadence.values
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
          validator: IncomingTalentDevelopmentRoadmapDraft.validateCadence,
        );
    final statusField =
        DropdownButtonFormField<IncomingTalentDevelopmentRoadmapStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Roadmap status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.route_outlined),
          ),
          items:
              IncomingTalentDevelopmentRoadmapStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onStatusChanged(value);
          },
          validator: IncomingTalentDevelopmentRoadmapDraft.validateStatus,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [cadenceField, const SizedBox(height: 12), statusField],
          );
        }

        return Row(
          children: [
            Expanded(child: cadenceField),
            const SizedBox(width: 12),
            Expanded(child: statusField),
          ],
        );
      },
    );
  }
}

class IncomingTalentDevelopmentRoadmapDraftReadiness extends StatelessWidget {
  final IncomingTalentDevelopmentRoadmapDraft draft;

  const IncomingTalentDevelopmentRoadmapDraftReadiness({
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
            label: '${(draft.completionRatio * 100).round()}% complete',
          ),
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

class _RoadmapDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _RoadmapDateField({
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
