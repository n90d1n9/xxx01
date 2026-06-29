import 'select_option.dart';

/// Widget-specific options for UI rendering

class WidgetOptions {
  final String? placeholder;
  final String? helpText;
  final List<SelectOption>? options;
  final int? rows;
  final int? maxLength;
  final bool? multiline;
  final String? referenceTo;
  final String? displayField;
  final String? slugFrom; // For slug fields: auto-generate from this field
  final Map<String, dynamic>? config;

  const WidgetOptions({
    this.placeholder,
    this.helpText,
    this.options,
    this.rows,
    this.maxLength,
    this.multiline,
    this.referenceTo,
    this.displayField,
    this.slugFrom,
    this.config,
  });

  Map<String, dynamic> toJson() => {
    'placeholder': placeholder,
    'helpText': helpText,
    'options': options?.map((e) => e.toJson()).toList(),
    'rows': rows,
    'maxLength': maxLength,
    'multiline': multiline,
    'referenceTo': referenceTo,
    'displayField': displayField,
    'slugFrom': slugFrom,
    'config': config,
  };

  factory WidgetOptions.fromJson(Map<String, dynamic> json) => WidgetOptions(
    placeholder: json['placeholder'],
    helpText: json['helpText'],
    options:
        json['options'] != null
            ? (json['options'] as List)
                .map((e) => SelectOption.fromJson(e))
                .toList()
            : null,
    rows: json['rows'],
    maxLength: json['maxLength'],
    multiline: json['multiline'],
    referenceTo: json['referenceTo'],
    displayField: json['displayField'],
    slugFrom: json['slugFrom'],
    config: json['config'],
  );
}
