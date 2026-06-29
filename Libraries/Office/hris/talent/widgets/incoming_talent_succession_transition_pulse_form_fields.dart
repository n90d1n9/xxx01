import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentSuccessionTransitionPulseTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?) validator;
  final int minLines;

  const IncomingTalentSuccessionTransitionPulseTextInput({
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

class IncomingTalentSuccessionTransitionPulseSignalFields
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionPulseDraft draft;
  final ValueChanged<IncomingTalentSuccessionTransitionPulseHealth>
  onHealthChanged;
  final ValueChanged<int> onAdoptionChanged;
  final ValueChanged<int> onManagerConfidenceChanged;
  final ValueChanged<IncomingTalentSuccessionTransitionRetentionRisk>
  onRetentionRiskChanged;

  const IncomingTalentSuccessionTransitionPulseSignalFields({
    super.key,
    required this.draft,
    required this.onHealthChanged,
    required this.onAdoptionChanged,
    required this.onManagerConfidenceChanged,
    required this.onRetentionRiskChanged,
  });

  @override
  Widget build(BuildContext context) {
    final healthField = DropdownButtonFormField<
      IncomingTalentSuccessionTransitionPulseHealth
    >(
      initialValue: draft.health,
      decoration: const InputDecoration(
        labelText: 'Pulse health',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.monitor_heart_outlined),
      ),
      items:
          IncomingTalentSuccessionTransitionPulseHealth.values
              .map(
                (health) =>
                    DropdownMenuItem(value: health, child: Text(health.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onHealthChanged(value);
      },
      validator: IncomingTalentSuccessionTransitionPulseDraft.validateHealth,
    );
    final adoptionField = _ScoreField(
      label: 'Adoption',
      value: draft.adoptionScore,
      onChanged: onAdoptionChanged,
    );
    final confidenceField = _ScoreField(
      label: 'Manager confidence',
      value: draft.managerConfidenceScore,
      onChanged: onManagerConfidenceChanged,
    );
    final riskField = DropdownButtonFormField<
      IncomingTalentSuccessionTransitionRetentionRisk
    >(
      initialValue: draft.retentionRisk,
      decoration: const InputDecoration(
        labelText: 'Retention risk',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shield_outlined),
      ),
      items:
          IncomingTalentSuccessionTransitionRetentionRisk.values
              .map(
                (risk) =>
                    DropdownMenuItem(value: risk, child: Text(risk.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onRetentionRiskChanged(value);
      },
      validator:
          IncomingTalentSuccessionTransitionPulseDraft.validateRetentionRisk,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              healthField,
              const SizedBox(height: 12),
              adoptionField,
              const SizedBox(height: 12),
              confidenceField,
              const SizedBox(height: 12),
              riskField,
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: healthField),
                const SizedBox(width: 12),
                Expanded(child: riskField),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: adoptionField),
                const SizedBox(width: 12),
                Expanded(child: confidenceField),
              ],
            ),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionTransitionPulseScheduleFields
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionPulseDraft draft;
  final ValueChanged<IncomingTalentSuccessionTransitionPulseWindow>
  onWindowChanged;
  final VoidCallback onSelectPulseDate;
  final VoidCallback onSelectNextPulseDate;

  const IncomingTalentSuccessionTransitionPulseScheduleFields({
    super.key,
    required this.draft,
    required this.onWindowChanged,
    required this.onSelectPulseDate,
    required this.onSelectNextPulseDate,
  });

  @override
  Widget build(BuildContext context) {
    final windowField =
        DropdownButtonFormField<IncomingTalentSuccessionTransitionPulseWindow>(
          initialValue: draft.pulseWindow,
          decoration: const InputDecoration(
            labelText: 'Pulse window',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timeline_outlined),
          ),
          items:
              IncomingTalentSuccessionTransitionPulseWindow.values
                  .map(
                    (window) => DropdownMenuItem(
                      value: window,
                      child: Text(window.label),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            if (value != null) onWindowChanged(value);
          },
          validator:
              IncomingTalentSuccessionTransitionPulseDraft.validatePulseWindow,
        );
    final pulseDateField = _PulseDateField(
      label: 'Pulse date',
      icon: Icons.event_available_outlined,
      value: draft.pulseDate,
      error: IncomingTalentSuccessionTransitionPulseDraft.validatePulseDate(
        draft.pulseDate,
        draft.asOfDate,
      ),
      onTap: onSelectPulseDate,
    );
    final nextPulseField = _PulseDateField(
      label: 'Next pulse',
      icon: Icons.update_outlined,
      value: draft.nextPulseDate,
      error: IncomingTalentSuccessionTransitionPulseDraft.validateNextPulseDate(
        draft.pulseDate,
        draft.nextPulseDate,
      ),
      onTap: onSelectNextPulseDate,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              windowField,
              const SizedBox(height: 12),
              pulseDateField,
              const SizedBox(height: 12),
              nextPulseField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: windowField),
            const SizedBox(width: 12),
            Expanded(child: pulseDateField),
            const SizedBox(width: 12),
            Expanded(child: nextPulseField),
          ],
        );
      },
    );
  }
}

class IncomingTalentSuccessionTransitionPulseDraftReadiness
    extends StatelessWidget {
  final IncomingTalentSuccessionTransitionPulseDraft draft;

  const IncomingTalentSuccessionTransitionPulseDraftReadiness({
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

class _ScoreField extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _ScoreField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value >= 1 && value <= 5 ? value : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.speed_outlined),
      ),
      items:
          [1, 2, 3, 4, 5]
              .map(
                (score) =>
                    DropdownMenuItem(value: score, child: Text('$score / 5')),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator:
          (value) => IncomingTalentSuccessionTransitionPulseDraft.validateScore(
            value ?? 0,
            label,
          ),
    );
  }
}

class _PulseDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _PulseDateField({
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
