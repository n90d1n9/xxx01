class ContentTypeSettings {
  final bool enableVersioning;
  final bool enablePublishing;
  final bool enableComments;
  final bool enableCategories;
  final bool enableTags;
  final String? defaultView;
  final List<String>? displayFields;
  final String? sortField;
  final String? sortOrder;

  const ContentTypeSettings({
    this.enableVersioning = false,
    this.enablePublishing = true,
    this.enableComments = false,
    this.enableCategories = false,
    this.enableTags = false,
    this.defaultView = 'list',
    this.displayFields,
    this.sortField,
    this.sortOrder = 'DESC',
  });

  Map<String, dynamic> toJson() => {
    'enableVersioning': enableVersioning,
    'enablePublishing': enablePublishing,
    'enableComments': enableComments,
    'enableCategories': enableCategories,
    'enableTags': enableTags,
    'defaultView': defaultView,
    'displayFields': displayFields,
    'sortField': sortField,
    'sortOrder': sortOrder,
  };

  factory ContentTypeSettings.fromJson(Map<String, dynamic> json) =>
      ContentTypeSettings(
        enableVersioning: json['enableVersioning'] ?? false,
        enablePublishing: json['enablePublishing'] ?? true,
        enableComments: json['enableComments'] ?? false,
        enableCategories: json['enableCategories'] ?? false,
        enableTags: json['enableTags'] ?? false,
        defaultView: json['defaultView'] ?? 'list',
        displayFields: json['displayFields']?.cast<String>(),
        sortField: json['sortField'],
        sortOrder: json['sortOrder'] ?? 'DESC',
      );
}
