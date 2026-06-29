import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityCadenceTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentMobilityCadenceTextInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.validator,
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

class IncomingTalentMobilityCadenceSignalFields extends StatelessWidget {
  final IncomingTalentMobilityCadenceCheckInDraft draft;
  final ValueChanged<IncomingTalentMobilityCadenceStatus> onStatusChanged;
  final ValueChanged<IncomingTalentMobilityStabilizationResidualRisk>
  onResidualRiskChanged;
  final ValueChanged<int> onConfidenceChanged;

  const IncomingTalentMobilityCadenceSignalFields({
    super.key,
    required this.draft,
    required this.onStatusChanged,
    required this.onResidualRiskChanged,
    required this.onConfidenceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statusField =
        DropdownButtonFormField<IncomingTalentMobilityCadenceStatus>(
          initialValue: draft.status,
          decoration: const InputDecoration(
            labelText: 'Cadence status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.event_repeat_outlined),
          ),
          items:
              IncomingTalentMobilityCadenceStatus.values
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
          validator: IncomingTalentMobilityCadenceCheckInDraft.validateStatus,
        );
    final riskField = DropdownButtonFormField<
      IncomingTalentMobilityStabilizationResidualRisk
    >(
      initialValue: draft.residualRisk,
      decoration: const InputDecoration(
        labelText: 'Residual risk',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items:
          IncomingTalentMobilityStabilizationResidualRisk.values
              .map(
                (risk) =>
                    DropdownMenuItem(value: risk, child: Text(risk.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onResidualRiskChanged(value);
      },
      validator: IncomingTalentMobilityCadenceCheckInDraft.validateResidualRisk,
    );
    final confidenceField = DropdownButtonFormField<int>(
      initialValue:
          draft.hostConfidenceScore >= 1 && draft.hostConfidenceScore <= 5
              ? draft.hostConfidenceScore
              : null,
      decoration: const InputDecoration(
        labelText: 'Host confidence',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.speed_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (score) =>
                    DropdownMenuItem(value: score, child: Text('$score / 5')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onConfidenceChanged(value);
      },
      validator:
          (value) =>
              IncomingTalentMobilityCadenceCheckInDraft.validateHostConfidence(
                value ?? 0,
              ),
    );

    return _ResponsiveFields(
      children: [statusField, riskField, confidenceField],
    );
  }
}

class IncomingTalentMobilityCadenceDateFields extends StatelessWidget {
  final IncomingTalentMobilityCadenceCheckInDraft draft;
  final VoidCallback onSelectCheckInDate;
  final VoidCallback onSelectNextReviewDate;

  const IncomingTalentMobilityCadenceDateFields({
    super.key,
    required this.draft,
    required this.onSelectCheckInDate,
    required this.onSelectNextReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveFields(
      children: [
        _CadenceDateField(
          label: 'Check-in date',
          icon: Icons.event_available_outlined,
          value: draft.checkInDate,
          error: IncomingTalentMobilityCadenceCheckInDraft.validateCheckInDate(
            draft.checkInDate,
            draft.asOfDate,
          ),
          onTap: onSelectCheckInDate,
        ),
        _CadenceDateField(
          label: 'Next review',
          icon: Icons.update_outlined,
          value: draft.nextReviewDate,
          error:
              IncomingTalentMobilityCadenceCheckInDraft.validateNextReviewDate(
                draft.checkInDate,
                draft.nextReviewDate,
              ),
          onTap: onSelectNextReviewDate,
        ),
      ],
    );
  }
}

class _CadenceDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _CadenceDateField({
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

class _ResponsiveFields extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFields({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                children[index],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}
