import '../model/report_configuration.dart';
import '../model/template_category.dart';

class TemplateService {
  Future<List<ReportConfiguration>> getTemplates(
    TemplateCategory? category,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Return pre-configured report templates
    return [];
  }

  Future<void> saveAsTemplate(ReportConfiguration config) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
