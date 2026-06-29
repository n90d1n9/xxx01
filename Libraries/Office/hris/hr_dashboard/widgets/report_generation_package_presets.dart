import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/report_generation_request.dart';
import '../models/report_package_preset.dart';

class ReportGenerationPackagePresets extends StatelessWidget {
  final ReportGenerationRequest request;
  final ValueChanged<ReportGenerationRequest> onChanged;

  const ReportGenerationPackagePresets({
    super.key,
    required this.request,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPreset = ReportPackagePreset.fromRequest(request);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Package preset',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: HrisColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              ReportPackagePreset.values.map((preset) {
                return _PackagePresetChip(
                  preset: preset,
                  selected: preset == selectedPreset,
                  onSelected: () => onChanged(preset.applyTo(request)),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class _PackagePresetChip extends StatelessWidget {
  final ReportPackagePreset preset;
  final bool selected;
  final VoidCallback onSelected;

  const _PackagePresetChip({
    required this.preset,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      key: Key('report-package-preset-${preset.name}'),
      avatar: Icon(
        _iconFor(preset),
        size: 17,
        color: selected ? HrisColors.primary : HrisColors.muted,
      ),
      label: Text(preset.label),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: selected ? HrisColors.primary : HrisColors.ink,
        fontWeight: FontWeight.w800,
      ),
      backgroundColor: HrisColors.surface,
      selectedColor: HrisColors.primary.withValues(alpha: 0.1),
      side: BorderSide(
        color: selected ? HrisColors.primary : HrisColors.border,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

IconData _iconFor(ReportPackagePreset preset) {
  return switch (preset) {
    ReportPackagePreset.brief => Icons.summarize_outlined,
    ReportPackagePreset.analysis => Icons.insights_outlined,
    ReportPackagePreset.audit => Icons.verified_outlined,
    ReportPackagePreset.data => Icons.table_chart_outlined,
  };
}
