import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';

class IncomingTalentMobilityLaunchTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;
  final int minLines;

  const IncomingTalentMobilityLaunchTextInput({
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

class IncomingTalentMobilityLaunchStatusField extends StatelessWidget {
  final IncomingTalentMobilityLaunchChecklistDraft draft;
  final ValueChanged<IncomingTalentMobilityLaunchStatus> onChanged;

  const IncomingTalentMobilityLaunchStatusField({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IncomingTalentMobilityLaunchStatus>(
      initialValue: draft.status,
      decoration: const InputDecoration(
        labelText: 'Launch status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.flag_circle_outlined),
      ),
      items:
          IncomingTalentMobilityLaunchStatus.values
              .map(
                (status) =>
                    DropdownMenuItem(value: status, child: Text(status.label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      validator: IncomingTalentMobilityLaunchChecklistDraft.validateStatus,
    );
  }
}

class IncomingTalentMobilityLaunchDateFields extends StatelessWidget {
  final IncomingTalentMobilityLaunchChecklistDraft draft;
  final VoidCallback onSelectLaunchDate;
  final VoidCallback onSelectFirstReviewDate;

  const IncomingTalentMobilityLaunchDateFields({
    super.key,
    required this.draft,
    required this.onSelectLaunchDate,
    required this.onSelectFirstReviewDate,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsivePair(
      left: _LaunchDateField(
        label: 'Launch date',
        icon: Icons.event_available_outlined,
        value: draft.launchDate,
        error: IncomingTalentMobilityLaunchChecklistDraft.validateLaunchDate(
          draft.launchDate,
          draft.asOfDate,
        ),
        onTap: onSelectLaunchDate,
      ),
      right: _LaunchDateField(
        label: 'First review',
        icon: Icons.update_outlined,
        value: draft.firstReviewDate,
        error:
            IncomingTalentMobilityLaunchChecklistDraft.validateFirstReviewDate(
              draft.launchDate,
              draft.firstReviewDate,
            ),
        onTap: onSelectFirstReviewDate,
      ),
    );
  }
}

class IncomingTalentMobilityLaunchDraftReadiness extends StatelessWidget {
  final IncomingTalentMobilityLaunchChecklistDraft draft;

  const IncomingTalentMobilityLaunchDraftReadiness({
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

class _LaunchDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? error;
  final VoidCallback onTap;

  const _LaunchDateField({
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

class _ResponsivePair extends StatelessWidget {
  final Widget left;
  final Widget right;

  const _ResponsivePair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(children: [left, const SizedBox(height: 12), right]);
        }

        return Row(
          children: [
            Expanded(child: left),
            const SizedBox(width: 12),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
