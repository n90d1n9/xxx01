import 'schema/layout/section.dart';

class Template {
  final String id;
  final String name;
  final String description;
  final String category;
  final String thumbnail;
  final List<Section> sections;

  Template({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.thumbnail,
    required this.sections,
  });
}
