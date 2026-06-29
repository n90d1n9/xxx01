import 'page_layout.dart';
import 'report_component.dart';

/// Report page with components
class ReportPage {
  final String id;
  final String name;
  final int pageNumber;
  final PageLayout layout;
  final List<ReportComponent> components;
  final ReportComponent? header;
  final ReportComponent? footer;
  final bool isTemplate;

  ReportPage({
    required this.id,
    required this.name,
    required this.pageNumber,
    required this.layout,
    this.components = const [],
    this.header,
    this.footer,
    this.isTemplate = false,
  });

  ReportPage copyWith({
    List<ReportComponent>? components,
    ReportComponent? header,
    ReportComponent? footer,
  }) {
    return ReportPage(
      id: id,
      name: name,
      pageNumber: pageNumber,
      layout: layout,
      components: components ?? this.components,
      header: header ?? this.header,
      footer: footer ?? this.footer,
      isTemplate: isTemplate,
    );
  }
}
