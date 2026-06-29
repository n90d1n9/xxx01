import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:math' as math;

import '../form_designer/zz.dart';

// ============================================================================
// PHASE 2: STEP 10 - RESPONSIVE GRID SYSTEM
// ============================================================================

class ResponsiveGridSystem {
  static const breakpoints = {
    'xs': 0,
    'sm': 576,
    'md': 768,
    'lg': 992,
    'xl': 1200,
    'xxl': 1400,
  };

  static String getCurrentBreakpoint(double width) {
    if (width >= breakpoints['xxl']!) return 'xxl';
    if (width >= breakpoints['xl']!) return 'xl';
    if (width >= breakpoints['lg']!) return 'lg';
    if (width >= breakpoints['md']!) return 'md';
    if (width >= breakpoints['sm']!) return 'sm';
    return 'xs';
  }

  static int getColumns(String breakpoint) {
    switch (breakpoint) {
      case 'xxl':
      case 'xl':
        return 12;
      case 'lg':
        return 12;
      case 'md':
        return 8;
      case 'sm':
        return 4;
      case 'xs':
        return 2;
      default:
        return 12;
    }
  }
}

class GridConfig {
  final Map<String, int> columnSpan; // breakpoint -> columns
  final Map<String, int> columnOffset;
  final Map<String, bool> hidden;
  final String alignment; // start, center, end, stretch
  final double gap;

  const GridConfig({
    this.columnSpan = const {'xs': 12},
    this.columnOffset = const {},
    this.hidden = const {},
    this.alignment = 'stretch',
    this.gap = 16,
  });

  GridConfig copyWith({
    Map<String, int>? columnSpan,
    Map<String, int>? columnOffset,
    Map<String, bool>? hidden,
    String? alignment,
    double? gap,
  }) {
    return GridConfig(
      columnSpan: columnSpan ?? this.columnSpan,
      columnOffset: columnOffset ?? this.columnOffset,
      hidden: hidden ?? this.hidden,
      alignment: alignment ?? this.alignment,
      gap: gap ?? this.gap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'columnSpan': columnSpan,
      'columnOffset': columnOffset,
      'hidden': hidden,
      'alignment': alignment,
      'gap': gap,
    };
  }
}

// ============================================================================
// PHASE 3: STEP 11 - ADVANCED FIELD TYPES
// ============================================================================

enum AdvancedFieldType {
  richText,
  fileUpload,
  imageUpload,
  signature,
  rating,
  slider,
  colorPicker,
  datePicker,
  timePicker,
  dateTimePicker,
  dateRange,
  location,
  map,
  qrCode,
  barcode,
}

class AdvancedFieldConfig {
  final AdvancedFieldType type;
  final Map<String, dynamic> settings;

  const AdvancedFieldConfig({
    required this.type,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'settings': settings,
    };
  }
}

// ============================================================================
// PHASE 3: STEP 12 - VALIDATION SYSTEM
// ============================================================================

enum ValidationType {
  required,
  email,
  url,
  phone,
  regex,
  minLength,
  maxLength,
  min,
  max,
  custom,
}

class ValidationRule {
  final ValidationType type;
  final dynamic value;
  final String? message;
  final bool async;

  const ValidationRule({
    required this.type,
    this.value,
    this.message,
    this.async = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'value': value,
      'message': message,
      'async': async,
    };
  }
}

class ValidationSchema {
  final List<ValidationRule> rules;
  final String? customValidatorCode;
  final Map<String, dynamic>? asyncValidation;

  const ValidationSchema({
    required this.rules,
    this.customValidatorCode,
    this.asyncValidation,
  });

  Map<String, dynamic> toJson() {
    return {
      'rules': rules.map((r) => r.toJson()).toList(),
      if (customValidatorCode != null) 'customValidator': customValidatorCode,
      if (asyncValidation != null) 'asyncValidation': asyncValidation,
    };
  }
}

// ============================================================================
// PHASE 3: STEP 13 - CONDITIONAL LOGIC BUILDER
// ============================================================================

enum ConditionOperator {
  equals,
  notEquals,
  contains,
  notContains,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  isEmpty,
  isNotEmpty,
  startsWith,
  endsWith,
  matches, // regex
}

class Condition {
  final String fieldId;
  final ConditionOperator operator;
  final dynamic value;

  const Condition({
    required this.fieldId,
    required this.operator,
    this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'operator': operator.toString(),
      'value': value,
    };
  }
}

enum LogicOperator { and, or }

class ConditionalRule {
  final List<Condition> conditions;
  final LogicOperator logicOperator;
  final ConditionalAction action;

  const ConditionalRule({
    required this.conditions,
    required this.logicOperator,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'logic': logicOperator.toString(),
      'action': action.toJson(),
    };
  }
}

enum ActionType {
  show,
  hide,
  enable,
  disable,
  setValue,
  calculate,
  validate,
  trigger,
}

class ConditionalAction {
  final ActionType type;
  final List<String> targetFieldIds;
  final dynamic value;
  final String? expression;

  const ConditionalAction({
    required this.type,
    required this.targetFieldIds,
    this.value,
    this.expression,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'targets': targetFieldIds,
      if (value != null) 'value': value,
      if (expression != null) 'expression': expression,
    };
  }
}

// ============================================================================
// PHASE 3: STEP 14 - TEMPLATES & LIBRARY
// ============================================================================

class FormTemplate {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> tags;
  final String thumbnail;
  final List<FieldConfig> fields;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final int usageCount;
  final double rating;

  const FormTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.tags,
    required this.thumbnail,
    required this.fields,
    required this.metadata,
    required this.createdAt,
    this.usageCount = 0,
    this.rating = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'tags': tags,
      'thumbnail': thumbnail,
      'fields': fields.map((f) => f.toJson()).toList(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'usageCount': usageCount,
      'rating': rating,
    };
  }
}

class TemplateLibrary {
  static final List<FormTemplate> predefined = [
    FormTemplate(
      id: 'contact_form',
      name: 'Contact Form',
      description: 'Simple contact form with name, email, and message',
      category: 'Contact',
      tags: ['contact', 'email', 'basic'],
      thumbnail: '📧',
      fields: [
        FieldConfig(
          id: 'name',
          type: 'text',
          name: 'name',
          label: 'Full Name',
          required: true,
        ),
        FieldConfig(
          id: 'email',
          type: 'email',
          name: 'email',
          label: 'Email Address',
          required: true,
        ),
        FieldConfig(
          id: 'message',
          type: 'textarea',
          name: 'message',
          label: 'Message',
          required: true,
        ),
      ],
      metadata: {},
      createdAt: DateTime.now(),
      usageCount: 150,
      rating: 4.5,
    ),
    FormTemplate(
      id: 'registration',
      name: 'User Registration',
      description: 'Complete user registration with validation',
      category: 'Authentication',
      tags: ['registration', 'auth', 'user'],
      thumbnail: '👤',
      fields: [
        FieldConfig(
          id: 'username',
          type: 'text',
          name: 'username',
          label: 'Username',
          required: true,
        ),
        FieldConfig(
          id: 'email',
          type: 'email',
          name: 'email',
          label: 'Email',
          required: true,
        ),
        FieldConfig(
          id: 'password',
          type: 'password',
          name: 'password',
          label: 'Password',
          required: true,
        ),
        FieldConfig(
          id: 'confirm_password',
          type: 'password',
          name: 'confirm_password',
          label: 'Confirm Password',
          required: true,
        ),
      ],
      metadata: {},
      createdAt: DateTime.now(),
      usageCount: 200,
      rating: 4.8,
    ),
  ];
}

// ============================================================================
// PHASE 3: STEP 15 - FORM VERSIONING
// ============================================================================

class FormVersion {
  final String id;
  final int versionNumber;
  final String title;
  final List<FieldConfig> fields;
  final DateTime createdAt;
  final String createdBy;
  final String? changeLog;
  final Map<String, dynamic>? diff;
  final bool isPublished;
  final String? publishedAt;

  const FormVersion({
    required this.id,
    required this.versionNumber,
    required this.title,
    required this.fields,
    required this.createdAt,
    required this.createdBy,
    this.changeLog,
    this.diff,
    this.isPublished = false,
    this.publishedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': versionNumber,
      'title': title,
      'fields': fields.map((f) => f.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'changeLog': changeLog,
      'diff': diff,
      'isPublished': isPublished,
      'publishedAt': publishedAt,
    };
  }
}

class VersionManager extends StateNotifier<List<FormVersion>> {
  VersionManager() : super([]);

  void createVersion(List<FieldConfig> fields, String title, String? changeLog) {
    final version = FormVersion(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      versionNumber: state.length + 1,
      title: title,
      fields: fields,
      createdAt: DateTime.now(),
      createdBy: 'current_user',
      changeLog: changeLog,
    );
    state = [...state, version];
  }

  void publishVersion(String versionId) {
    state = state.map((v) {
      if (v.id == versionId) {
        return FormVersion(
          id: v.id,
          versionNumber: v.versionNumber,
          title: v.title,
          fields: v.fields,
          createdAt: v.createdAt,
          createdBy: v.createdBy,
          changeLog: v.changeLog,
          diff: v.diff,
          isPublished: true,
          publishedAt: DateTime.now().toIso8601String(),
        );
      }
      return v;
    }).toList();
  }

  FormVersion? getVersion(String id) {
    try {
      return state.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  FormVersion? getLatestPublished() {
    final published = state.where((v) => v.isPublished).toList();
    if (published.isEmpty) return null;
    return published.last;
  }
}

// ============================================================================
// PHASE 4: STEP 16 - CODE GENERATION
// ============================================================================

class CodeGenerator {
  static String generateFlutterCode(List<FieldConfig> fields, FormTheme theme) {
    final buffer = StringBuffer();
    
    buffer.writeln('import \'package:flutter/material.dart\';');
    buffer.writeln('');
    buffer.writeln('class GeneratedForm extends StatefulWidget {');
    buffer.writeln('  const GeneratedForm({Key? key}) : super(key: key);');
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  State<GeneratedForm> createState() => _GeneratedFormState();');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('class _GeneratedFormState extends State<GeneratedForm> {');
    buffer.writeln('  final _formKey = GlobalKey<FormState>();');
    
    // Controllers
    for (final field in fields) {
      if (!field.isContainer) {
        buffer.writeln('  final _${field.name}Controller = TextEditingController();');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return Form(');
    buffer.writeln('      key: _formKey,');
    buffer.writeln('      child: Column(');
    buffer.writeln('        children: [');
    
    for (final field in fields) {
      buffer.writeln('          ${_generateFieldWidget(field, theme)},');
    }
    
    buffer.writeln('          ElevatedButton(');
    buffer.writeln('            onPressed: () {');
    buffer.writeln('              if (_formKey.currentState!.validate()) {');
    buffer.writeln('                // Handle form submission');
    buffer.writeln('              }');
    buffer.writeln('            },');
    buffer.writeln('            child: const Text(\'Submit\'),');
    buffer.writeln('          ),');
    buffer.writeln('        ],');
    buffer.writeln('      ),');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
    
    return buffer.toString();
  }

  static String _generateFieldWidget(FieldConfig field, FormTheme theme) {
    switch (field.type) {
      case 'text':
      case 'email':
      case 'password':
        return '''TextFormField(
            controller: _${field.name}Controller,
            decoration: InputDecoration(
              labelText: '${field.label}',
              hintText: '${field.hint ?? ''}',
            ),
            validator: (value) {
              if (${field.required} && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
          )''';
      case 'number':
        return '''TextFormField(
            controller: _${field.name}Controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${field.label}',
            ),
          )''';
      default:
        return 'Container()';
    }
  }

  static String generateReactCode(List<FieldConfig> fields) {
    final buffer = StringBuffer();
    
    buffer.writeln('import React, { useState } from \'react\';');
    buffer.writeln('');
    buffer.writeln('export default function GeneratedForm() {');
    buffer.writeln('  const [formData, setFormData] = useState({');
    
    for (final field in fields.where((f) => !f.isContainer)) {
      buffer.writeln('    ${field.name}: \'\',');
    }
    
    buffer.writeln('  });');
    buffer.writeln('');
    buffer.writeln('  const handleSubmit = (e) => {');
    buffer.writeln('    e.preventDefault();');
    buffer.writeln('    console.log(formData);');
    buffer.writeln('  };');
    buffer.writeln('');
    buffer.writeln('  return (');
    buffer.writeln('    <form onSubmit={handleSubmit}>');
    
    for (final field in fields) {
      buffer.writeln(_generateReactField(field));
    }
    
    buffer.writeln('      <button type="submit">Submit</button>');
    buffer.writeln('    </form>');
    buffer.writeln('  );');
    buffer.writeln('}');
    
    return buffer.toString();
  }

  static String _generateReactField(FieldConfig field) {
    return '''
      <div>
        <label>${field.label}</label>
        <input
          type="${field.type}"
          name="${field.name}"
          ${field.required ? 'required' : ''}
          onChange={(e) => setFormData({...formData, ${field.name}: e.target.value})}
        />
      </div>''';
  }

  static String generateHTML(List<FieldConfig> fields) {
    final buffer = StringBuffer();
    
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('  <meta charset="UTF-8">');
    buffer.writeln('  <title>Generated Form</title>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('  <form id="generatedForm">');
    
    for (final field in fields) {
      buffer.writeln(_generateHTMLField(field));
    }
    
    buffer.writeln('    <button type="submit">Submit</button>');
    buffer.writeln('  </form>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');
    
    return buffer.toString();
  }

  static String _generateHTMLField(FieldConfig field) {
    return '''
    <div>
      <label for="${field.name}">${field.label}</label>
      <input 
        type="${field.type}" 
        id="${field.name}" 
        name="${field.name}"
        ${field.required ? 'required' : ''}
      />
    </div>''';
  }
}

// ============================================================================
// PHASE 4: STEP 17 - MULTIPLE EXPORT FORMATS
// ============================================================================

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
  static String export(List<FieldConfig> fields, ExportFormat format, FormTheme theme) {
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
      if (field.name != null) buffer.writeln('      <name>${field.name}</name>');
      if (field.label != null) buffer.writeln('      <label>${field.label}</label>');
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

// ============================================================================
// PHASE 4: STEP 18 - API INTEGRATION
// ============================================================================

class APIIntegration {
  final String endpoint;
  final String method; // GET, POST, PUT, DELETE
  final Map<String, String>? headers;
  final Map<String, dynamic>? body;
  final String? authType; // none, bearer, apiKey, basic
  final String? authToken;

  const APIIntegration({
    required this.endpoint,
    this.method = 'POST',
    this.headers,
    this.body,
    this.authType,
    this.authToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'method': method,
      'headers': headers,
      'body': body,
      'authType': authType,
      'authToken': authToken,
    };
  }
}

// ============================================================================
// PHASE 4: STEP 19 - TESTING & SIMULATION
// ============================================================================

class FormTester {
  static List<TestCase> generateTestCases(List<FieldConfig> fields) {
    final testCases = <TestCase>[];
    
    // Required field tests
    for (final field in fields.where((f) => f.required)) {
      testCases.add(TestCase(
        name: '${field.label ?? field.name} - Required validation',
        fieldId: field.id,
        input: '',
        expectedResult: TestResult.failure,
        expectedMessage: 'Field is required',
      ));
    }
    
    // Email validation tests
    for (final field in fields.where((f) => f.type == 'email')) {
      testCases.add(TestCase(
        name: '${field.label ?? field.name} - Valid email',
        fieldId: field.id,
        input: 'test@example.com',
        expectedResult: TestResult.success,
      ));
      
      testCases.add(TestCase(
        name: '${field.label ?? field.name} - Invalid email',
        fieldId: field.id,
        input: 'invalid-email',
        expectedResult: TestResult.failure,
      ));
    }
    
    return testCases;
  }
}

enum TestResult { success, failure, warning }

class TestCase {
  final String name;
  final String fieldId;
  final dynamic input;
  final TestResult expectedResult;
  final String? expectedMessage;

  const TestCase({
    required this.name,
    required this.fieldId,
    required this.input,
    required this.expectedResult,
    this.expectedMessage,
  });
}

// ============================================================================
// PHASE 4: STEP 20 - ANALYTICS DASHBOARD
// ============================================================================

class FormAnalytics {
  final int totalSubmissions;
  final int successfulSubmissions;
  final int failedSubmissions;
  final double averageCompletionTime;
  final Map<String, int> fieldErrors;
  final Map<String, double> fieldCompletionRate;
  final List<DropOffPoint> dropOffPoints;

  const FormAnalytics({
    required this.totalSubmissions,
    required this.successfulSubmissions,
    required this.failedSubmissions,
    required this.averageCompletionTime,
    required this.fieldErrors,
    required this.fieldCompletionRate,
    required this.dropOffPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalSubmissions': totalSubmissions,
      'successfulSubmissions': successfulSubmissions,
      'failedSubmissions': failedSubmissions,
      'averageCompletionTime': averageCompletionTime,
      'fieldErrors': fieldErrors,
      'fieldCompletionRate': fieldCompletionRate,
      'dropOffPoints': dropOffPoints.map((d) => d.toJson()).toList(),
    };
  }
}

class DropOffPoint {
  final String fieldId;
  final String fieldLabel;
  final int dropOffCount;
  final double dropOffRate;

  const DropOffPoint({
    required this.fieldId,
    required this.fieldLabel,
    required this.dropOffCount,
    required this.dropOffRate,
  });

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'fieldLabel': fieldLabel,
      'dropOffCount': dropOffCount,
      'dropOffRate': dropOffRate,
    };
  }
}

// ============================================================================
// COMPLETE MAIN DESIGNER WITH ALL PHASES
// ============================================================================

class CompleteFormBuilderDesigner extends ConsumerStatefulWidget {
  const CompleteFormBuilderDesigner({Key? key}) : super(key: key);

  @override
  ConsumerState<CompleteFormBuilderDesigner> createState() => _CompleteFormBuilderDesignerState();
}

class _CompleteFormBuilderDesignerState extends ConsumerState<CompleteFormBuilderDesigner> {
  int _selectedPhase = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        title: const Text('🚀 Form Builder - Complete (Phases 1-4)'),
        backgroundColor: theme.colors.surface,
        foregroundColor: theme.colors.text,
        actions: [
          // Phase selector
          PopupMenuButton<int>(
            icon: Icon(Icons.layers, color: theme.colors.primary),
            tooltip: 'Select Phase',
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0, child: Text('Phase 1: Core Features')),
              const PopupMenuItem(value: 1, child: Text('Phase 2: Visual & Layout')),
              const PopupMenuItem(value: 2, child: Text('Phase 3: Advanced Features')),
              const PopupMenuItem(value: 3, child: Text('Phase 4: Integration')),
            ],
            onSelected: (value) => setState(() => _selectedPhase = value),
          ),
          
          // Export menu
          PopupMenuButton<ExportFormat>(
            icon: Icon(Icons.download, color: theme.colors.text),
            tooltip: 'Export',
            itemBuilder: (context) => [
              const PopupMenuItem(value: ExportFormat.json, child: Text('📄 JSON')),
              const PopupMenuItem(value: ExportFormat.yaml, child: Text('📋 YAML')),
              const PopupMenuItem(value: ExportFormat.xml, child: Text('🔖 XML')),
              const PopupMenuItem(value: ExportFormat.flutterCode, child: Text('📱 Flutter Code')),
              const PopupMenuItem(value: ExportFormat.reactCode, child: Text('⚛️ React Code')),
              const PopupMenuItem(value: ExportFormat.html, child: Text('🌐 HTML')),
              const PopupMenuItem(value: ExportFormat.markdown, child: Text('📝 Markdown')),
            ],
            onSelected: (format) => _handleExport(format),
          ),
          
          // Templates
          IconButton(
            icon: Icon(Icons.library_books, color: theme.colors.text),
            tooltip: 'Templates',
            onPressed: () => _showTemplateLibrary(),
          ),
          
          // Testing
          IconButton(
            icon: Icon(Icons.bug_report, color: theme.colors.text),
            tooltip: 'Test Form',
            onPressed: () => _showTestRunner(),
          ),
          
          // Analytics
          IconButton(
            icon: Icon(Icons.analytics, color: theme.colors.text),
            tooltip: 'Analytics',
            onPressed: () => _showAnalytics(),
          ),
          
          // Versioning
          IconButton(
            icon: Icon(Icons.history, color: theme.colors.text),
            tooltip: 'Version History',
            onPressed: () => _showVersionHistory(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Component Palette
          CompleteComponentPalette(theme: theme, phase: _selectedPhase),
          
          // Main canvas
          Expanded(
            child: Column(
              children: [
                // Phase toolbar
                _buildPhaseToolbar(theme),
                
                // Canvas area
                Expanded(
                  child: FormCanvasWidget(theme: theme),
                ),
              ],
            ),
          ),
          
          // Right sidebar - Properties & Tools
          CompletePropertiesPanel(theme: theme, phase: _selectedPhase),
        ],
      ),
      floatingActionButton: _buildFloatingActions(theme),
    );
  }

  Widget _buildPhaseToolbar(FormTheme theme) {
    final phaseInfo = [
      {'name': 'Core', 'icon': Icons.build, 'color': Colors.blue},
      {'name': 'Visual', 'icon': Icons.palette, 'color': Colors.purple},
      {'name': 'Advanced', 'icon': Icons.settings, 'color': Colors.orange},
      {'name': 'Integration', 'icon': Icons.integration_instructions, 'color': Colors.green},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Row(
        children: [
          ...phaseInfo.asMap().entries.map((entry) {
            final index = entry.key;
            final info = entry.value;
            final isActive = _selectedPhase == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPhase = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? (info['color'] as Color).withOpacity(0.2) : Colors.transparent,
                    border: Border.all(
                      color: isActive ? (info['color'] as Color) : theme.colors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        info['icon'] as IconData,
                        color: isActive ? (info['color'] as Color) : theme.colors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phase ${index + 1}: ${info['name']}',
                        style: TextStyle(
                          color: isActive ? (info['color'] as Color) : theme.colors.textSecondary,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // Quick stats
          _buildQuickStat(theme, Icons.layers, '${ref.watch(formFieldsProvider).length} Fields'),
          const SizedBox(width: 16),
          _buildQuickStat(theme, Icons.check_circle, 'Ready'),
        ],
      ),
    );
  }

  Widget _buildQuickStat(FormTheme theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: theme.colors.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(FormTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'preview',
          mini: true,
          backgroundColor: theme.colors.primary,
          onPressed: () => _showPreview(),
          child: const Icon(Icons.visibility, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'save',
          mini: true,
          backgroundColor: Colors.green,
          onPressed: () => _saveForm(),
          child: const Icon(Icons.save, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'deploy',
          backgroundColor: theme.colors.primary,
          onPressed: () => _deployForm(),
          child: const Icon(Icons.rocket_launch),
        ),
      ],
    );
  }

  void _handleExport(ExportFormat format) {
    final fields = ref.read(formFieldsProvider);
    final theme = ref.read(themeManagerProvider);
    final exported = ExportManager.export(fields, format, theme);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.download, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Export as ${format.toString().split('.').last.toUpperCase()}',
                style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Generated ${format.toString().split('.').last} export',
                      style: TextStyle(color: theme.colors.textSecondary, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: theme.colors.primary, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: exported));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('✅ Copied to clipboard!'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      exported,
                      style: const TextStyle(
                        color: Color(0xFF4EC9B0),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colors.primary),
            onPressed: () {
              // In a real app, trigger file download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📥 Download started')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTemplateLibrary() {
    final theme = ref.read(themeManagerProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.library_books, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Template Library', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: SizedBox(
          width: 800,
          height: 600,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: TemplateLibrary.predefined.length,
            itemBuilder: (context, index) {
              final template = TemplateLibrary.predefined[index];
              return _buildTemplateCard(template, theme);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(FormTemplate template, FormTheme theme) {
    return InkWell(
      onTap: () {
        // Load template
        ref.read(formFieldsProvider.notifier).clear();
        for (final field in template.fields) {
          ref.read(formFieldsProvider.notifier).addField(field);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Loaded template: ${template.name}')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(template.thumbnail, style: const TextStyle(fontSize: 32)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    template.category,
                    style: TextStyle(color: theme.colors.primary, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              template.name,
              style: TextStyle(
                color: theme.colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: TextStyle(
                color: theme.colors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  template.rating.toString(),
                  style: TextStyle(color: theme.colors.text, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.download, color: theme.colors.textSecondary, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${template.usageCount}',
                  style: TextStyle(color: theme.colors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTestRunner() {
    final theme = ref.read(themeManagerProvider);
    final fields = ref.read(formFieldsProvider);
    final testCases = FormTester.generateTestCases(fields);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.bug_report, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Test Runner', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Generated ${testCases.length} test cases for ${fields.length} fields',
                        style: const TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: testCases.length,
                  itemBuilder: (context, index) {
                    final test = testCases[index];
                    return _buildTestCaseItem(test, theme);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run All Tests'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🧪 Running tests...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestCaseItem(TestCase test, FormTheme theme) {
    final resultColor = test.expectedResult == TestResult.success ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        children: [
          Icon(
            test.expectedResult == TestResult.success ? Icons.check_circle : Icons.error,
            color: resultColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.name,
                  style: TextStyle(color: theme.colors.text, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Input: "${test.input}"',
                  style: TextStyle(color: theme.colors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    final theme = ref.read(themeManagerProvider);

    // Mock analytics data
    final analytics = FormAnalytics(
      totalSubmissions: 1523,
      successfulSubmissions: 1401,
      failedSubmissions: 122,
      averageCompletionTime: 45.3,
      fieldErrors: {
        'email': 67,
        'phone': 34,
        'password': 21,
      },
      fieldCompletionRate: {
        'name': 0.98,
        'email': 0.95,
        'phone': 0.87,
        'message': 0.92,
      },
      dropOffPoints: [
        DropOffPoint(
          fieldId: 'phone',
          fieldLabel: 'Phone Number',
          dropOffCount: 87,
          dropOffRate: 0.057,
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.analytics, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Form Analytics', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview stats
                Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      theme,
                      'Total Submissions',
                      '${analytics.totalSubmissions}',
                      Icons.send,
                      Colors.blue,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(
                      theme,
                      'Success Rate',
                      '${((analytics.successfulSubmissions / analytics.totalSubmissions) * 100).toStringAsFixed(1)}%',
                      Icons.check_circle,
                      Colors.green,
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatCard(
                      theme,
                      'Avg. Time',
                      '${analytics.averageCompletionTime.toStringAsFixed(1)}s',
                      Icons.timer,
                      Colors.orange,
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(
                      theme,
                      'Failed',
                      '${analytics.failedSubmissions}',
                      Icons.error,
                      Colors.red,
                    )),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Field errors
                Text(
                  'Field Errors',
                  style: TextStyle(
                    color: theme.colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...analytics.fieldErrors.entries.map((entry) {
                  return _buildErrorBar(theme, entry.key, entry.value, analytics.totalSubmissions);
                }),
                
                const SizedBox(height: 24),
                
                // Completion rates
                Text(
                  'Field Completion Rates',
                  style: TextStyle(
                    color: theme.colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...analytics.fieldCompletionRate.entries.map((entry) {
                  return _buildCompletionBar(theme, entry.key, entry.value);
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Export Report'),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📊 Exporting analytics report...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(FormTheme theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: theme.colors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: theme.colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBar(FormTheme theme, String fieldName, int errors, int total) {
    final percentage = (errors / total) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fieldName,
                  style: TextStyle(color: theme.colors.text, fontSize: 13),
                ),
              ),
              Text(
                '$errors errors (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: theme.colors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBar(FormTheme theme, String fieldName, double rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fieldName,
                  style: TextStyle(color: theme.colors.text, fontSize: 13),
                ),
              ),
              Text(
                '${(rate * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: rate,
            backgroundColor: theme.colors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  void _showVersionHistory() {
    final theme = ref.read(themeManagerProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.history, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Version History', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: const SizedBox(
          width: 500,
          height: 400,
          child: Center(
            child: Text('Version history feature - Manage form versions here'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Version'),
            onPressed: () {
              // Create new version
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    final theme = ref.read(themeManagerProvider);
    final fields = ref.read(formFieldsProvider);
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colors.surface,
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility, color: theme.colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Form Preview',
                    style: TextStyle(
                      color: theme.colors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colors.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colors.border),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: fields.map((field) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (field.label != null) ...[
                                Text(
                                  field.label!,
                                  style: TextStyle(
                                    color: theme.colors.text,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              TextField(
                                style: TextStyle(color: theme.colors.text),
                                decoration: InputDecoration(
                                  hintText: field.hint,
                                  hintStyle: TextStyle(color: theme.colors.textSecondary),
                                  filled: true,
                                  fillColor: theme.colors.inputBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: theme.colors.border),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 Form saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deployForm() {
    final theme = ref.read(themeManagerProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.rocket_launch, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Deploy Form', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: const Text('Choose deployment option:'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Deploy to Cloud'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🚀 Deploying to cloud...')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// COMPLETE COMPONENT PALETTE
// ============================================================================

class CompleteComponentPalette extends ConsumerWidget {
  final FormTheme theme;
  final int phase;

  const CompleteComponentPalette({
    Key? key,
    required this.theme,
    required this.phase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 280,
      color: theme.colors.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'COMPONENTS - PHASE ${phase + 1}',
            style: TextStyle(
              color: theme.colors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (phase == 0) ..._buildPhase1Components(ref),
          if (phase == 1) ..._buildPhase2Components(ref),
          if (phase == 2) ..._buildPhase3Components(ref),
          if (phase == 3) ..._buildPhase4Components(ref),
        ],
      ),
    );
  }

  List<Widget> _buildPhase1Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Basic Inputs'),
      _ComponentButton(theme: theme, label: 'Text Input', icon: Icons.text_fields, onTap: () => _addField(ref, 'text', 'Text Input')),
      _ComponentButton(theme: theme, label: 'Email', icon: Icons.email, onTap: () => _addField(ref, 'email', 'Email')),
      _ComponentButton(theme: theme, label: 'Number', icon: Icons.numbers, onTap: () => _addField(ref, 'number', 'Number')),
      _ComponentButton(theme: theme, label: 'Password', icon: Icons.lock, onTap: () => _addField(ref, 'password', 'Password')),
      _ComponentButton(theme: theme, label: 'Textarea', icon: Icons.notes, onTap: () => _addField(ref, 'textarea', 'Message')),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Selection'),
      _ComponentButton(theme: theme, label: 'Dropdown', icon: Icons.arrow_drop_down_circle, onTap: () => _addField(ref, 'select', 'Select Option')),
      _ComponentButton(theme: theme, label: 'Checkbox', icon: Icons.check_box, onTap: () => _addField(ref, 'checkbox', 'Agree to terms')),
      _ComponentButton(theme: theme, label: 'Radio Group', icon: Icons.radio_button_checked, onTap: () => _addField(ref, 'radio', 'Choose one')),
      _ComponentButton(theme: theme, label: 'Switch', icon: Icons.toggle_on, onTap: () => _addField(ref, 'switch', 'Enable feature')),
    ];
  }

  List<Widget> _buildPhase2Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Layout Components'),
      _ComponentButton(theme: theme, label: 'Container', icon: Icons.crop_square, onTap: () => _addField(ref, 'container', null, isContainer: true)),
      _ComponentButton(theme: theme, label: 'Row', icon: Icons.view_week, onTap: () => _addField(ref, 'row', null, isContainer: true)),
      _ComponentButton(theme: theme, label: 'Column', icon: Icons.view_agenda, onTap: () => _addField(ref, 'column', null, isContainer: true)),
      _ComponentButton(theme: theme, label: 'Grid', icon: Icons.grid_on, onTap: () => _addField(ref, 'grid', null, isContainer: true)),
      _ComponentButton(theme: theme, label: 'Card', icon: Icons.credit_card, onTap: () => _addField(ref, 'card', null, isContainer: true)),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Advanced Layouts'),
      _ComponentButton(theme: theme, label: 'Tabs', icon: Icons.tab, onTap: () => _addField(ref, 'tabs', null, isContainer: true)),
      _ComponentButton(theme: theme, label: 'Stepper', icon: Icons.stairs, onTap: () => _addField(ref, 'stepper', null, isContainer: true)),
      _ComponentButton(theme: theme, label: 'Accordion', icon: Icons.expand_more, onTap: () => _addField(ref, 'accordion', null, isContainer: true)),
    ];
  }

  List<Widget> _buildPhase3Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Advanced Fields'),
      _ComponentButton(theme: theme, label: 'Date Picker', icon: Icons.calendar_today, onTap: () => _addField(ref, 'date', 'Select Date')),
      _ComponentButton(theme: theme, label: 'Time Picker', icon: Icons.access_time, onTap: () => _addField(ref, 'time', 'Select Time')),
      _ComponentButton(theme: theme, label: 'Date Range', icon: Icons.date_range, onTap: () => _addField(ref, 'daterange', 'Select Range')),
      _ComponentButton(theme: theme, label: 'File Upload', icon: Icons.upload_file, onTap: () => _addField(ref, 'file', 'Upload File')),
      _ComponentButton(theme: theme, label: 'Image Upload', icon: Icons.image, onTap: () => _addField(ref, 'image', 'Upload Image')),
      _ComponentButton(theme: theme, label: 'Signature', icon: Icons.gesture, onTap: () => _addField(ref, 'signature', 'Sign Here')),
      _ComponentButton(theme: theme, label: 'Rating', icon: Icons.star, onTap: () => _addField(ref, 'rating', 'Rate this')),
      _ComponentButton(theme: theme, label: 'Slider', icon: Icons.tune, onTap: () => _addField(ref, 'slider', 'Adjust value')),
      _ComponentButton(theme: theme, label: 'Color Picker', icon: Icons.color_lens, onTap: () => _addField(ref, 'color', 'Pick Color')),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Special Fields'),
      _ComponentButton(theme: theme, label: 'Rich Text Editor', icon: Icons.text_format, onTap: () => _addField(ref, 'richtext', 'Content')),
      _ComponentButton(theme: theme, label: 'Location', icon: Icons.location_on, onTap: () => _addField(ref, 'location', 'Enter Location')),
      _ComponentButton(theme: theme, label: 'QR Code', icon: Icons.qr_code, onTap: () => _addField(ref, 'qrcode', 'Scan QR')),
    ];
  }

  List<Widget> _buildPhase4Components(WidgetRef ref) {
    return [
      _ComponentCategory(theme: theme, title: 'Integration Components'),
      _ComponentButton(theme: theme, label: 'API Field', icon: Icons.api, onTap: () {}),
      _ComponentButton(theme: theme, label: 'Webhook Trigger', icon: Icons.webhook, onTap: () {}),
      _ComponentButton(theme: theme, label: 'Payment Gateway', icon: Icons.payment, onTap: () {}),
      _ComponentButton(theme: theme, label: 'reCAPTCHA', icon: Icons.verified_user, onTap: () {}),
      const SizedBox(height: 16),
      _ComponentCategory(theme: theme, title: 'Templates'),
      _ComponentButton(theme: theme, label: 'Contact Form', icon: Icons.contact_mail, onTap: () => _loadTemplate(ref, 'contact_form')),
      _ComponentButton(theme: theme, label: 'Registration', icon: Icons.person_add, onTap: () => _loadTemplate(ref, 'registration')),
      _ComponentButton(theme: theme, label: 'Survey', icon: Icons.poll, onTap: () {}),
      _ComponentButton(theme: theme, label: 'Feedback', icon: Icons.feedback, onTap: () {}),
    ];
  }

  void _addField(WidgetRef ref, String type, String? label, {bool isContainer = false}) {
    final field = FieldConfig(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      name: isContainer ? null : '${type}_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      hint: label != null ? 'Enter $label' : null,
      children: isContainer ? [] : null,
    );
    ref.read(formFieldsProvider.notifier).addField(field);
  }

  void _loadTemplate(WidgetRef ref, String templateId) {
    final template = TemplateLibrary.predefined.firstWhere((t) => t.id == templateId);
    ref.read(formFieldsProvider.notifier).clear();
    for (final field in template.fields) {
      ref.read(formFieldsProvider.notifier).addField(field);
    }
  }
}

class _ComponentCategory extends StatelessWidget {
  final FormTheme theme;
  final String title;

  const _ComponentCategory({required this.theme, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: theme.colors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _ComponentButton extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ComponentButton({
    required this.theme,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colors.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: theme.colors.text, fontSize: 13),
              ),
            ),
            Icon(Icons.add, size: 16, color: theme.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// COMPLETE PROPERTIES PANEL
// ============================================================================

class CompletePropertiesPanel extends ConsumerWidget {
  final FormTheme theme;
  final int phase;

  const CompletePropertiesPanel({
    Key? key,
    required this.theme,
    required this.phase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedField = ref.watch(selectedFieldProvider);

    return Container(
      width: 320,
      color: theme.colors.surface,
      child: selectedField == null
          ? _buildEmptyState()
          : _buildPropertiesContent(selectedField, ref),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 60, color: theme.colors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Select a field to edit',
            style: TextStyle(color: theme.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesContent(FieldConfig field, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.settings, color: theme.colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Properties',
              style: TextStyle(
                color: theme.colors.text,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Basic properties
        _PropertyField(
          theme: theme,
          label: 'Label',
          value: field.label ?? '',
          onChanged: (value) {
            ref.read(formFieldsProvider.notifier).updateField(
              field.id,
              field.copyWith(label: value),
            );
          },
        ),
        const SizedBox(height: 16),

        _PropertyField(
          theme: theme,
          label: 'Name',
          value: field.name ?? '',
          onChanged: (value) {
            ref.read(formFieldsProvider.notifier).updateField(
              field.id,
              field.copyWith(name: value),
            );
          },
        ),
        const SizedBox(height: 16),

        _PropertyField(
          theme: theme,
          label: 'Placeholder',
          value: field.hint ?? '',
          onChanged: (value) {
            ref.read(formFieldsProvider.notifier).updateField(
              field.id,
              field.copyWith(hint: value),
            );
          },
        ),
        const SizedBox(height: 16),

        // Required toggle
        _PropertyToggle(
          theme: theme,
          label: 'Required',
          value: field.required,
          onChanged: (value) {
            ref.read(formFieldsProvider.notifier).updateField(
              field.id,
              field.copyWith(required: value),
            );
          },
        ),
        const SizedBox(height: 24),

        // Phase-specific properties
        if (phase == 2) ..._buildAdvancedProperties(field, ref),
        if (phase == 3) ..._buildIntegrationProperties(field, ref),

        // Actions
        const Divider(),
        const SizedBox(height: 16),
        
        ElevatedButton.icon(
          icon: const Icon(Icons.content_copy, size: 18),
          label: const Text('Duplicate Field'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colors.primary,
          ),
          onPressed: () {
            ref.read(formFieldsProvider.notifier).duplicateField(field);
          },
        ),
        const SizedBox(height: 8),
        
        OutlinedButton.icon(
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Delete Field'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: () {
            ref.read(formFieldsProvider.notifier).deleteField(field.id);
            ref.read(selectedFieldProvider.notifier).state = null;
          },
        ),
      ],
    );
  }

  List<Widget> _buildAdvancedProperties(FieldConfig field, WidgetRef ref) {
    return [
      Text(
        'Validation Rules',
        style: TextStyle(
          color: theme.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 12),
      _ValidationRuleItem(
        theme: theme,
        label: 'Min Length',
        onTap: () {},
      ),
      _ValidationRuleItem(
        theme: theme,
        label: 'Max Length',
        onTap: () {},
      ),
      _ValidationRuleItem(
        theme: theme,
        label: 'Pattern (Regex)',
        onTap: () {},
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.add, size: 16),
        label: const Text('Add Validation Rule'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colors.primary,
          side: BorderSide(color: theme.colors.primary),
        ),
        onPressed: () {},
      ),
      const SizedBox(height: 24),
      
      Text(
        'Conditional Logic',
        style: TextStyle(
          color: theme.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        icon: const Icon(Icons.rule, size: 16),
        label: const Text('Add Condition'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colors.primary,
          side: BorderSide(color: theme.colors.primary),
        ),
        onPressed: () {},
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildIntegrationProperties(FieldConfig field, WidgetRef ref) {
    return [
      Text(
        'API Integration',
        style: TextStyle(
          color: theme.colors.text,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 12),
      _PropertyField(
        theme: theme,
        label: 'Endpoint URL',
        value: '',
        onChanged: (value) {},
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        icon: const Icon(Icons.link, size: 16),
        label: const Text('Configure API'),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colors.primary,
          side: BorderSide(color: theme.colors.primary),
        ),
        onPressed: () {},
      ),
      const SizedBox(height: 24),
    ];
  }
}

class _PropertyField extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final String value;
  final Function(String) onChanged;

  const _PropertyField({
    required this.theme,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colors.text,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          style: TextStyle(color: theme.colors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: theme.colors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PropertyToggle extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final bool value;
  final Function(bool) onChanged;

  const _PropertyToggle({
    required this.theme,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.colors.text,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colors.primary,
        ),
      ],
    );
  }
}

class _ValidationRuleItem extends StatelessWidget {
  final FormTheme theme;
  final String label;
  final VoidCallback onTap;

  const _ValidationRuleItem({
    required this.theme,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colors.inputBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: theme.colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, size: 16, color: theme.colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: theme.colors.text, fontSize: 13),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: theme.colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN APP ENTRY
// ============================================================================

void main() {
  runApp(
    const ProviderScope(
      child: MaterialApp(
        title: 'Form Builder - Complete (Phase 1-4)',
        debugShowCheckedModeBanner: false,
        home: CompleteFormBuilderDesigner(),
      ),
    ),
  );
}