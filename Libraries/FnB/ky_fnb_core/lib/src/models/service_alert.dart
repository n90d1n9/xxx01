/// Categories for guest and service alerts shared across FnB workflows.
enum FnbServiceAlertType {
  allergy,
  dietary,
  preference,
  accessibility,
  timing,
  service;

  String get label => switch (this) {
    FnbServiceAlertType.allergy => 'Allergy',
    FnbServiceAlertType.dietary => 'Dietary',
    FnbServiceAlertType.preference => 'Preference',
    FnbServiceAlertType.accessibility => 'Accessibility',
    FnbServiceAlertType.timing => 'Timing',
    FnbServiceAlertType.service => 'Service',
  };

  int get priorityScore => switch (this) {
    FnbServiceAlertType.allergy => 60,
    FnbServiceAlertType.dietary => 50,
    FnbServiceAlertType.accessibility => 40,
    FnbServiceAlertType.timing => 30,
    FnbServiceAlertType.preference => 20,
    FnbServiceAlertType.service => 10,
  };
}

/// Structured warning or guest need carried from service into operations.
class FnbServiceAlert {
  const FnbServiceAlert({
    required this.type,
    required this.label,
    this.description,
    this.critical = false,
  }) : assert(label != '', 'label must not be empty.');

  final FnbServiceAlertType type;
  final String label;
  final String? description;
  final bool critical;

  int get priorityScore => type.priorityScore + (critical ? 100 : 0);

  String get titleLabel {
    final value = label.trim();
    return value.isEmpty ? type.label : value;
  }

  String? get descriptionLabel {
    final value = description?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String get compactLabel {
    return '${type.label}: $titleLabel';
  }

  String get accessibilityLabel {
    final prefix = critical ? 'Critical ' : '';
    final description = descriptionLabel;
    final label = '$prefix$compactLabel';
    if (description == null) return label;
    return '$label, $description';
  }
}
