import 'field_config.dart';

class AccordionPanelConfig {
  final String id;
  final String header;
  final String? description;
  final List<FieldConfig> fields;
  final bool expanded;
  final bool canToggle;

  AccordionPanelConfig({
    required this.id,
    required this.header,
    this.description,
    required this.fields,
    this.expanded = false,
    this.canToggle = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'header': header,
      'description': description,
      'fields': fields.map((f) => f.toJson()).toList(),
      'expanded': expanded,
      'canToggle': canToggle,
    };
  }
}
