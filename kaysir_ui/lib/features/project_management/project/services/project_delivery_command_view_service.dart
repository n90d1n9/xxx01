import 'project_delivery_command_service.dart';
import 'project_delivery_saved_lens_service.dart';

class ProjectDeliveryCommandViewPreferences {
  const ProjectDeliveryCommandViewPreferences({
    required this.profile,
    required this.filter,
  });

  static const initial = ProjectDeliveryCommandViewPreferences(
    profile: ProjectDeliverySavedLensProfile.deliveryLead,
    filter: ProjectDeliveryCommandFilter.empty,
  );

  final ProjectDeliverySavedLensProfile profile;
  final ProjectDeliveryCommandFilter filter;

  ProjectDeliveryCommandViewPreferences copyWith({
    ProjectDeliverySavedLensProfile? profile,
    ProjectDeliveryCommandFilter? filter,
  }) {
    return ProjectDeliveryCommandViewPreferences(
      profile: profile ?? this.profile,
      filter: filter ?? this.filter,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'profile': profile.name,
      'filter': {'level': filter.level?.name, 'kind': filter.kind?.name},
    };
  }

  factory ProjectDeliveryCommandViewPreferences.fromJson(
    Map<String, Object?> json,
  ) {
    final filterJson = json['filter'];

    return ProjectDeliveryCommandViewPreferences(
      profile:
          _enumFromName<ProjectDeliverySavedLensProfile>(
            ProjectDeliverySavedLensProfile.values,
            json['profile'],
            ProjectDeliverySavedLensProfile.deliveryLead,
          ) ??
          ProjectDeliverySavedLensProfile.deliveryLead,
      filter:
          filterJson is Map
              ? ProjectDeliveryCommandFilter(
                level: _enumFromName(
                  ProjectDeliveryCommandLevel.values,
                  filterJson['level'],
                  null,
                ),
                kind: _enumFromName(
                  ProjectDeliveryCommandKind.values,
                  filterJson['kind'],
                  null,
                ),
              )
              : ProjectDeliveryCommandFilter.empty,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectDeliveryCommandViewPreferences &&
        other.profile == profile &&
        other.filter == filter;
  }

  @override
  int get hashCode => Object.hash(profile, filter);
}

T? _enumFromName<T extends Enum>(
  Iterable<T> values,
  Object? name,
  T? fallback,
) {
  if (name is! String) return fallback;

  for (final value in values) {
    if (value.name == name) return value;
  }

  return fallback;
}
