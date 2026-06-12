import 'registry_health_showcase_source_location.dart';

class RegistryHealthShowcaseSourceMapEntry {
  final String sourceFile;
  final String familyConstName;
  final String familyId;
  final String familyTitle;
  final int familyIndex;
  final String sampleListName;
  final String sampleTitle;
  final int sampleIndex;
  final String sampleJsonSymbol;
  final int sampleLine;
  final int sampleColumn;
  final String? chartType;
  final int? typeLine;
  final int? typeColumn;

  const RegistryHealthShowcaseSourceMapEntry({
    required this.sourceFile,
    required this.familyConstName,
    required this.familyId,
    required this.familyTitle,
    required this.familyIndex,
    required this.sampleListName,
    required this.sampleTitle,
    required this.sampleIndex,
    required this.sampleJsonSymbol,
    required this.sampleLine,
    required this.sampleColumn,
    required this.chartType,
    required this.typeLine,
    required this.typeColumn,
  });

  RegistryHealthShowcaseSourceLocation locationFor({
    required String? jsonPath,
    required String? chartType,
  }) {
    final useTypePosition = jsonPath == 'type' && typeLine != null;
    return registryHealthShowcaseFocusedSampleSourceLocation(
      familyId: familyId,
      familyTitle: familyTitle,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
      jsonPath: jsonPath,
      chartType: chartType ?? this.chartType,
      sourceFile: sourceFile,
      line: useTypePosition ? typeLine : sampleLine,
      column: useTypePosition ? typeColumn : sampleColumn,
    );
  }

  Map<String, dynamic> toJson() => {
    'sourceFile': sourceFile,
    'familyConstName': familyConstName,
    'familyId': familyId,
    'familyTitle': familyTitle,
    'familyIndex': familyIndex,
    'sampleListName': sampleListName,
    'sampleTitle': sampleTitle,
    'sampleIndex': sampleIndex,
    'sampleJsonSymbol': sampleJsonSymbol,
    'sampleLine': sampleLine,
    'sampleColumn': sampleColumn,
    if (chartType != null && chartType!.isNotEmpty) 'chartType': chartType,
    if (typeLine != null) 'typeLine': typeLine,
    if (typeColumn != null) 'typeColumn': typeColumn,
  };
}

class RegistryHealthShowcaseSourceMap {
  final String sourceFile;
  final List<RegistryHealthShowcaseSourceMapEntry> entries;

  const RegistryHealthShowcaseSourceMap({
    required this.sourceFile,
    required this.entries,
  });

  RegistryHealthShowcaseSourceMapEntry? entryFor({
    required String familyId,
    required int? familyIndex,
    required String sampleTitle,
    required int? sampleIndex,
  }) {
    for (final entry in entries) {
      if (familyIndex != null &&
          sampleIndex != null &&
          entry.familyIndex == familyIndex &&
          entry.sampleIndex == sampleIndex) {
        return entry;
      }
    }

    for (final entry in entries) {
      if (entry.familyId == familyId && entry.sampleTitle == sampleTitle) {
        return entry;
      }
    }

    return null;
  }

  RegistryHealthShowcaseSourceLocation locationFor({
    required String familyId,
    required String familyTitle,
    required int? familyIndex,
    required String sampleTitle,
    required int? sampleIndex,
    required String? jsonPath,
    required String? chartType,
  }) {
    final entry = entryFor(
      familyId: familyId,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
    );

    if (entry != null) {
      return entry.locationFor(jsonPath: jsonPath, chartType: chartType);
    }

    return registryHealthShowcaseFocusedSampleSourceLocation(
      familyId: familyId,
      familyTitle: familyTitle,
      familyIndex: familyIndex,
      sampleTitle: sampleTitle,
      sampleIndex: sampleIndex,
      jsonPath: jsonPath,
      chartType: chartType,
      sourceFile: sourceFile,
    );
  }

  Map<String, dynamic> toJson() => {
    'sourceFile': sourceFile,
    'entryCount': entries.length,
    'entries': [for (final entry in entries) entry.toJson()],
  };
}

RegistryHealthShowcaseSourceMap registryHealthShowcaseSourceMapFromText(
  String source, {
  String sourceFile = registryHealthChartSamplesRegistrySourceFile,
}) {
  final lines = source.split('\n');
  final maps = <String, _MapSource>{};
  final sampleLists = <String, List<_SampleSource>>{};
  final families = <String, _FamilySource>{};
  final focusedFamilyNames = <String>[];

  for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
    final line = lines[lineIndex];
    final mapName = _mapDeclarationName(line);
    if (mapName != null) {
      final parsed = _readMapSource(lines, lineIndex, mapName);
      maps[mapName] = parsed.item;
      lineIndex = parsed.endLineIndex;
      continue;
    }

    final sampleListName = _sampleListDeclarationName(line);
    if (sampleListName != null) {
      final parsed = _readSampleList(lines, lineIndex, sampleListName);
      sampleLists[sampleListName] = parsed.item;
      lineIndex = parsed.endLineIndex;
      continue;
    }

    final familyName = _familyDeclarationName(line);
    if (familyName != null) {
      final parsed = _readFamily(lines, lineIndex, familyName);
      families[familyName] = parsed.item;
      lineIndex = parsed.endLineIndex;
      continue;
    }

    if (_isFocusedFamiliesDeclaration(line)) {
      final parsed = _readFocusedFamilies(lines, lineIndex);
      focusedFamilyNames.addAll(parsed.item);
      lineIndex = parsed.endLineIndex;
    }
  }

  final entries = <RegistryHealthShowcaseSourceMapEntry>[];
  for (
    var familyIndex = 0;
    familyIndex < focusedFamilyNames.length;
    familyIndex++
  ) {
    final familyConstName = focusedFamilyNames[familyIndex];
    final family = families[familyConstName];
    if (family == null) continue;

    final samples = sampleLists[family.sampleListName];
    if (samples == null) continue;

    for (var sampleIndex = 0; sampleIndex < samples.length; sampleIndex++) {
      final sample = samples[sampleIndex];
      final chartMap = maps[sample.sampleJsonSymbol];
      entries.add(
        RegistryHealthShowcaseSourceMapEntry(
          sourceFile: sourceFile,
          familyConstName: familyConstName,
          familyId: family.id,
          familyTitle: family.title,
          familyIndex: familyIndex,
          sampleListName: family.sampleListName,
          sampleTitle: sample.title,
          sampleIndex: sampleIndex,
          sampleJsonSymbol: sample.sampleJsonSymbol,
          sampleLine: sample.line,
          sampleColumn: sample.column,
          chartType: chartMap?.typeValue,
          typeLine: chartMap?.typeLine,
          typeColumn: chartMap?.typeColumn,
        ),
      );
    }
  }

  return RegistryHealthShowcaseSourceMap(
    sourceFile: sourceFile,
    entries: List<RegistryHealthShowcaseSourceMapEntry>.unmodifiable(entries),
  );
}

String? _mapDeclarationName(String line) {
  return RegExp(
    r'static\s+const\s+Map<[^>]+>\s+(\w+)\s*=',
  ).firstMatch(line)?.group(1);
}

String? _sampleListDeclarationName(String line) {
  return RegExp(
    r'static\s+const\s+List<ChartShowcaseSample>\s+(\w+)\s*=',
  ).firstMatch(line)?.group(1);
}

String? _familyDeclarationName(String line) {
  return RegExp(
    r'static\s+const\s+ChartShowcaseFamily\s+(\w+)\s*=',
  ).firstMatch(line)?.group(1);
}

bool _isFocusedFamiliesDeclaration(String line) {
  return RegExp(
    r'static\s+const\s+List<ChartShowcaseFamily>\s+focusedFamilies\s*=',
  ).hasMatch(line);
}

_Parsed<_MapSource> _readMapSource(
  List<String> lines,
  int startLineIndex,
  String name,
) {
  String? typeValue;
  int? typeLine;
  int? typeColumn;
  var balance = 0;
  var endLineIndex = startLineIndex;

  for (var i = startLineIndex; i < lines.length; i++) {
    final line = lines[i];
    final typeMatch = RegExp(
      r'''['"]type['"]\s*:\s*['"]([^'"]*)['"]''',
    ).firstMatch(line);
    if (typeMatch != null && typeLine == null) {
      typeValue = typeMatch.group(1);
      typeLine = i + 1;
      typeColumn = typeMatch.start + 1;
    }

    balance += _delimiterDelta(line, 123, 125);
    endLineIndex = i;
    if (i > startLineIndex && balance <= 0) break;
  }

  return _Parsed(
    _MapSource(
      name: name,
      typeValue: typeValue,
      typeLine: typeLine,
      typeColumn: typeColumn,
    ),
    endLineIndex,
  );
}

_Parsed<List<_SampleSource>> _readSampleList(
  List<String> lines,
  int startLineIndex,
  String name,
) {
  final samples = <_SampleSource>[];
  var balance = 0;
  var endLineIndex = startLineIndex;

  for (var i = startLineIndex; i < lines.length; i++) {
    final line = lines[i];
    final sampleMatch = RegExp(
      r'''ChartShowcaseSample\(\s*['"]([^'"]+)['"]\s*,\s*[^,]+,\s*(\w+)''',
    ).firstMatch(line);
    if (sampleMatch != null) {
      samples.add(
        _SampleSource(
          title: sampleMatch.group(1)!,
          sampleJsonSymbol: sampleMatch.group(2)!,
          line: i + 1,
          column: sampleMatch.start + 1,
        ),
      );
    }

    balance += _delimiterDelta(line, 91, 93);
    endLineIndex = i;
    if (i > startLineIndex && balance <= 0) break;
  }

  return _Parsed(samples, endLineIndex);
}

_Parsed<_FamilySource> _readFamily(
  List<String> lines,
  int startLineIndex,
  String name,
) {
  var id = '';
  var title = '';
  var sampleListName = '';
  var endLineIndex = startLineIndex;

  for (var i = startLineIndex; i < lines.length; i++) {
    final line = lines[i];
    id = _fieldStringValue(line, 'id') ?? id;
    title = _fieldStringValue(line, 'title') ?? title;
    sampleListName = _fieldSymbolValue(line, 'samples') ?? sampleListName;
    endLineIndex = i;
    if (i > startLineIndex && line.trim() == ');') break;
  }

  return _Parsed(
    _FamilySource(
      name: name,
      id: id,
      title: title,
      sampleListName: sampleListName,
    ),
    endLineIndex,
  );
}

_Parsed<List<String>> _readFocusedFamilies(
  List<String> lines,
  int startLineIndex,
) {
  final names = <String>[];
  var endLineIndex = startLineIndex;

  for (var i = startLineIndex + 1; i < lines.length; i++) {
    final line = lines[i].trim();
    final match = RegExp(r'^(\w+),?$').firstMatch(line);
    if (match != null) names.add(match.group(1)!);
    endLineIndex = i;
    if (line == '];') break;
  }

  return _Parsed(names, endLineIndex);
}

String? _fieldStringValue(String line, String fieldName) {
  return RegExp(
    "$fieldName:\\s*['\"]([^'\"]*)['\"]",
  ).firstMatch(line)?.group(1);
}

String? _fieldSymbolValue(String line, String fieldName) {
  return RegExp('$fieldName:\\s*(\\w+)').firstMatch(line)?.group(1);
}

int _delimiterDelta(String line, int openCodeUnit, int closeCodeUnit) {
  var delta = 0;
  for (final codeUnit in line.codeUnits) {
    if (codeUnit == openCodeUnit) delta++;
    if (codeUnit == closeCodeUnit) delta--;
  }
  return delta;
}

class _Parsed<T> {
  final T item;
  final int endLineIndex;

  const _Parsed(this.item, this.endLineIndex);
}

class _MapSource {
  final String name;
  final String? typeValue;
  final int? typeLine;
  final int? typeColumn;

  const _MapSource({
    required this.name,
    required this.typeValue,
    required this.typeLine,
    required this.typeColumn,
  });
}

class _SampleSource {
  final String title;
  final String sampleJsonSymbol;
  final int line;
  final int column;

  const _SampleSource({
    required this.title,
    required this.sampleJsonSymbol,
    required this.line,
    required this.column,
  });
}

class _FamilySource {
  final String name;
  final String id;
  final String title;
  final String sampleListName;

  const _FamilySource({
    required this.name,
    required this.id,
    required this.title,
    required this.sampleListName,
  });
}
