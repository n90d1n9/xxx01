import 'dart:convert';

import 'chart_story_contract.dart';

String chartStoryContractMarkdown({
  required String title,
  required ChartStoryContract contract,
}) {
  final buffer = StringBuffer()
    ..writeln('# ${_escapeInline(title)}')
    ..writeln();

  final summary = contract.summary;
  if (summary != null && summary.trim().isNotEmpty) {
    buffer
      ..writeln(summary.trim())
      ..writeln();
  }

  final facets = _facetRows(contract);
  if (facets.isNotEmpty) {
    buffer
      ..writeln('## Metadata')
      ..writeln()
      ..writeln('| Field | Value |')
      ..writeln('| --- | --- |');
    for (final row in facets) {
      buffer.writeln('| ${row.label} | ${_escapeTableCell(row.value)} |');
    }
    buffer.writeln();
  }

  _writeListSection(buffer, 'Use Cases', contract.useCases);
  _writeListSection(buffer, 'Tags', contract.tags);

  if (contract.knobs.isNotEmpty) {
    buffer
      ..writeln('## Knobs')
      ..writeln()
      ..writeln('| Group | Label | Type | Default | Options |')
      ..writeln('| --- | --- | --- | --- | --- |');
    for (final knob in contract.knobs) {
      buffer.writeln(
        '| ${_escapeTableCell(knob.group)} '
        '| ${_escapeTableCell(knob.label)} '
        '| ${knob.type.name} '
        '| ${_escapeTableCell(knob.defaultValue?.toString() ?? '-')} '
        '| ${_escapeTableCell(knob.options.join(', '))} |',
      );
    }
    buffer.writeln();
  }

  final sampleJson = contract.sampleJson;
  if (sampleJson != null) {
    buffer
      ..writeln('## Sample JSON')
      ..writeln()
      ..writeln('```json')
      ..writeln(const JsonEncoder.withIndent('  ').convert(sampleJson))
      ..writeln('```')
      ..writeln();
  }

  final sampleCode = contract.sampleCode;
  if (sampleCode != null && sampleCode.trim().isNotEmpty) {
    buffer
      ..writeln('## Dart')
      ..writeln()
      ..writeln('```dart')
      ..writeln(sampleCode.trim())
      ..writeln('```')
      ..writeln();
  }

  return buffer.toString().trimRight();
}

List<_FacetRow> _facetRows(ChartStoryContract contract) {
  return [
    if (_hasText(contract.section))
      _FacetRow(label: 'Section', value: contract.section!),
    if (_hasText(contract.dataShape))
      _FacetRow(label: 'Data Shape', value: contract.dataShape!),
    if (_hasText(contract.family))
      _FacetRow(label: 'Family', value: contract.family!),
    if (_hasText(contract.variant))
      _FacetRow(label: 'Variant', value: contract.variant!),
  ];
}

void _writeListSection(
  StringBuffer buffer,
  String heading,
  List<String> values,
) {
  if (values.isEmpty) return;

  buffer
    ..writeln('## $heading')
    ..writeln();
  for (final value in values) {
    buffer.writeln('- ${value.trim()}');
  }
  buffer.writeln();
}

String _escapeInline(String value) {
  return value.replaceAll('\n', ' ').trim();
}

String _escapeTableCell(String value) {
  return _escapeInline(value).replaceAll('|', r'\|');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

class _FacetRow {
  const _FacetRow({required this.label, required this.value});

  final String label;
  final String value;
}
