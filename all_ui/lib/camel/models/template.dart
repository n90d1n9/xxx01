import 'package:flutter/material.dart';

class Template {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final Map<String, dynamic> defaultContext;
  final List<TemplateField> fields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> tags;
  final TemplateConfig config;

  const Template({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.category = 'General',
    this.defaultContext = const {},
    this.fields = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.tags = const [],
    this.config = const TemplateConfig(),
  });

  Template copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    String? category,
    Map<String, dynamic>? defaultContext,
    List<TemplateField>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? tags,
    TemplateConfig? config,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      defaultContext: defaultContext ?? this.defaultContext,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      config: config ?? this.config,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _iconToCode(icon),
      'category': category,
      'defaultContext': defaultContext,
      'fields': fields.map((field) => field.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'tags': tags,
      'config': config.toJson(),
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: _iconFromCode(json['icon']),
      category: json['category'],
      defaultContext: Map<String, dynamic>.from(json['defaultContext']),
      fields:
          (json['fields'] as List)
              .map((field) => TemplateField.fromJson(field))
              .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isActive: json['isActive'],
      tags: List<String>.from(json['tags']),
      config: TemplateConfig.fromJson(json['config']),
    );
  }

  static String _iconToCode(IconData icon) {
    // Convert IconData to string representation
    return '${icon.codePoint}:${icon.fontFamily}:${icon.fontPackage}';
  }

  static IconData _iconFromCode(String code) {
    final parts = code.split(':');
    return IconData(
      int.parse(parts[0]),
      fontFamily: parts[1] == 'null' ? null : parts[1],
      fontPackage: parts[2] == 'null' ? null : parts[2],
    );
  }

  @override
  String toString() {
    return 'Template(id: $id, name: $name, category: $category, active: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Template && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TemplateField {
  final String key;
  final String label;
  final FieldType type;
  final dynamic defaultValue;
  final bool required;
  final List<String>? options;
  final String? validationRegex;
  final String? hintText;

  const TemplateField({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.required = false,
    this.options,
    this.validationRegex,
    this.hintText,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'type': type.name,
      'defaultValue': defaultValue,
      'required': required,
      'options': options,
      'validationRegex': validationRegex,
      'hintText': hintText,
    };
  }

  factory TemplateField.fromJson(Map<String, dynamic> json) {
    return TemplateField(
      key: json['key'],
      label: json['label'],
      type: FieldType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FieldType.text,
      ),
      defaultValue: json['defaultValue'],
      required: json['required'],
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
      validationRegex: json['validationRegex'],
      hintText: json['hintText'],
    );
  }
}

enum FieldType { text, number, email, date, boolean, select, textarea, json }

class TemplateConfig {
  final bool allowStreaming;
  final bool enableCaching;
  final int cacheDuration;
  final List<String> outputFormats;
  final int maxFileSize;

  const TemplateConfig({
    this.allowStreaming = true,
    this.enableCaching = true,
    this.cacheDuration = 300, // seconds
    this.outputFormats = const ['html', 'txt'],
    this.maxFileSize = 1024 * 1024, // 1MB
  });

  Map<String, dynamic> toJson() {
    return {
      'allowStreaming': allowStreaming,
      'enableCaching': enableCaching,
      'cacheDuration': cacheDuration,
      'outputFormats': outputFormats,
      'maxFileSize': maxFileSize,
    };
  }

  factory TemplateConfig.fromJson(Map<String, dynamic> json) {
    return TemplateConfig(
      allowStreaming: json['allowStreaming'],
      enableCaching: json['enableCaching'],
      cacheDuration: json['cacheDuration'],
      outputFormats: List<String>.from(json['outputFormats']),
      maxFileSize: json['maxFileSize'],
    );
  }
}
