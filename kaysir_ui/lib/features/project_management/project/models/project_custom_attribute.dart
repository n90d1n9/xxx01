import 'project_custom_attribute_value.dart';

enum ProjectCustomAttributeType { text, number, date, url, choice, boolean }

enum ProjectCustomAttributeImportance { requiredField, recommended, optional }

const projectCustomAttributeLimit = 12;

class ProjectCustomAttribute {
  const ProjectCustomAttribute({
    required this.key,
    required this.label,
    required this.type,
    this.value = '',
    this.unit = '',
    this.options = const [],
    this.isPinned = false,
  });

  final String key;
  final String label;
  final ProjectCustomAttributeType type;
  final String value;
  final String unit;
  final List<String> options;
  final bool isPinned;

  bool get hasValue => value.trim().isNotEmpty;

  String get displayValue {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Not set';

    switch (type) {
      case ProjectCustomAttributeType.boolean:
        return projectCustomAttributeBooleanDisplayValue(trimmed);
      case ProjectCustomAttributeType.number:
        return unit.trim().isEmpty ? trimmed : '$trimmed ${unit.trim()}';
      case ProjectCustomAttributeType.text:
      case ProjectCustomAttributeType.date:
      case ProjectCustomAttributeType.url:
      case ProjectCustomAttributeType.choice:
        return trimmed;
    }
  }

  ProjectCustomAttribute copyWith({
    String? key,
    String? label,
    ProjectCustomAttributeType? type,
    String? value,
    String? unit,
    List<String>? options,
    bool? isPinned,
  }) {
    return ProjectCustomAttribute(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      options: options ?? this.options,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProjectCustomAttribute &&
            other.key == key &&
            other.label == label &&
            other.type == type &&
            other.value == value &&
            other.unit == unit &&
            _stringListEquals(other.options, options) &&
            other.isPinned == isPinned;
  }

  @override
  int get hashCode {
    return Object.hash(
      key,
      label,
      type,
      value,
      unit,
      Object.hashAll(options),
      isPinned,
    );
  }
}

class ProjectCustomAttributeTemplate {
  const ProjectCustomAttributeTemplate({
    required this.key,
    required this.label,
    required this.type,
    this.unit = '',
    this.options = const [],
    this.defaultValue = '',
    this.isPinned = true,
    this.importance = ProjectCustomAttributeImportance.recommended,
  });

  final String key;
  final String label;
  final ProjectCustomAttributeType type;
  final String unit;
  final List<String> options;
  final String defaultValue;
  final bool isPinned;
  final ProjectCustomAttributeImportance importance;

  ProjectCustomAttribute toAttribute() {
    return ProjectCustomAttribute(
      key: key,
      label: label,
      type: type,
      value: defaultValue,
      unit: unit,
      options: options,
      isPinned: isPinned,
    );
  }
}

extension ProjectCustomAttributeImportancePresentation
    on ProjectCustomAttributeImportance {
  String get label {
    switch (this) {
      case ProjectCustomAttributeImportance.requiredField:
        return 'Required';
      case ProjectCustomAttributeImportance.recommended:
        return 'Recommended';
      case ProjectCustomAttributeImportance.optional:
        return 'Optional';
    }
  }
}

extension ProjectCustomAttributeTypePresentation on ProjectCustomAttributeType {
  String get label {
    switch (this) {
      case ProjectCustomAttributeType.text:
        return 'Text';
      case ProjectCustomAttributeType.number:
        return 'Number';
      case ProjectCustomAttributeType.date:
        return 'Date';
      case ProjectCustomAttributeType.url:
        return 'URL';
      case ProjectCustomAttributeType.choice:
        return 'Choice';
      case ProjectCustomAttributeType.boolean:
        return 'Yes/No';
    }
  }
}

List<ProjectCustomAttribute> normalizeProjectCustomAttributes(
  Iterable<ProjectCustomAttribute> attributes, {
  bool keepEmpty = false,
}) {
  final normalized = <ProjectCustomAttribute>[];
  final usedKeys = <String>{};

  for (final attribute in attributes) {
    final label = attribute.label.trim();
    final value = attribute.value.trim();
    if (!keepEmpty && label.isEmpty && value.isEmpty) continue;

    final baseKey = normalizeProjectCustomAttributeKey(
      attribute.key.trim().isEmpty ? label : attribute.key,
    );
    final key = _uniqueAttributeKey(
      baseKey.isEmpty ? 'custom-field' : baseKey,
      usedKeys,
    );
    final options = _uniqueStrings(attribute.options);

    normalized.add(
      attribute.copyWith(
        key: key,
        label: label.isEmpty ? 'Custom Field' : label,
        value: value,
        unit: attribute.unit.trim(),
        options: options,
      ),
    );
    if (normalized.length == projectCustomAttributeLimit) break;
  }

  return List.unmodifiable(normalized);
}

List<ProjectCustomAttribute> projectCustomAttributesForStorage(
  Iterable<ProjectCustomAttribute> attributes,
) {
  return List.unmodifiable(
    normalizeProjectCustomAttributes(
      attributes,
    ).where((attribute) => attribute.hasValue),
  );
}

String normalizeProjectCustomAttributeKey(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

ProjectCustomAttributeType projectCustomAttributeTypeFromName(Object? value) {
  final name = value?.toString();
  return ProjectCustomAttributeType.values.firstWhere(
    (type) => type.name == name,
    orElse: () => ProjectCustomAttributeType.text,
  );
}

String _uniqueAttributeKey(String baseKey, Set<String> usedKeys) {
  var candidate = baseKey;
  var suffix = 2;

  while (usedKeys.contains(candidate)) {
    candidate = '$baseKey-$suffix';
    suffix += 1;
  }

  usedKeys.add(candidate);
  return candidate;
}

List<String> _uniqueStrings(Iterable<String> values) {
  final seen = <String>{};
  final unique = <String>[];

  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || !seen.add(trimmed.toLowerCase())) continue;
    unique.add(trimmed);
  }

  return List.unmodifiable(unique);
}

bool _stringListEquals(List<String> first, List<String> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}
