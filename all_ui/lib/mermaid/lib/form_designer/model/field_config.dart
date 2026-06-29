import 'package:flutter/material.dart';

import '../style/field_style.dart';
import 'accordion_panel_config.dart';
import 'step_config.dart';
import 'tab_config.dart';

class FieldConfig {
  final String id;
  //final FieldType type;
  final String type;
  final String? name;
  final String? label;
  final String? title;
  final String? description;
  final String? content;
  final String? hint;
  final String? helperText;
  final bool required;
  final dynamic defaultValue;
  final List<dynamic>? options;
  final Map<String, dynamic>? validation;
  final String? visibleIf;
  final String? enabledIf;
  final String? requiredIf;
  final num? min;
  final num? max;
  final int? maxLines;
  final int? maxRating;
  //final FieldStyle? style;

  // Layout properties
  final List<FieldConfig>? children;
  final String? layout; // 'column', 'row'
  final int? flex;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisAlignment? mainAxisAlignment;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final int? columns; // For grid layout
  final double? spacing;
  final double? runSpacing;

  FieldConfig({
    required this.id,
    required this.type,
    //this.style,
    this.name,
    this.label,
    this.title,
    this.description,
    this.content,
    this.hint,
    this.helperText,
    this.required = false,
    this.defaultValue,
    this.options,
    this.validation,
    this.visibleIf,
    this.enabledIf,
    this.requiredIf,
    this.min,
    this.max,
    this.maxLines,
    this.maxRating,
    this.children,
    this.layout,
    this.flex,
    this.crossAxisAlignment,
    this.mainAxisAlignment,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.width,
    this.height,
    this.decoration,
    this.columns,
    this.spacing,
    this.runSpacing,
  });

  bool get isAdvancedLayout =>
      ['tabs', 'stepper', 'accordion', 'wizard'].contains(type);

  bool get isContainer =>
      ['container', 'row', 'column', 'card', 'grid'].contains(type);

  List<TabConfig>? get tabs {
    if (type == 'tabs' && options is Map && (options as Map)['tabs'] != null) {
      final tabsData = List.from((options as Map)['tabs'] as List);
      return tabsData.map((t) {
        final tabMap = Map<String, dynamic>.from(t as Map);
        return TabConfig(
          id: tabMap['id'] as String,
          label: tabMap['label'] as String,
          icon: tabMap['icon'] != null
              ? IconData(tabMap['icon'] as int, fontFamily: 'MaterialIcons')
              : null,
          fields: (tabMap['fields'] as List)
              .map((f) => fromJson(f as Map<String, dynamic>))
              .toList(),
          enabled: tabMap['enabled'] as bool? ?? true,
        );
      }).toList();
    }
    return null;
  }

  FieldConfig withStyle(FieldStyle style) {
    // Create a map for style options if it doesn't exist
    final List<dynamic> newOptions = options != null
        ? List<dynamic>.from(options!)
        : <dynamic>[];

    // Find and remove existing style entry if it exists
    newOptions.removeWhere((item) => item is Map && item.containsKey('style'));

    // Add the new style
    newOptions.add({'style': style.toJson()});

    return copyWith(options: newOptions);
  }

  FieldStyle? get style {
    if (options != null) {
      // Look for a map entry with 'style' key in the options list
      for (final item in options!) {
        if (item is Map<String, dynamic> && item.containsKey('style')) {
          final styleData = item['style'] as Map<String, dynamic>;
          return FieldStyle(
            backgroundColor: styleData['backgroundColor'] != null
                ? Color(styleData['backgroundColor'] as int)
                : null,
            borderColor: styleData['borderColor'] != null
                ? Color(styleData['borderColor'] as int)
                : null,
            textColor: styleData['textColor'] != null
                ? Color(styleData['textColor'] as int)
                : null,
            borderWidth: styleData['borderWidth'] as double?,
            borderRadius: styleData['borderRadius'] as double?,
            elevation: styleData['elevation'] as double?,
          );
        }
      }
    }
    return null;
  }

  List<StepConfig>? get steps {
    if (type == 'stepper' &&
        options is Map &&
        (options as Map)['steps'] != null) {
      final stepsData = List.from((options as Map)['steps'] as List);
      return stepsData.map((s) {
        final stepMap = Map<String, dynamic>.from(s as Map);
        return StepConfig(
          id: stepMap['id'] as String,
          title: stepMap['title'] as String,
          subtitle: stepMap['subtitle'] as String?,
          fields: (stepMap['fields'] as List)
              .map((f) => fromJson(f as Map<String, dynamic>))
              .toList(),
          optional: stepMap['optional'] as bool? ?? false,
        );
      }).toList();
    }
    return null;
  }

  List<AccordionPanelConfig>? get panels {
    if (type == 'accordion' &&
        options is Map &&
        (options as Map)['panels'] != null) {
      final panelsData = List.from((options as Map)['panels'] as List);
      return panelsData.map((p) {
        final panelMap = Map<String, dynamic>.from(p as Map);
        return AccordionPanelConfig(
          id: panelMap['id'] as String,
          header: panelMap['header'] as String,
          description: panelMap['description'] as String?,
          fields: (panelMap['fields'] as List)
              .map((f) => fromJson(f as Map<String, dynamic>))
              .toList(),
          expanded: panelMap['expanded'] as bool? ?? false,
          canToggle: panelMap['canToggle'] as bool? ?? true,
        );
      }).toList();
    }
    return null;
  }

  FieldConfig copyWith({
    String? id,
    //FieldType? type,
    String? type,
    String? name,
    String? label,
    String? title,
    String? description,
    String? content,
    String? hint,
    String? helperText,
    bool? required,
    dynamic defaultValue,
    List<dynamic>? options,
    Map<String, dynamic>? validation,
    String? visibleIf,
    String? enabledIf,
    String? requiredIf,
    num? min,
    num? max,
    int? maxLines,
    int? maxRating,
    List<FieldConfig>? children,
    String? layout,
    int? flex,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisAlignment? mainAxisAlignment,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    double? width,
    double? height,
    BoxDecoration? decoration,
    int? columns,
    double? spacing,
    double? runSpacing,
  }) {
    return FieldConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      label: label ?? this.label,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      hint: hint ?? this.hint,
      helperText: helperText ?? this.helperText,
      required: required ?? this.required,
      defaultValue: defaultValue ?? this.defaultValue,
      options: options ?? this.options,
      validation: validation ?? this.validation,
      visibleIf: visibleIf ?? this.visibleIf,
      enabledIf: enabledIf ?? this.enabledIf,
      requiredIf: requiredIf ?? this.requiredIf,
      min: min ?? this.min,
      max: max ?? this.max,
      maxLines: maxLines ?? this.maxLines,
      maxRating: maxRating ?? this.maxRating,
      children: children ?? this.children,
      layout: layout ?? this.layout,
      flex: flex ?? this.flex,
      crossAxisAlignment: crossAxisAlignment ?? this.crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment ?? this.mainAxisAlignment,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      width: width ?? this.width,
      height: height ?? this.height,
      decoration: decoration ?? this.decoration,
      columns: columns ?? this.columns,
      spacing: spacing ?? this.spacing,
      runSpacing: runSpacing ?? this.runSpacing,
    );
  }

  static FieldConfig fromJson(Map<String, dynamic> json) {
    Color? _parseColor(dynamic value) {
      if (value == null) return null;
      if (value is int) return Color(value);
      if (value is String) {
        var hex = value.replaceFirst('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        final intVal = int.parse(hex, radix: 16);
        return Color(intVal);
      }
      return null;
    }

    EdgeInsets? _parseEdgeInsets(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        final left = (value['left'] as num?)?.toDouble() ?? 0.0;
        final top = (value['top'] as num?)?.toDouble() ?? 0.0;
        final right = (value['right'] as num?)?.toDouble() ?? 0.0;
        final bottom = (value['bottom'] as num?)?.toDouble() ?? 0.0;
        return EdgeInsets.fromLTRB(left, top, right, bottom);
      }
      return null;
    }

    List<FieldConfig>? _parseChildren(dynamic value) {
      if (value == null) return null;
      if (value is List) {
        return value
            .where((e) => e != null)
            .map(
              (e) => FieldConfig.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      }
      return null;
    }

    List<dynamic>? parsedOptions;
    final rawOptions = json['options'];
    if (rawOptions is List) {
      parsedOptions = List<dynamic>.from(rawOptions);
    } else if (rawOptions != null) {
      // keep map-like options accessible by wrapping into a single-entry list
      parsedOptions = [rawOptions];
    }

    Map<String, dynamic>? parsedValidation;
    if (json['validation'] is Map) {
      parsedValidation = Map<String, dynamic>.from(json['validation'] as Map);
    }

    // id fallback: prefer explicit id, then name, otherwise generate a timestamped id
    final idVal =
        json['id'] as String? ??
        json['name'] as String? ??
        '${json['type']}_${DateTime.now().microsecondsSinceEpoch}';

    return FieldConfig(
      id: idVal,
      type: json['type'] as String,
      name: json['name'] as String?,
      label: json['label'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      hint: json['hint'] as String?,
      helperText: json['helperText'] as String?,
      required: json['required'] as bool? ?? false,
      defaultValue: json.containsKey('defaultValue')
          ? json['defaultValue']
          : null,
      options: parsedOptions,
      validation: parsedValidation,
      visibleIf: json['visibleIf'] as String?,
      enabledIf: json['enabledIf'] as String?,
      requiredIf: json['requiredIf'] as String?,
      min: json['min'] as num?,
      max: json['max'] as num?,
      maxLines: (json['maxLines'] is num)
          ? (json['maxLines'] as num).toInt()
          : null,
      maxRating: (json['maxRating'] is num)
          ? (json['maxRating'] as num).toInt()
          : null,
      children: _parseChildren(json['children']),
      layout: json['layout'] as String?,
      flex: (json['flex'] is num) ? (json['flex'] as num).toInt() : null,
      crossAxisAlignment: null,
      mainAxisAlignment: null,
      padding: _parseEdgeInsets(json['padding']),
      margin: _parseEdgeInsets(json['margin']),
      backgroundColor: _parseColor(json['backgroundColor']),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      decoration: null,
      columns: (json['columns'] is num)
          ? (json['columns'] as num).toInt()
          : null,
      spacing: (json['spacing'] as num?)?.toDouble(),
      runSpacing: (json['runSpacing'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'type': type};

    if (name != null) json['name'] = name;
    if (label != null) json['label'] = label;
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (content != null) json['content'] = content;
    if (hint != null) json['hint'] = hint;
    if (helperText != null) json['helperText'] = helperText;
    if (required) json['required'] = required;
    if (defaultValue != null) json['defaultValue'] = defaultValue;
    if (options != null) json['options'] = options;
    if (validation != null) json['validation'] = validation;
    if (visibleIf != null && visibleIf!.isNotEmpty) {
      json['visibleIf'] = visibleIf;
    }
    if (enabledIf != null && enabledIf!.isNotEmpty) {
      json['enabledIf'] = enabledIf;
    }
    if (requiredIf != null && requiredIf!.isNotEmpty) {
      json['requiredIf'] = requiredIf;
    }
    if (min != null) json['min'] = min;
    if (max != null) json['max'] = max;
    if (maxLines != null) json['maxLines'] = maxLines;
    if (maxRating != null) json['maxRating'] = maxRating;

    // Layout properties
    if (children != null) {
      json['children'] = children!.map((c) => c.toJson()).toList();
    }
    if (layout != null) json['layout'] = layout;
    if (flex != null) json['flex'] = flex;
    if (padding != null) json['padding'] = _edgeInsetsToJson(padding!);
    if (margin != null) json['margin'] = _edgeInsetsToJson(margin!);
    if (backgroundColor != null) {
      json['backgroundColor'] =
          '#${backgroundColor!.value.toRadixString(16).substring(2)}';
    }
    if (width != null) json['width'] = width;
    if (height != null) json['height'] = height;
    if (columns != null) json['columns'] = columns;
    if (spacing != null) json['spacing'] = spacing;
    if (runSpacing != null) json['runSpacing'] = runSpacing;

    return json;
  }

  Map<String, double> _edgeInsetsToJson(EdgeInsets insets) {
    return {
      'left': insets.left,
      'top': insets.top,
      'right': insets.right,
      'bottom': insets.bottom,
    };
  }
}
