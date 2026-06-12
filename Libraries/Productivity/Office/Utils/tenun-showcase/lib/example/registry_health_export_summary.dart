import 'dart:convert';

import 'package:tenun/tenun_core.dart';

import 'registry_health_export_options.dart';
import 'registry_health_export_presets.dart';

class RegistryHealthExportPresetSummary {
  const RegistryHealthExportPresetSummary({
    required this.options,
    required this.extraSectionKeys,
    required this.topLevelKeys,
    required this.payloadBytes,
  });

  final RegistryHealthExportOptions options;
  final List<String> extraSectionKeys;
  final List<String> topLevelKeys;
  final int payloadBytes;

  int get extraSectionCount => extraSectionKeys.length;
  int get topLevelKeyCount => topLevelKeys.length;
}

RegistryHealthExportPresetSummary registryHealthExportPresetSummary(
  ChartRegistryHealthReport report, {
  Map<String, dynamic> extraSections = const <String, dynamic>{},
  RegistryHealthExportOptions options = RegistryHealthExportOptions.full,
}) {
  final filteredExtraSections = registryHealthFilterExtraSections(
    extraSections,
    options: options,
  );
  final json = Map<String, dynamic>.from(report.toJson())
    ..addAll(filteredExtraSections);
  const encoder = JsonEncoder.withIndent('  ');

  return RegistryHealthExportPresetSummary(
    options: options,
    extraSectionKeys: filteredExtraSections.keys.toList(growable: false),
    topLevelKeys: json.keys.toList(growable: false),
    payloadBytes: utf8.encode(encoder.convert(json)).length,
  );
}

String registryHealthFormatExportBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }

  final kilobytes = bytes / 1024;
  if (kilobytes < 1024) {
    return '${_registryHealthFormatSizeAmount(kilobytes)} KB';
  }

  final megabytes = kilobytes / 1024;
  return '${_registryHealthFormatSizeAmount(megabytes)} MB';
}

String registryHealthExportPresetTooltip(
  RegistryHealthExportPresetSummary summary,
) {
  final label = registryHealthExportPresetLabelForOptions(summary.options);
  final sections = summary.extraSectionCount == 1 ? 'section' : 'sections';
  final size = registryHealthFormatExportBytes(summary.payloadBytes);
  return '$label export: ${summary.extraSectionCount} $sections, $size';
}

String _registryHealthFormatSizeAmount(double amount) {
  final formatted = amount < 10
      ? amount.toStringAsFixed(1)
      : amount.toStringAsFixed(0);
  return formatted.endsWith('.0')
      ? formatted.substring(0, formatted.length - 2)
      : formatted;
}
