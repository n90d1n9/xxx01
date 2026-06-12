import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tenun/tenun_core.dart' hide Align;

import 'registry_health_export_options.dart';
import 'registry_health_export_presets.dart';
import 'registry_health_export_summary.dart';

class RegistryHealthCopyButton extends StatelessWidget {
  const RegistryHealthCopyButton({
    super.key,
    required this.report,
    this.extraSections = const <String, dynamic>{},
    this.exportOptions = RegistryHealthExportOptions.full,
  });

  final ChartRegistryHealthReport report;
  final Map<String, dynamic> extraSections;
  final RegistryHealthExportOptions exportOptions;

  @override
  Widget build(BuildContext context) {
    final summary = registryHealthExportPresetSummary(
      report,
      extraSections: extraSections,
      options: exportOptions,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message: registryHealthExportPresetTooltip(summary),
        child: OutlinedButton.icon(
          onPressed: () => _copyReport(context),
          icon: const Icon(Icons.copy, size: 16),
          label: Text(
            registryHealthExportPresetCopyLabelForOptions(exportOptions),
          ),
        ),
      ),
    );
  }

  Future<void> _copyReport(BuildContext context) async {
    await Clipboard.setData(
      ClipboardData(
        text: registryHealthExportText(
          report,
          extraSections: extraSections,
          options: exportOptions,
        ),
      ),
    );
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          registryHealthExportPresetCopiedLabelForOptions(exportOptions),
        ),
      ),
    );
  }
}

Map<String, dynamic> registryHealthExportJson(
  ChartRegistryHealthReport report, {
  Map<String, dynamic> extraSections = const <String, dynamic>{},
  RegistryHealthExportOptions options = RegistryHealthExportOptions.full,
}) {
  final out = Map<String, dynamic>.from(report.toJson());
  for (final entry in registryHealthFilterExtraSections(
    extraSections,
    options: options,
  ).entries) {
    out[entry.key] = entry.value;
  }
  return out;
}

String registryHealthExportText(
  ChartRegistryHealthReport report, {
  Map<String, dynamic> extraSections = const <String, dynamic>{},
  RegistryHealthExportOptions options = RegistryHealthExportOptions.full,
}) {
  const encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(
    registryHealthExportJson(
      report,
      extraSections: extraSections,
      options: options,
    ),
  );
}

class RegistryHealthMetricCard extends StatelessWidget {
  const RegistryHealthMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: effectiveColor),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: effectiveColor),
              ),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistryHealthSectionCard extends StatelessWidget {
  const RegistryHealthSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class RegistryHealthIssueRow extends StatelessWidget {
  const RegistryHealthIssueRow({super.key, required this.issue});

  final RegistrationAuditIssue issue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            issue.isError ? Icons.error_outline : Icons.info_outline,
            size: 18,
            color: issue.isError ? Colors.red.shade700 : Colors.orange.shade800,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              issue.message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
