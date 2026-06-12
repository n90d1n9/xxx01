import 'dart:convert';

import '../model/field_config.dart';
import '../model/form_theme.dart';
import 'code_generator.dart';

enum ExportFormat {
  json,
  yaml,
  xml,
  flutterCode,
  reactCode,
  vueCode,
  html,
  pdf,
  markdown,
}

class ExportManager {
  static String export(
    List<FieldConfig> fields,
    ExportFormat format,
    FormTheme theme,
  ) {
    switch (format) {
      case ExportFormat.json:
        return _exportJSON(fields);
      case ExportFormat.yaml:
        return _exportYAML(fields);
      case ExportFormat.xml:
        return _exportXML(fields);
      case ExportFormat.flutterCode:
        return CodeGenerator.generateFlutterCode(fields, theme);
      case ExportFormat.reactCode:
        return CodeGenerator.generateReactCode(fields);
      case ExportFormat.html:
        return CodeGenerator.generateHTML(fields);
      case ExportFormat.markdown:
        return _exportMarkdown(fields);
      default:
        return _exportJSON(fields);
    }
  }

  static String _exportJSON(List<FieldConfig> fields) {
    final config = {
      'version': '1.0.0',
      'fields': fields.map((f) => f.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(config);
  }

  static String _exportYAML(List<FieldConfig> fields) {
    final buffer = StringBuffer();
    buffer.writeln('version: 1.0.0');
    buffer.writeln('fields:');
    for (final field in fields) {
      buffer.writeln('  - type: ${field.type}');
      if (field.name != null) buffer.writeln('    name: ${field.name}');
      if (field.label != null) buffer.writeln('    label: ${field.label}');
      if (field.required) buffer.writeln('    required: true');
    }
    return buffer.toString();
  }

  static String _exportXML(List<FieldConfig> fields) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<form version="1.0.0">');
    buffer.writeln('  <fields>');
    for (final field in fields) {
      buffer.writeln('    <field type="${field.type}">');
      if (field.name != null) {
        buffer.writeln('      <name>${field.name}</name>');
      }
      if (field.label != null) {
        buffer.writeln('      <label>${field.label}</label>');
      }
      if (field.required) buffer.writeln('      <required>true</required>');
      buffer.writeln('    </field>');
    }
    buffer.writeln('  </fields>');
    buffer.writeln('</form>');
    return buffer.toString();
  }

  static String _exportMarkdown(List<FieldConfig> fields) {
    final buffer = StringBuffer();
    buffer.writeln('# Form Structure\n');
    for (final field in fields) {
      buffer.writeln('## ${field.label ?? field.type}');
      buffer.writeln('- **Type**: ${field.type}');
      if (field.name != null) buffer.writeln('- **Name**: ${field.name}');
      if (field.required) buffer.writeln('- **Required**: Yes');
      buffer.writeln();
    }
    return buffer.toString();
  }
}
