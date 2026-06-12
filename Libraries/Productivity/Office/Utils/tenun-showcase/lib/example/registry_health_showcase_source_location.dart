const String registryHealthChartSamplesRegistrySourceFile =
    'lib/example/chart_samples_registry.dart';

class RegistryHealthShowcaseSourceLocation {
  final String sourceFile;
  final String registryPath;
  final String familyId;
  final String familyTitle;
  final int? familyIndex;
  final String sampleTitle;
  final int? sampleIndex;
  final String? jsonPath;
  final String? chartType;
  final int? line;
  final int? column;

  const RegistryHealthShowcaseSourceLocation({
    required this.sourceFile,
    required this.registryPath,
    required this.familyId,
    required this.familyTitle,
    required this.familyIndex,
    required this.sampleTitle,
    required this.sampleIndex,
    required this.jsonPath,
    required this.chartType,
    this.line,
    this.column,
  });

  bool get hasExactPosition => line != null;

  String get displayPath {
    final position = line == null
        ? ''
        : ':$line${column == null ? '' : ':$column'}';
    return '$sourceFile$position::$registryPath';
  }

  Map<String, dynamic> toJson() => {
    'sourceFile': sourceFile,
    'registryPath': registryPath,
    'displayPath': displayPath,
    'hasExactPosition': hasExactPosition,
    'familyId': familyId,
    'familyTitle': familyTitle,
    if (familyIndex != null) 'familyIndex': familyIndex,
    'sampleTitle': sampleTitle,
    if (sampleIndex != null) 'sampleIndex': sampleIndex,
    if (jsonPath != null && jsonPath!.isNotEmpty) 'jsonPath': jsonPath,
    if (chartType != null && chartType!.isNotEmpty) 'chartType': chartType,
    if (line != null) 'line': line,
    if (column != null) 'column': column,
  };
}

RegistryHealthShowcaseSourceLocation
registryHealthShowcaseFocusedSampleSourceLocation({
  required String familyId,
  required String familyTitle,
  required int? familyIndex,
  required String sampleTitle,
  required int? sampleIndex,
  required String? jsonPath,
  required String? chartType,
  String sourceFile = registryHealthChartSamplesRegistrySourceFile,
  int? line,
  int? column,
}) {
  return RegistryHealthShowcaseSourceLocation(
    sourceFile: sourceFile,
    registryPath: registryHealthShowcaseFocusedSampleRegistryPath(
      familyId: familyId,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
      jsonPath: jsonPath,
    ),
    familyId: familyId,
    familyTitle: familyTitle,
    familyIndex: familyIndex,
    sampleTitle: sampleTitle,
    sampleIndex: sampleIndex,
    jsonPath: jsonPath,
    chartType: chartType,
    line: line,
    column: column,
  );
}

String registryHealthShowcaseFocusedSampleRegistryPath({
  required String familyId,
  required int? familyIndex,
  required String sampleTitle,
  required int? sampleIndex,
  String? jsonPath,
}) {
  final fieldPath = _registryJsonFieldPath(jsonPath);

  if (familyIndex != null && sampleIndex != null) {
    return 'ChartSamplesRegistry.focusedFamilies[$familyIndex]'
        '.samples[$sampleIndex]$fieldPath';
  }

  return 'ChartSamplesRegistry.focusedFamilies.'
      '${_stableSourceSegment(familyId)}.samples.'
      '${_stableSourceSegment(sampleTitle)}$fieldPath';
}

String registryHealthShowcaseSourceDisplayPath(
  RegistryHealthShowcaseSourceLocation location,
) {
  return location.displayPath;
}

String _registryJsonFieldPath(String? jsonPath) {
  final trimmed = jsonPath?.trim();
  if (trimmed == null || trimmed.isEmpty) return '';
  return '.json.$trimmed';
}

String _stableSourceSegment(String value) {
  final normalized = value.trim().toLowerCase();
  final out = StringBuffer();
  var lastWasSeparator = false;

  for (final codeUnit in normalized.codeUnits) {
    final isLetter = codeUnit >= 97 && codeUnit <= 122;
    final isDigit = codeUnit >= 48 && codeUnit <= 57;
    if (isLetter || isDigit) {
      out.writeCharCode(codeUnit);
      lastWasSeparator = false;
      continue;
    }
    if (!lastWasSeparator) {
      out.write('-');
      lastWasSeparator = true;
    }
  }

  final text = out.toString();
  final trimmed = text.replaceAll(RegExp('^-+|-+\$'), '');
  return trimmed.isEmpty ? 'unknown' : trimmed;
}
