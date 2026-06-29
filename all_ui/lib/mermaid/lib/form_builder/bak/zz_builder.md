import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// Note: Add to pubspec.yaml:
// dependencies:
//   cel_dart: ^0.1.0  # Pure Dart CEL implementation

// ============================================================================
// CEL EXPRESSION EVALUATOR
// ============================================================================

/// CEL Expression Evaluator for form conditions
class CelExpressionEvaluator {
  final Map<String, dynamic> context;

  CelExpressionEvaluator(this.context);

  /// Evaluates a CEL expression against the current context
  /// Examples:
  ///   - "age >= 18"
  ///   - "country == 'USA' && state != ''"
  ///   - "items.size() > 0"
  ///   - "email.matches('[a-z]+@[a-z]+\\.[a-z]+')"
  bool evaluate(String expression) {
    try {
      // For production, use: import 'package:cel_dart/cel_dart.dart';
      // final program = Cel.compile(expression);
      // final result = program.eval(context);
      // return result as bool;

      // Fallback: Simple expression parser
      return _evaluateSimpleExpression(expression);
    } catch (e) {
      print('CEL evaluation error: $e');
      return false;
    }
  }

  /// Simple expression evaluator (fallback when CEL package not available)
  /// Supports: ==, !=, >, <, >=, <=, &&, ||, in, contains, matches, size()
  bool _evaluateSimpleExpression(String expression) {
    expression = expression.trim();

    // Handle logical operators
    if (expression.contains('&&')) {
      final parts = expression.split('&&');
      return parts.every((part) => _evaluateSimpleExpression(part.trim()));
    }

    if (expression.contains('||')) {
      final parts = expression.split('||');
      return parts.any((part) => _evaluateSimpleExpression(part.trim()));
    }

    // Handle 'in' operator: "value in ['a', 'b', 'c']"
    if (expression.contains(' in ')) {
      final parts = expression.split(' in ');
      if (parts.length == 2) {
        final value = _resolveValue(parts[0].trim());
        final list = _parseList(parts[1].trim());
        return list.contains(value);
      }
    }

    // Handle 'has' operator: "data.has(field)"
    if (expression.contains('.has(')) {
      final match = RegExp(r'(\w+)\.has\(([^)]+)\)').firstMatch(expression);
      if (match != null) {
        final objName = match.group(1);
        final fieldName = match
            .group(2)
            ?.replaceAll("'", '')
            .replaceAll('"', '');
        if (objName == 'data' && fieldName != null) {
          return context.containsKey(fieldName) && context[fieldName] != null;
        }
      }
    }

    // Handle 'size()' function: "items.size() > 0"
    if (expression.contains('.size()')) {
      final match = RegExp(
        r'(\w+)\.size\(\)\s*([><=!]+)\s*(\d+)',
      ).firstMatch(expression);
      if (match != null) {
        final varName = match.group(1);
        final operator = match.group(2);
        final compareValue = int.parse(match.group(3)!);

        final value = context[varName];
        if (value is List) {
          return _compareNumbers(value.length, operator!, compareValue);
        } else if (value is String) {
          return _compareNumbers(value.length, operator!, compareValue);
        }
      }
    }

    // Handle 'matches()' function: "email.matches('[a-z]+@[a-z]+')"
    if (expression.contains('.matches(')) {
      final match = RegExp(
        r'''(\w+)\.matches\(["\'](.+)["\']\)''',
      ).firstMatch(expression);
      if (match != null) {
        final varName = match.group(1);
        final pattern = match.group(2);
        final value = context[varName]?.toString() ?? '';
        return RegExp(pattern!).hasMatch(value);
      }
    }

    // Handle 'startsWith()' and 'endsWith()'
    if (expression.contains('.startsWith(')) {
      final match = RegExp(
        r'''(\w+)\.startsWith\(["\'](.+)["\']\)''',
      ).firstMatch(expression);
      if (match != null) {
        final varName = match.group(1);
        final prefix = match.group(2);
        final value = context[varName]?.toString() ?? '';
        return value.startsWith(prefix!);
      }
    }

    if (expression.contains('.endsWith(')) {
      final match = RegExp(
        r'''(\w+)\.endsWith\(["\'](.+)["\']\)''',
      ).firstMatch(expression);
      if (match != null) {
        final varName = match.group(1);
        final suffix = match.group(2);
        final value = context[varName]?.toString() ?? '';
        return value.endsWith(suffix!);
      }
    }

    // Handle 'contains()' function: "name.contains('John')"
    if (expression.contains('.contains(')) {
      final match = RegExp(
        r'''(\w+)\.contains\(["\'](.+)["\']\)''',
      ).firstMatch(expression);
      if (match != null) {
        final varName = match.group(1);
        final searchValue = match.group(2);
        final value = context[varName]?.toString() ?? '';
        return value.contains(searchValue!);
      }
    }

    // Handle comparison operators
    for (final op in ['==', '!=', '>=', '<=', '>', '<']) {
      if (expression.contains(op)) {
        final parts = expression.split(op);
        if (parts.length == 2) {
          final left = _resolveValue(parts[0].trim());
          final right = _resolveValue(parts[1].trim());
          return _compare(left, op, right);
        }
      }
    }

    // Handle boolean literals
    if (expression == 'true') return true;
    if (expression == 'false') return false;

    // Try to resolve as variable
    final value = _resolveValue(expression);
    if (value is bool) return value;

    // Default: check if variable exists and is truthy
    return value != null &&
        value.toString().isNotEmpty &&
        value.toString() != 'false';
  }

  dynamic _resolveValue(String expr) {
    expr = expr.trim();

    // String literal
    if ((expr.startsWith("'") && expr.endsWith("'")) ||
        (expr.startsWith('"') && expr.endsWith('"'))) {
      return expr.substring(1, expr.length - 1);
    }

    // Number literal
    final numValue = num.tryParse(expr);
    if (numValue != null) return numValue;

    // Boolean literal
    if (expr == 'true') return true;
    if (expr == 'false') return false;

    // Null literal
    if (expr == 'null') return null;

    // Variable reference
    return context[expr];
  }

  List<dynamic> _parseList(String listStr) {
    listStr = listStr.trim();
    if (listStr.startsWith('[') && listStr.endsWith(']')) {
      listStr = listStr.substring(1, listStr.length - 1);
      return listStr.split(',').map((item) {
        item = item.trim();
        if (item.startsWith("'") || item.startsWith('"')) {
          return item.substring(1, item.length - 1);
        }
        return num.tryParse(item) ?? item;
      }).toList();
    }
    return [];
  }

  bool _compare(dynamic left, String operator, dynamic right) {
    switch (operator) {
      case '==':
        return left == right;
      case '!=':
        return left != right;
      case '>':
        if (left is num && right is num) return left > right;
        return false;
      case '<':
        if (left is num && right is num) return left < right;
        return false;
      case '>=':
        if (left is num && right is num) return left >= right;
        return false;
      case '<=':
        if (left is num && right is num) return left <= right;
        return false;
      default:
        return false;
    }
  }

  bool _compareNumbers(num left, String operator, num right) {
    switch (operator) {
      case '>':
        return left > right;
      case '<':
        return left < right;
      case '>=':
        return left >= right;
      case '<=':
        return left <= right;
      case '==':
        return left == right;
      case '!=':
        return left != right;
      default:
        return false;
    }
  }
}

// ============================================================================
// ABSTRACT FIELD RENDERER
// ============================================================================

abstract class FormFieldRenderer {
  Widget render(
    BuildContext context,
    Map<String, dynamic> field,
    dynamic value,
    Function(dynamic) onChanged,
    String? Function(dynamic)? validator,
    bool enabled,
  );

  List<String> get supportedTypes;
}

// ============================================================================
// FORM FIELD THEME
// ============================================================================

class FormFieldTheme {
  final Color backgroundColor;
  final Color fillColor;
  final Color textColor;
  final Color labelColor;
  final Color hintColor;
  final Color borderColor;
  final Color errorColor;
  final Color primaryColor;
  final double borderRadius;
  final EdgeInsets fieldPadding;

  const FormFieldTheme({
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.fillColor = const Color(0xFF2D2D2D),
    this.textColor = Colors.white,
    this.labelColor = const Color(0xFFB0B0B0),
    this.hintColor = const Color(0xFF808080),
    this.borderColor = const Color(0xFF3D3D3D),
    this.errorColor = Colors.red,
    this.primaryColor = Colors.blue,
    this.borderRadius = 8.0,
    this.fieldPadding = const EdgeInsets.only(bottom: 16),
  });
}

// ============================================================================
// CONFIGURABLE FORM BUILDER WITH CEL SUPPORT
// ============================================================================

class ConfigurableFormBuilder extends StatefulWidget {
  final List<Map<String, dynamic>> fields;
  final Map<String, dynamic> initialValues;
  final Function(Map<String, dynamic>) onChanged;
  final List<Map<String, dynamic>>? actions;
  final Function(String actionId, Map<String, dynamic> formData)? onAction;
  final Function(String fieldName, dynamic value)? onFieldChanged;
  final Map<String, FormFieldRenderer>? customRenderers;
  final FormFieldTheme? theme;
  final bool enableAutoSave;
  final Duration? autoSaveDelay;
  final Function(Map<String, dynamic>)? onAutoSave;
  final bool useCelExpressions;

  const ConfigurableFormBuilder({
    Key? key,
    required this.fields,
    required this.initialValues,
    required this.onChanged,
    this.actions,
    this.onAction,
    this.onFieldChanged,
    this.customRenderers,
    this.theme,
    this.enableAutoSave = false,
    this.autoSaveDelay = const Duration(seconds: 2),
    this.onAutoSave,
    this.useCelExpressions = true,
  }) : super(key: key);

  @override
  State<ConfigurableFormBuilder> createState() =>
      _ConfigurableFormBuilderState();
}

class _ConfigurableFormBuilderState extends State<ConfigurableFormBuilder> {
  late Map<String, dynamic> _formData;
  late Map<String, TextEditingController> _controllers;
  late Map<String, FocusNode> _focusNodes;
  late Map<String, FormFieldRenderer> _renderers;
  late FormFieldTheme _theme;
  final _formKey = GlobalKey<FormState>();
  Timer? _autoSaveTimer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.initialValues);
    _controllers = {};
    _focusNodes = {};
    _theme = widget.theme ?? const FormFieldTheme();
    _renderers = widget.customRenderers ?? {};

    for (var field in widget.fields) {
      final name = field['name'] as String?;
      if (name == null) continue;

      final type = field['type'] as String;
      if ([
        'text',
        'textarea',
        'number',
        'email',
        'password',
        'url',
        'tel',
        'search',
      ].contains(type)) {
        _controllers[name] = TextEditingController(
          text:
              _formData[name]?.toString() ??
              field['defaultValue']?.toString() ??
              '',
        );
        _focusNodes[name] = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  /// Evaluates CEL expression or fallback to simple condition
  bool _evaluateCondition(dynamic condition) {
    if (condition == null) return true;

    // CEL expression (string)
    if (condition is String && widget.useCelExpressions) {
      final evaluator = CelExpressionEvaluator({
        ..._formData,
        'data': _formData, // Allow 'data.field' syntax
      });
      return evaluator.evaluate(condition);
    }

    // Legacy map-based condition (backward compatible)
    if (condition is Map<String, dynamic>) {
      return _evaluateLegacyCondition(condition);
    }

    return true;
  }

  /// Legacy condition evaluator (backward compatible)
  bool _evaluateLegacyCondition(Map<String, dynamic> condition) {
    final field = condition['field'] as String;
    final operator = condition['operator'] as String;
    final value = condition['value'];
    final fieldValue = _formData[field];

    switch (operator) {
      case '==':
        return fieldValue == value;
      case '!=':
        return fieldValue != value;
      case '>':
        return (fieldValue is num) && fieldValue > (value as num);
      case '<':
        return (fieldValue is num) && fieldValue < (value as num);
      case '>=':
        return (fieldValue is num) && fieldValue >= (value as num);
      case '<=':
        return (fieldValue is num) && fieldValue <= (value as num);
      case 'contains':
        return fieldValue?.toString().contains(value.toString()) ?? false;
      case 'in':
        return (value as List).contains(fieldValue);
      case 'notIn':
        return !(value as List).contains(fieldValue);
      case 'isEmpty':
        return fieldValue == null || fieldValue.toString().isEmpty;
      case 'isNotEmpty':
        return fieldValue != null && fieldValue.toString().isNotEmpty;
      default:
        return true;
    }
  }

  String? _validateField(Map<String, dynamic> field, dynamic value) {
    final required = field['required'] as bool? ?? false;
    final validation = field['validation'] as Map<String, dynamic>?;

    // CEL-based conditional requirement
    final requiredCondition = field['requiredIf'];
    final isConditionallyRequired = _evaluateCondition(requiredCondition);

    if ((required || isConditionallyRequired) &&
        (value == null || value.toString().isEmpty)) {
      return field['errorMessage'] as String? ?? 'This field is required';
    }

    // CEL-based custom validation
    if (validation?['cel'] != null &&
        value != null &&
        value.toString().isNotEmpty) {
      final celExpression = validation!['cel'] as String;
      final evaluator = CelExpressionEvaluator({'value': value, ..._formData});

      if (!evaluator.evaluate(celExpression)) {
        return validation['celErrorMessage'] as String? ?? 'Validation failed';
      }
    }

    if (validation != null && value != null && value.toString().isNotEmpty) {
      if (validation['minLength'] != null &&
          value.toString().length < validation['minLength']) {
        return 'Minimum ${validation['minLength']} characters required';
      }
      if (validation['maxLength'] != null &&
          value.toString().length > validation['maxLength']) {
        return 'Maximum ${validation['maxLength']} characters allowed';
      }
      if (validation['min'] != null &&
          value is num &&
          value < validation['min']) {
        return 'Minimum value is ${validation['min']}';
      }
      if (validation['max'] != null &&
          value is num &&
          value > validation['max']) {
        return 'Maximum value is ${validation['max']}';
      }
      if (validation['pattern'] != null) {
        final pattern = RegExp(validation['pattern'] as String);
        if (!pattern.hasMatch(value.toString())) {
          return validation['patternMessage'] as String? ?? 'Invalid format';
        }
      }
    }

    return null;
  }

  void _updateField(String name, dynamic value) {
    setState(() {
      _formData[name] = value;
    });

    widget.onChanged(_formData);
    widget.onFieldChanged?.call(name, value);

    if (widget.enableAutoSave) {
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer(widget.autoSaveDelay!, () {
        widget.onAutoSave?.call(_formData);
      });
    }
  }

  Future<void> _handleAction(String actionId) async {
    final action = widget.actions?.firstWhere((a) => a['id'] == actionId);
    final requiresValidation = action?['requiresValidation'] as bool? ?? true;

    // CEL-based action condition
    final actionCondition = action?['condition'];
    if (actionCondition != null && !_evaluateCondition(actionCondition)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              action?['conditionErrorMessage'] ?? 'Action not available',
            ),
          ),
        );
      }
      return;
    }

    if (requiresValidation) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _isSubmitting = true);
        try {
          await widget.onAction?.call(actionId, _formData);
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
      }
    } else {
      widget.onAction?.call(actionId, _formData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.fields.map((field) {
            // CEL-based visibility
            final visibleCondition = field['visibleIf'];
            final isVisible = _evaluateCondition(visibleCondition);

            if (!isVisible) return const SizedBox.shrink();

            return _buildFormField(field);
          }),
          if (widget.actions != null && widget.actions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    final type = field['type'] as String;
    final name = field['name'] as String?;

    if (type == 'section') return _buildSectionHeader(field);
    if (type == 'divider') return _buildDivider(field);
    if (type == 'html') return _buildHtmlField(field);

    if (name == null) return const SizedBox.shrink();

    final value = _formData[name];

    // CEL-based enabled condition
    final enabledCondition = field['enabledIf'];
    final enabled = _evaluateCondition(enabledCondition);

    // Check custom renderer
    if (_renderers.containsKey(type)) {
      return _renderers[type]!.render(
        context,
        field,
        value,
        (newValue) => _updateField(name, newValue),
        (val) => _validateField(field, val),
        enabled,
      );
    }

    return _buildBuiltInField(field, name, value, enabled);
  }

  Widget _buildBuiltInField(
    Map<String, dynamic> field,
    String name,
    dynamic value,
    bool enabled,
  ) {
    final type = field['type'] as String;
    final label = field['label'] as String? ?? name;
    final hint = field['hint'] as String?;

    switch (type) {
      case 'text':
      case 'email':
      case 'password':
      case 'url':
      case 'tel':
        return _buildTextField(field, name, label, hint, enabled);
      case 'number':
        return _buildNumberField(field, name, label, hint, enabled);
      case 'textarea':
        return _buildTextAreaField(field, name, label, hint, enabled);
      case 'select':
      case 'dropdown':
        return _buildDropdownField(field, name, label, hint, enabled);
      case 'checkbox':
        return _buildCheckboxField(field, name, label, enabled);
      case 'switch':
        return _buildSwitchField(field, name, label, enabled);
      case 'slider':
        return _buildSliderField(field, name, label, enabled);
      case 'radio':
        return _buildRadioField(field, name, label, enabled);
      case 'chips':
        return _buildChipsField(field, name, label, enabled);
      case 'date':
        return _buildDateField(field, name, label, hint, enabled);
      default:
        return _buildTextField(field, name, label, hint, enabled);
    }
  }

  // Simplified field builders

  Widget _buildTextField(
    Map<String, dynamic> field,
    String name,
    String label,
    String? hint,
    bool enabled,
  ) {
    final type = field['type'] as String? ?? 'text';
    final obscureText = type == 'password';

    return Padding(
      padding: _theme.fieldPadding,
      child: TextFormField(
        controller: _controllers[name],
        obscureText: obscureText,
        style: TextStyle(color: _theme.textColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: _theme.labelColor),
          filled: true,
          fillColor: _theme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_theme.borderRadius),
          ),
          prefixIcon: field['prefixIcon'] != null
              ? Icon(field['prefixIcon'] as IconData, color: _theme.labelColor)
              : null,
        ),
        validator: (val) => _validateField(field, val),
        enabled: enabled,
        onChanged: (value) => _updateField(name, value),
      ),
    );
  }

  Widget _buildNumberField(
    Map<String, dynamic> field,
    String name,
    String label,
    String? hint,
    bool enabled,
  ) {
    return Padding(
      padding: _theme.fieldPadding,
      child: TextFormField(
        controller: _controllers[name],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: _theme.textColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: _theme.labelColor),
          filled: true,
          fillColor: _theme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_theme.borderRadius),
          ),
        ),
        validator: (val) => _validateField(
          field,
          val != null && val.isNotEmpty ? num.tryParse(val) : null,
        ),
        enabled: enabled,
        onChanged: (value) {
          final parsed = num.tryParse(value);
          if (parsed != null || value.isEmpty) _updateField(name, parsed);
        },
      ),
    );
  }

  Widget _buildTextAreaField(
    Map<String, dynamic> field,
    String name,
    String label,
    String? hint,
    bool enabled,
  ) {
    return Padding(
      padding: _theme.fieldPadding,
      child: TextFormField(
        controller: _controllers[name],
        maxLines: field['maxLines'] as int? ?? 4,
        style: TextStyle(color: _theme.textColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: _theme.labelColor),
          filled: true,
          fillColor: _theme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_theme.borderRadius),
          ),
        ),
        validator: (val) => _validateField(field, val),
        enabled: enabled,
        onChanged: (value) => _updateField(name, value),
      ),
    );
  }

  Widget _buildDropdownField(
    Map<String, dynamic> field,
    String name,
    String label,
    String? hint,
    bool enabled,
  ) {
    final options = field['options'] as List;
    final value = _formData[name];

    return Padding(
      padding: _theme.fieldPadding,
      child: DropdownButtonFormField<String>(
        value: value?.toString(),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: _theme.labelColor),
          filled: true,
          fillColor: _theme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_theme.borderRadius),
          ),
        ),
        dropdownColor: _theme.fillColor,
        style: TextStyle(color: _theme.textColor),
        validator: (val) => _validateField(field, val),
        items: options.map((option) {
          final optionValue = option is Map
              ? option['value'].toString()
              : option.toString();
          final optionLabel = option is Map
              ? option['label'].toString()
              : option.toString();
          return DropdownMenuItem(value: optionValue, child: Text(optionLabel));
        }).toList(),
        onChanged: enabled ? (val) => _updateField(name, val) : null,
      ),
    );
  }

  Widget _buildCheckboxField(
    Map<String, dynamic> field,
    String name,
    String label,
    bool enabled,
  ) {
    final value = _formData[name] as bool? ?? false;
    return Padding(
      padding: _theme.fieldPadding,
      child: CheckboxListTile(
        title: Text(label, style: TextStyle(color: _theme.textColor)),
        value: value,
        onChanged: enabled ? (val) => _updateField(name, val ?? false) : null,
        activeColor: _theme.primaryColor,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSwitchField(
    Map<String, dynamic> field,
    String name,
    String label,
    bool enabled,
  ) {
    final value = _formData[name] as bool? ?? false;
    return Padding(
      padding: _theme.fieldPadding,
      child: SwitchListTile(
        title: Text(label, style: TextStyle(color: _theme.textColor)),
        value: value,
        onChanged: enabled ? (val) => _updateField(name, val) : null,
        activeColor: _theme.primaryColor,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSliderField(
    Map<String, dynamic> field,
    String name,
    String label,
    bool enabled,
  ) {
    final value = (_formData[name] as num? ?? field['defaultValue'] ?? 0)
        .toDouble();
    final min = (field['min'] as num? ?? 0).toDouble();
    final max = (field['max'] as num? ?? 100).toDouble();

    return Padding(
      padding: _theme.fieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: _theme.labelColor, fontSize: 16),
              ),
              Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: _theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: enabled ? (val) => _updateField(name, val) : null,
            activeColor: _theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioField(
    Map<String, dynamic> field,
    String name,
    String label,
    bool enabled,
  ) {
    final options = field['options'] as List;
    final value = _formData[name];

    return Padding(
      padding: _theme.fieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: _theme.labelColor, fontSize: 16)),
          ...options.map((option) {
            final optionValue = option is Map
                ? option['value'].toString()
                : option.toString();
            final optionLabel = option is Map
                ? option['label'].toString()
                : option.toString();
            return RadioListTile<String>(
              title: Text(
                optionLabel,
                style: TextStyle(color: _theme.textColor),
              ),
              value: optionValue,
              groupValue: value?.toString(),
              onChanged: enabled ? (val) => _updateField(name, val) : null,
              activeColor: _theme.primaryColor,
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChipsField(
    Map<String, dynamic> field,
    String name,
    String label,
    bool enabled,
  ) {
    final options = field['options'] as List;
    final selectedValues =
        (_formData[name] as List?)?.map((e) => e.toString()).toList() ?? [];

    return Padding(
      padding: _theme.fieldPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: _theme.labelColor, fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final optionValue = option is Map
                  ? option['value'].toString()
                  : option.toString();
              final optionLabel = option is Map
                  ? option['label'].toString()
                  : option.toString();
              final isSelected = selectedValues.contains(optionValue);
              return FilterChip(
                label: Text(optionLabel),
                selected: isSelected,
                onSelected: enabled
                    ? (selected) {
                        final newList = List<String>.from(selectedValues);
                        if (selected) {
                          newList.add(optionValue);
                        } else {
                          newList.remove(optionValue);
                        }
                        _updateField(name, newList);
                      }
                    : null,
                selectedColor: _theme.primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : _theme.labelColor,
                ),
                backgroundColor: _theme.fillColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    Map<String, dynamic> field,
    String name,
    String label,
    String? hint,
    bool enabled,
  ) {
    final value = _formData[name] as DateTime?;

    return Padding(
      padding: _theme.fieldPadding,
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: value != null
              ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
              : '',
        ),
        style: TextStyle(color: _theme.textColor),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: _theme.labelColor),
          filled: true,
          fillColor: _theme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_theme.borderRadius),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: _theme.labelColor),
        ),
        validator: (val) => _validateField(field, value),
        onTap: enabled
            ? () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: value ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) _updateField(name, picked);
              }
            : null,
      ),
    );
  }

  Widget _buildSectionHeader(Map<String, dynamic> field) {
    final title = field['title'] as String;
    final description = field['description'] as String?;

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _theme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: _theme.hintColor, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider(Map<String, dynamic> field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        color: _theme.borderColor,
        thickness: field['thickness'] as double? ?? 1,
      ),
    );
  }

  Widget _buildHtmlField(Map<String, dynamic> field) {
    final content = field['content'] as String;

    return Padding(
      padding: _theme.fieldPadding,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _theme.fillColor,
          borderRadius: BorderRadius.circular(_theme.borderRadius),
        ),
        child: Text(content, style: TextStyle(color: _theme.labelColor)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.actions!.map((action) {
        final type = action['type'] as String? ?? 'primary';
        final label = action['label'] as String;
        final id = action['id'] as String;
        final icon = action['icon'] as IconData?;

        // CEL-based action visibility
        final visibleCondition = action['visibleIf'];
        final isVisible = _evaluateCondition(visibleCondition);

        if (!isVisible) return const SizedBox.shrink();

        // CEL-based action enabled state
        final enabledCondition = action['enabledIf'];
        final enabled = _evaluateCondition(enabledCondition);

        return ElevatedButton(
          onPressed: (enabled && !_isSubmitting)
              ? () => _handleAction(id)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: type == 'primary'
                ? _theme.primaryColor
                : type == 'danger'
                ? _theme.errorColor
                : _theme.borderColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isSubmitting && type == 'primary'
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label),
                  ],
                ),
        );
      }).toList(),
    );
  }
}

// ============================================================================
// EXAMPLE USAGE WITH CEL EXPRESSIONS
// ============================================================================

class CelFormBuilderExample extends StatefulWidget {
  const CelFormBuilderExample({Key? key}) : super(key: key);

  @override
  State<CelFormBuilderExample> createState() => _CelFormBuilderExampleState();
}

class _CelFormBuilderExampleState extends State<CelFormBuilderExample> {
  Map<String, dynamic> _formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('CEL-Powered Form Builder'),
        backgroundColor: const Color(0xFF2D2D2D),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'CEL Expression Examples',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• age >= 18 && country == "USA"\n'
                    '• email.contains("@") && email.contains(".")\n'
                    '• skills.size() > 2\n'
                    '• name.matches("[A-Za-z]+")\n'
                    '• accountType in ["premium", "enterprise"]',
                    style: TextStyle(color: Colors.blue[200], fontSize: 13),
                  ),
                ],
              ),
            ),

            ConfigurableFormBuilder(
              fields: [
                // Section 1: Basic Info
                {
                  'type': 'section',
                  'title': 'Personal Information',
                  'description': 'Basic details about you',
                },

                {
                  'name': 'name',
                  'type': 'text',
                  'label': 'Full Name',
                  'hint': 'Enter your full name',
                  'prefixIcon': Icons.person,
                  'required': true,
                  'validation': {
                    'minLength': 2,
                    'cel': 'name.matches("[A-Za-z ]+") && name.size() >= 2',
                    'celErrorMessage':
                        'Name must contain only letters and be at least 2 characters',
                  },
                },

                {
                  'name': 'email',
                  'type': 'email',
                  'label': 'Email Address',
                  'hint': 'your@email.com',
                  'prefixIcon': Icons.email,
                  'required': true,
                  'validation': {
                    'cel': 'email.contains("@") && email.contains(".")',
                    'celErrorMessage': 'Please enter a valid email address',
                  },
                },

                {
                  'name': 'age',
                  'type': 'number',
                  'label': 'Age',
                  'hint': 'Enter your age',
                  'prefixIcon': Icons.cake,
                  'required': true,
                  'validation': {
                    'min': 1,
                    'max': 120,
                    'cel': 'age >= 1 && age <= 120',
                    'celErrorMessage': 'Age must be between 1 and 120',
                  },
                },

                {
                  'name': 'country',
                  'type': 'select',
                  'label': 'Country',
                  'options': ['USA', 'Canada', 'UK', 'Australia', 'Other'],
                  'required': true,
                },

                // Conditional field: Only show state if country is USA
                {
                  'name': 'state',
                  'type': 'text',
                  'label': 'State',
                  'hint': 'Enter your state',
                  'visibleIf': 'country == "USA"',
                  'requiredIf': 'country == "USA"',
                },

                {'type': 'divider'},

                // Section 2: Account Type
                {'type': 'section', 'title': 'Account Settings'},

                {
                  'name': 'accountType',
                  'type': 'radio',
                  'label': 'Account Type',
                  'options': [
                    {'value': 'free', 'label': 'Free'},
                    {'value': 'premium', 'label': 'Premium'},
                    {'value': 'enterprise', 'label': 'Enterprise'},
                  ],
                  'defaultValue': 'free',
                },

                // Show premium features only for premium/enterprise
                {
                  'name': 'premiumFeatures',
                  'type': 'chips',
                  'label': 'Premium Features',
                  'options': [
                    'Advanced Analytics',
                    'Priority Support',
                    'Custom Branding',
                    'API Access',
                  ],
                  'visibleIf': 'accountType in ["premium", "enterprise"]',
                },

                // Enterprise-only field
                {
                  'name': 'companySize',
                  'type': 'slider',
                  'label': 'Company Size',
                  'min': 1,
                  'max': 10000,
                  'defaultValue': 50,
                  'visibleIf': 'accountType == "enterprise"',
                },

                // Enable notifications only for age >= 18
                {
                  'name': 'emailNotifications',
                  'type': 'switch',
                  'label': 'Email Notifications',
                  'enabledIf': 'age >= 18',
                  'defaultValue': false,
                },

                {'type': 'divider'},

                // Section 3: Skills & Experience
                {'type': 'section', 'title': 'Skills & Experience'},

                {
                  'name': 'experience',
                  'type': 'slider',
                  'label': 'Years of Experience',
                  'min': 0,
                  'max': 50,
                  'defaultValue': 0,
                },

                {
                  'name': 'skills',
                  'type': 'chips',
                  'label': 'Technical Skills',
                  'options': [
                    'Flutter',
                    'React',
                    'Python',
                    'Java',
                    'JavaScript',
                    'Go',
                    'Rust',
                  ],
                },

                // Show advanced certification only if experience >= 5
                {
                  'name': 'certifications',
                  'type': 'textarea',
                  'label': 'Professional Certifications',
                  'hint': 'List your certifications',
                  'maxLines': 3,
                  'visibleIf': 'experience >= 5',
                },

                {'type': 'divider'},

                // Section 4: Additional Info
                {'type': 'section', 'title': 'Additional Information'},

                {
                  'name': 'newsletter',
                  'type': 'checkbox',
                  'label': 'Subscribe to Newsletter',
                  'defaultValue': false,
                },

                {
                  'name': 'terms',
                  'type': 'checkbox',
                  'label': 'I agree to the Terms and Conditions',
                  'required': true,
                },

                {
                  'name': 'bio',
                  'type': 'textarea',
                  'label': 'Bio',
                  'hint': 'Tell us about yourself (optional)',
                  'maxLines': 4,
                  'validation': {
                    'cel': 'bio.size() == 0 || bio.size() >= 10',
                    'celErrorMessage':
                        'Bio must be empty or at least 10 characters',
                  },
                },

                {
                  'type': 'html',
                  'content':
                      '📋 All fields marked with * are required. Your data is secure and encrypted.',
                },
              ],

              initialValues: _formData,

              onChanged: (data) {
                setState(() => _formData = data);
              },

              onFieldChanged: (fieldName, value) {
                print('Field "$fieldName" changed to: $value');
              },

              useCelExpressions: true,

              enableAutoSave: true,
              autoSaveDelay: const Duration(seconds: 3),
              onAutoSave: (data) {
                print('Auto-saved: $data');
              },

              actions: [
                {
                  'id': 'reset',
                  'label': 'Reset Form',
                  'type': 'secondary',
                  'icon': Icons.refresh,
                  'requiresValidation': false,
                },
                {
                  'id': 'draft',
                  'label': 'Save Draft',
                  'type': 'secondary',
                  'icon': Icons.save,
                  'requiresValidation': false,
                  'visibleIf':
                      'name != "" || email != ""', // Show only if some data entered
                },
                {
                  'id': 'submit',
                  'label': 'Submit',
                  'type': 'primary',
                  'icon': Icons.check,
                  'requiresValidation': true,
                  'enabledIf': 'terms == true', // Enable only if terms accepted
                  'condition': 'age >= 18 || country != "USA"',
                  'conditionErrorMessage':
                      'You must be 18 or older to submit (for USA users)',
                },
              ],

              onAction: (actionId, formData) async {
                if (actionId == 'submit') {
                  print('Submitting form: $formData');

                  // Simulate API call
                  await Future.delayed(const Duration(seconds: 2));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✅ Form submitted successfully!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else if (actionId == 'reset') {
                  setState(() => _formData = {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Form reset'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (actionId == 'draft') {
                  print('Saving draft: $formData');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💾 Draft saved'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
