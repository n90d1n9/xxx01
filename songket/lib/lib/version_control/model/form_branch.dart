import 'form_commit.dart';

class FormBranch {
  final String id;
  final String name;
  final String description;
  final String basedOn;
  final DateTime createdAt;
  final String createdBy;
  final bool isProtected;
  final List<FormCommit> commits;

  const FormBranch({
    required this.id,
    required this.name,
    required this.description,
    required this.basedOn,
    required this.createdAt,
    required this.createdBy,
    this.isProtected = false,
    this.commits = const [],
  });
}
