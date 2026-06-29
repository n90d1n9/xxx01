// services/template_service.dart
import '../models/execution_log_entry.dart';
import '../models/template.dart';
import 'template_engine.dart';

class TemplateService {
  final TemplateEngine _engine = TemplateEngine(templateDirectory: 'templates');

  Future<void> executeTemplate(Template template) async {
    try {
      // Your template execution logic here
      final result = _engine.render(template.name, template.defaultContext);

      // Log the execution
      final logEntry = ExecutionLogEntry(
        id: 'exec_${DateTime.now().millisecondsSinceEpoch}',
        templateId: template.id,
        templateName: template.name,
        action: 'Template Execution',
        nodeName: 'Template Engine',
        timestamp: DateTime.now(),
        processingTime: Duration.zero, // Calculate actual time
        status: ExecutionStatus.success,
        outputSize: result.length,
      );

      // Add to your log system
      // ref.read(logProvider.notifier).addLog(logEntry);
    } catch (e) {
      // Handle error
      final errorEntry = ExecutionLogEntry(
        id: 'exec_${DateTime.now().millisecondsSinceEpoch}',
        templateId: template.id,
        templateName: template.name,
        action: 'Template Execution Failed',
        nodeName: 'Template Engine',
        timestamp: DateTime.now(),
        status: ExecutionStatus.error,
        errorMessage: e.toString(),
      );

      // Add to your log system
      // ref.read(logProvider.notifier).addLog(errorEntry);
    }
  }
}
