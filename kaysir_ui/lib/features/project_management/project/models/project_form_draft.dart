import '../data/project_custom_attribute_templates.dart';
import '../data/project_domain_registry.dart';
import 'project_custom_attribute.dart';
import 'project_portfolio_item.dart';

class ProjectFormDraft {
  const ProjectFormDraft({
    required this.name,
    required this.client,
    required this.owner,
    required this.sponsor,
    required this.businessDomain,
    required this.summary,
    required this.startDate,
    required this.endDate,
    required this.health,
    required this.progress,
    required this.budgetUsed,
    this.customAttributes = const [],
  });

  factory ProjectFormDraft.initial({DateTime? today}) {
    final startDate = today ?? DateTime.now();
    return ProjectFormDraft(
      name: '',
      client: '',
      owner: '',
      sponsor: '',
      businessDomain: projectBusinessDomainOptions.first,
      summary: '',
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      endDate: DateTime(startDate.year, startDate.month + 2, startDate.day),
      health: ProjectHealth.onTrack,
      progress: 0,
      budgetUsed: 0,
      customAttributes: defaultProjectCustomAttributesForDomain(
        projectBusinessDomainOptions.first,
      ),
    );
  }

  factory ProjectFormDraft.fromProject(ProjectPortfolioItem project) {
    return ProjectFormDraft(
      name: project.name,
      client: project.client,
      owner: project.owner,
      sponsor: project.sponsor,
      businessDomain:
          project.businessDomain.isEmpty
              ? projectBusinessDomainOptions.last
              : project.businessDomain,
      summary: project.summary,
      startDate: project.startDate,
      endDate: project.endDate,
      health: project.health,
      progress: project.progress,
      budgetUsed: project.budgetUsed,
      customAttributes: mergeProjectCustomAttributesForDomain(
        domain:
            project.businessDomain.isEmpty
                ? projectBusinessDomainOptions.last
                : project.businessDomain,
        currentAttributes: project.customAttributes,
      ),
    );
  }

  final String name;
  final String client;
  final String owner;
  final String sponsor;
  final String businessDomain;
  final String summary;
  final DateTime startDate;
  final DateTime endDate;
  final ProjectHealth health;
  final double progress;
  final double budgetUsed;
  final List<ProjectCustomAttribute> customAttributes;

  int get durationDays => endDate.difference(startDate).inDays + 1;

  ProjectFormDraft copyWith({
    String? name,
    String? client,
    String? owner,
    String? sponsor,
    String? businessDomain,
    String? summary,
    DateTime? startDate,
    DateTime? endDate,
    ProjectHealth? health,
    double? progress,
    double? budgetUsed,
    List<ProjectCustomAttribute>? customAttributes,
  }) {
    return ProjectFormDraft(
      name: name ?? this.name,
      client: client ?? this.client,
      owner: owner ?? this.owner,
      sponsor: sponsor ?? this.sponsor,
      businessDomain: businessDomain ?? this.businessDomain,
      summary: summary ?? this.summary,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      health: health ?? this.health,
      progress: progress ?? this.progress,
      budgetUsed: budgetUsed ?? this.budgetUsed,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ProjectFormDraft &&
            other.name == name &&
            other.client == client &&
            other.owner == owner &&
            other.sponsor == sponsor &&
            other.businessDomain == businessDomain &&
            other.summary == summary &&
            other.startDate == startDate &&
            other.endDate == endDate &&
            other.health == health &&
            other.progress == progress &&
            other.budgetUsed == budgetUsed &&
            _customAttributesEqual(other.customAttributes, customAttributes);
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      client,
      owner,
      sponsor,
      businessDomain,
      summary,
      startDate,
      endDate,
      health,
      progress,
      budgetUsed,
      Object.hashAll(customAttributes),
    );
  }
}

bool _customAttributesEqual(
  List<ProjectCustomAttribute> first,
  List<ProjectCustomAttribute> second,
) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}

const projectBusinessDomainOptions = projectDomainBusinessDomainOptions;
