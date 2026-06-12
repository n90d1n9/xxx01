class SurveySection {
  final String id;
  final String title;
  final String description;
  final int order;

  const SurveySection({
    required this.id,
    required this.title,
    this.description = '',
    this.order = 0,
  });

  SurveySection copyWith({
    String? id,
    String? title,
    String? description,
    int? order,
  }) {
    return SurveySection(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }

  factory SurveySection.fromJson(Map<String, dynamic> json) {
    return SurveySection(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled section',
      description: json['description'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
    };
  }
}

extension SurveySectionDetails on SurveySection {
  String get titleOrFallback {
    final label = title.trim();
    return label.isEmpty ? 'Untitled section' : label;
  }
}
