import '../../form_designer/model/field_config.dart';

class FormCommit {
  final String id;
  final String branchId;
  final String message;
  final String author;
  final DateTime timestamp;
  final List<FieldConfig> fields;
  final Map<String, dynamic>? metadata;
  final String? parentCommitId;

  const FormCommit({
    required this.id,
    required this.branchId,
    required this.message,
    required this.author,
    required this.timestamp,
    required this.fields,
    this.metadata,
    this.parentCommitId,
  });
}
