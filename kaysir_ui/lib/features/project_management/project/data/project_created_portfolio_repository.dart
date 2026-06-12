import 'package:kaysir/services/local_database/local_storage_service.dart';

import '../models/project_custom_attribute.dart';
import '../models/project_portfolio_item.dart';

abstract class ProjectCreatedPortfolioSnapshotStore {
  Future<Map<String, Object?>?> read();

  Future<void> write(Map<String, Object?> snapshot);
}

class LocalDbProjectCreatedPortfolioSnapshotStore
    implements ProjectCreatedPortfolioSnapshotStore {
  static const defaultStorageKey = 'project.created_portfolio.snapshot.v1';

  LocalDbProjectCreatedPortfolioSnapshotStore({
    this.storageKey = defaultStorageKey,
    this.encryptionPassword = 'kaysir-project-created-portfolio-local',
  });

  final String storageKey;
  final String encryptionPassword;
  Future<void>? _initialization;

  @override
  Future<Map<String, Object?>?> read() async {
    await _ensureInitialized();
    final stored = await LocalDBService.getPreference(key: storageKey);
    return _asJsonMap(stored);
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    await _ensureInitialized();
    await LocalDBService.savePreference(key: storageKey, value: snapshot);
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= LocalDBService.initialize(
      encryptionPassword: encryptionPassword,
    ).then((_) {});
  }
}

class MemoryProjectCreatedPortfolioSnapshotStore
    implements ProjectCreatedPortfolioSnapshotStore {
  Map<String, Object?>? _snapshot;

  Map<String, Object?>? get snapshot {
    final value = _snapshot;
    if (value == null) return null;

    return Map<String, Object?>.unmodifiable(value);
  }

  @override
  Future<Map<String, Object?>?> read() async {
    return snapshot;
  }

  @override
  Future<void> write(Map<String, Object?> snapshot) async {
    _snapshot = Map<String, Object?>.unmodifiable(snapshot);
  }
}

class ProjectCreatedPortfolioRepository {
  const ProjectCreatedPortfolioRepository({required this.store});

  final ProjectCreatedPortfolioSnapshotStore store;

  Future<List<ProjectPortfolioItem>> load() async {
    final snapshot = await store.read();
    if (snapshot == null) return const [];

    try {
      final rawProjects = snapshot['projects'];
      if (rawProjects is! List) return const [];

      return List.unmodifiable(
        rawProjects
            .map((raw) => _projectFromJson(_asJsonMap(raw)))
            .whereType<ProjectPortfolioItem>(),
      );
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<ProjectPortfolioItem> projects) async {
    await store.write({
      'version': 1,
      'projects': [for (final project in projects) _projectToJson(project)],
    });
  }

  Future<void> clear() async {
    await save(const []);
  }
}

Map<String, Object?> _projectToJson(ProjectPortfolioItem project) {
  return {
    'id': project.id,
    'name': project.name,
    'owner': project.owner,
    'client': project.client,
    'businessDomain': project.businessDomain,
    'summary': project.summary,
    'sponsor': project.sponsor,
    'startDate': project.startDate.toIso8601String(),
    'endDate': project.endDate.toIso8601String(),
    'progress': project.progress,
    'budgetUsed': project.budgetUsed,
    'health': project.health.name,
    'timelineTaskIds': project.timelineTaskIds,
    'customAttributes': [
      for (final attribute in project.customAttributes)
        {
          'key': attribute.key,
          'label': attribute.label,
          'type': attribute.type.name,
          'value': attribute.value,
          'unit': attribute.unit,
          'options': attribute.options,
          'isPinned': attribute.isPinned,
        },
    ],
    'milestones': [
      for (final milestone in project.milestones)
        {
          'label': milestone.label,
          'dueDate': milestone.dueDate.toIso8601String(),
          'isComplete': milestone.isComplete,
        },
    ],
    'risks': [
      for (final risk in project.risks)
        {
          'title': risk.title,
          'detail': risk.detail,
          'severity': risk.severity.name,
        },
    ],
    'team': [
      for (final member in project.team)
        {
          'name': member.name,
          'role': member.role,
          'allocation': member.allocation,
        },
    ],
  };
}

ProjectPortfolioItem? _projectFromJson(Map<String, Object?>? json) {
  if (json == null) return null;

  try {
    final id = _string(json['id']);
    final name = _string(json['name']);
    final owner = _string(json['owner']);
    final client = _string(json['client']);
    final startDate = _date(json['startDate']);
    final endDate = _date(json['endDate']);
    if ([id, name, owner, client].any((value) => value.isEmpty) ||
        startDate == null ||
        endDate == null) {
      return null;
    }

    return ProjectPortfolioItem(
      id: id,
      name: name,
      owner: owner,
      client: client,
      businessDomain:
          _string(json['businessDomain']).isEmpty
              ? 'General Business'
              : _string(json['businessDomain']),
      summary: _string(json['summary']),
      sponsor: _string(json['sponsor']),
      startDate: startDate,
      endDate: endDate,
      progress: _double(json['progress']).clamp(0, 1),
      budgetUsed: _double(json['budgetUsed']).clamp(0, 1),
      health: _health(json['health']),
      timelineTaskIds: [
        for (final value in _list(json['timelineTaskIds'])) _string(value),
      ].where((value) => value.isNotEmpty).toList(growable: false),
      customAttributes: [
        for (final attribute in _list(
          json['customAttributes'],
        ).map((raw) => _customAttributeFromJson(_asJsonMap(raw))))
          if (attribute != null) attribute,
      ],
      milestones: [
        for (final raw in _list(json['milestones']))
          if (_milestoneFromJson(_asJsonMap(raw)) != null)
            _milestoneFromJson(_asJsonMap(raw))!,
      ],
      risks: [
        for (final raw in _list(json['risks']))
          if (_riskFromJson(_asJsonMap(raw)) != null)
            _riskFromJson(_asJsonMap(raw))!,
      ],
      team: [
        for (final raw in _list(json['team']))
          if (_teamMemberFromJson(_asJsonMap(raw)) != null)
            _teamMemberFromJson(_asJsonMap(raw))!,
      ],
    );
  } catch (_) {
    return null;
  }
}

ProjectCustomAttribute? _customAttributeFromJson(Map<String, Object?>? json) {
  if (json == null) return null;
  final label = _string(json['label']);
  final value = _string(json['value']);
  if (label.isEmpty && value.isEmpty) return null;

  return ProjectCustomAttribute(
    key: normalizeProjectCustomAttributeKey(
      _string(json['key']).isEmpty ? label : _string(json['key']),
    ),
    label: label.isEmpty ? 'Custom Field' : label,
    type: projectCustomAttributeTypeFromName(json['type']),
    value: value,
    unit: _string(json['unit']),
    options: [
      for (final option in _list(json['options']))
        if (_string(option).isNotEmpty) _string(option),
    ],
    isPinned: json['isPinned'] == true,
  );
}

ProjectMilestone? _milestoneFromJson(Map<String, Object?>? json) {
  if (json == null) return null;
  final label = _string(json['label']);
  final dueDate = _date(json['dueDate']);
  if (label.isEmpty || dueDate == null) return null;

  return ProjectMilestone(
    label: label,
    dueDate: dueDate,
    isComplete: json['isComplete'] == true,
  );
}

ProjectDeliveryRisk? _riskFromJson(Map<String, Object?>? json) {
  if (json == null) return null;
  final title = _string(json['title']);
  final detail = _string(json['detail']);
  if (title.isEmpty || detail.isEmpty) return null;

  return ProjectDeliveryRisk(
    title: title,
    detail: detail,
    severity: _health(json['severity']),
  );
}

ProjectTeamMember? _teamMemberFromJson(Map<String, Object?>? json) {
  if (json == null) return null;
  final name = _string(json['name']);
  final role = _string(json['role']);
  if (name.isEmpty || role.isEmpty) return null;

  return ProjectTeamMember(
    name: name,
    role: role,
    allocation: _double(json['allocation']).clamp(0, 1),
  );
}

Map<String, Object?>? _asJsonMap(Object? value) {
  if (value == null) return null;
  if (value is Map<String, Object?>) return value;
  if (value is Map) return Map<String, Object?>.from(value);

  return null;
}

List<Object?> _list(Object? value) {
  if (value is List) return value.cast<Object?>();
  return const [];
}

String _string(Object? value) => value?.toString().trim() ?? '';

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  return DateTime.tryParse(value?.toString() ?? '');
}

ProjectHealth _health(Object? value) {
  final name = value?.toString();
  return ProjectHealth.values.firstWhere(
    (health) => health.name == name,
    orElse: () => ProjectHealth.onTrack,
  );
}
