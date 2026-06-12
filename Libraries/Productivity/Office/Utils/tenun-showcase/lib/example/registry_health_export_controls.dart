import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenun/tenun_core.dart' hide Align;

import 'registry_health_export_options.dart';
import 'registry_health_export_presets.dart';
import 'registry_health_export_summary.dart';
import 'registry_health_widgets.dart';

class RegistryHealthExportPresetControls extends StatelessWidget {
  const RegistryHealthExportPresetControls({
    super.key,
    required this.report,
    this.extraSections = const <String, dynamic>{},
    this.presets = RegistryHealthExportOptions.presets,
    this.primaryOptions,
  });

  final ChartRegistryHealthReport report;
  final Map<String, dynamic> extraSections;
  final List<RegistryHealthExportOptions> presets;
  final RegistryHealthExportOptions? primaryOptions;

  @override
  Widget build(BuildContext context) {
    final orderedPresets = registryHealthOrderedExportPresets(
      presets,
      primaryOptions: primaryOptions,
    );
    if (orderedPresets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final preset in orderedPresets)
            Tooltip(
              message: registryHealthExportPresetTooltip(
                registryHealthExportPresetSummary(
                  report,
                  extraSections: extraSections,
                  options: preset,
                ),
              ),
              child: OutlinedButton.icon(
                onPressed: () => _copyReport(context, preset),
                icon: Icon(registryHealthExportPresetIcon(preset), size: 16),
                label: Text(registryHealthExportPresetCopyLabel(preset)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _copyReport(
    BuildContext context,
    RegistryHealthExportOptions options,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text: registryHealthExportText(
          report,
          extraSections: extraSections,
          options: options,
        ),
      ),
    );
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(registryHealthExportPresetCopiedLabel(options))),
    );
  }
}

List<RegistryHealthExportOptions> registryHealthOrderedExportPresets(
  Iterable<RegistryHealthExportOptions> presets, {
  RegistryHealthExportOptions? primaryOptions,
}) {
  final out = <RegistryHealthExportOptions>[];
  final names = <String>{};

  void addPreset(RegistryHealthExportOptions options) {
    final name = options.name.trim().toLowerCase();
    if (name.isEmpty || !names.add(name)) {
      return;
    }
    out.add(options);
  }

  final primary = primaryOptions;
  if (primary != null) {
    addPreset(primary);
  }
  for (final preset in presets) {
    addPreset(preset);
  }

  return out;
}

IconData registryHealthExportPresetIcon(RegistryHealthExportOptions options) {
  switch (options.name.trim()) {
    case 'compact':
      return Icons.filter_alt_outlined;
    case 'release':
      return Icons.assignment_turned_in_outlined;
    case 'planning':
      return Icons.map_outlined;
    default:
      return Icons.copy;
  }
}

String registryHealthExportPresetCopyLabel(
  RegistryHealthExportOptions options,
) {
  return registryHealthExportPresetCopyLabelForOptions(options);
}

String registryHealthExportPresetCopiedLabel(
  RegistryHealthExportOptions options,
) {
  return registryHealthExportPresetCopiedLabelForOptions(options);
}

String registryHealthExportPresetLabel(RegistryHealthExportOptions options) {
  return registryHealthExportPresetLabelForOptions(options);
}
