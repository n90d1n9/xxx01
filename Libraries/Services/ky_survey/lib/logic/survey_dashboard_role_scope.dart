import '../models/survey_role.dart';
import '../models/survey_workspace_intent.dart';

/// Describes a role and section index after dashboard role scoping is applied.
class SurveyDashboardRoleSelection {
  final SurveyRole role;
  final int selectedIndex;

  const SurveyDashboardRoleSelection({
    required this.role,
    required this.selectedIndex,
  });

  SurveyWorkspaceSection get section {
    return role.sections[selectedIndex];
  }
}

/// Normalizes and applies the roles available to an embedded survey dashboard.
class SurveyDashboardRoleScope {
  final List<SurveyRole> roles;

  SurveyDashboardRoleScope(Iterable<SurveyRole> roles)
    : roles = _normalizeRoles(roles);

  bool contains(SurveyRole role) {
    return roles.contains(role);
  }

  SurveyRole resolveRole(SurveyRole preferredRole) {
    if (contains(preferredRole)) {
      return preferredRole;
    }

    return roles.first;
  }

  SurveyDashboardRoleSelection resolveSelection({
    required SurveyRole role,
    required int selectedIndex,
  }) {
    final currentSection = _sectionFor(
      role: role,
      selectedIndex: selectedIndex,
    );
    final scopedRole = resolveRole(role);
    final scopedIndex = scopedRole.sections.indexOf(currentSection);

    return SurveyDashboardRoleSelection(
      role: scopedRole,
      selectedIndex: scopedIndex < 0 ? 0 : scopedIndex,
    );
  }

  SurveyWorkspaceIntent resolveIntent(SurveyWorkspaceIntent intent) {
    final role = resolveRole(intent.role);
    if (role == intent.role) {
      return intent;
    }

    return intent.copyWith(role: role);
  }

  static List<SurveyRole> _normalizeRoles(Iterable<SurveyRole> roles) {
    final normalizedRoles = <SurveyRole>[];
    for (final role in roles) {
      if (!normalizedRoles.contains(role)) {
        normalizedRoles.add(role);
      }
    }

    if (normalizedRoles.isEmpty) {
      return SurveyRole.values;
    }

    return List.unmodifiable(normalizedRoles);
  }

  static SurveyWorkspaceSection _sectionFor({
    required SurveyRole role,
    required int selectedIndex,
  }) {
    final sections = role.sections;
    if (selectedIndex >= 0 && selectedIndex < sections.length) {
      return sections[selectedIndex];
    }

    return sections.first;
  }
}
