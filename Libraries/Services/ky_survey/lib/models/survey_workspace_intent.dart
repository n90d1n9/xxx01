import 'survey_role.dart';

enum SurveyWorkspaceLaunchTarget {
  workspace,
  surveyList,
  createSurvey,
  editSurvey,
  intake,
}

class SurveyWorkspaceIntent {
  final SurveyRole role;
  final SurveyWorkspaceSection section;
  final SurveyWorkspaceLaunchTarget launchTarget;
  final String? surveyId;

  const SurveyWorkspaceIntent({
    this.role = SurveyRole.admin,
    this.section = SurveyWorkspaceSection.overview,
    this.launchTarget = SurveyWorkspaceLaunchTarget.workspace,
    this.surveyId,
  });

  const SurveyWorkspaceIntent.overview({SurveyRole role = SurveyRole.admin})
    : this(role: role);

  const SurveyWorkspaceIntent.builder({
    SurveyRole role = SurveyRole.admin,
    String? surveyId,
    bool openEditor = false,
  }) : this(
         role: role,
         section: SurveyWorkspaceSection.builder,
         launchTarget: openEditor || surveyId != null
             ? SurveyWorkspaceLaunchTarget.editSurvey
             : SurveyWorkspaceLaunchTarget.workspace,
         surveyId: surveyId,
       );

  const SurveyWorkspaceIntent.newBuilder({SurveyRole role = SurveyRole.admin})
    : this(
        role: role,
        section: SurveyWorkspaceSection.builder,
        launchTarget: SurveyWorkspaceLaunchTarget.createSurvey,
      );

  const SurveyWorkspaceIntent.fieldwork({
    SurveyRole role = SurveyRole.interviewer,
  }) : this(role: role, section: SurveyWorkspaceSection.fieldwork);

  const SurveyWorkspaceIntent.participants({
    SurveyRole role = SurveyRole.participant,
  }) : this(role: role, section: SurveyWorkspaceSection.participants);

  const SurveyWorkspaceIntent.intake({
    SurveyRole role = SurveyRole.participant,
    String? surveyId,
  }) : this(
         role: role,
         section: SurveyWorkspaceSection.participants,
         launchTarget: SurveyWorkspaceLaunchTarget.intake,
         surveyId: surveyId,
       );

  const SurveyWorkspaceIntent.analytics({SurveyRole role = SurveyRole.analyst})
    : this(role: role, section: SurveyWorkspaceSection.analytics);

  const SurveyWorkspaceIntent.reports({
    SurveyRole role = SurveyRole.reportViewer,
  }) : this(role: role, section: SurveyWorkspaceSection.reports);

  const SurveyWorkspaceIntent.surveyList({SurveyRole role = SurveyRole.admin})
    : this(role: role, launchTarget: SurveyWorkspaceLaunchTarget.surveyList);

  bool get opensScreen {
    return launchTarget != SurveyWorkspaceLaunchTarget.workspace;
  }

  bool get needsSurvey {
    return launchTarget == SurveyWorkspaceLaunchTarget.editSurvey ||
        launchTarget == SurveyWorkspaceLaunchTarget.intake;
  }

  SurveyWorkspaceSection get effectiveSection {
    final roleSections = role.sections;
    if (roleSections.contains(section)) {
      return section;
    }
    return roleSections.first;
  }

  int get selectedIndex {
    return role.sections.indexOf(effectiveSection);
  }

  SurveyWorkspaceIntent copyWith({
    SurveyRole? role,
    SurveyWorkspaceSection? section,
    SurveyWorkspaceLaunchTarget? launchTarget,
    String? surveyId,
    bool clearSurveyId = false,
  }) {
    return SurveyWorkspaceIntent(
      role: role ?? this.role,
      section: section ?? this.section,
      launchTarget: launchTarget ?? this.launchTarget,
      surveyId: clearSurveyId ? null : surveyId ?? this.surveyId,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SurveyWorkspaceIntent &&
            other.role == role &&
            other.section == section &&
            other.launchTarget == launchTarget &&
            other.surveyId == surveyId;
  }

  @override
  int get hashCode {
    return Object.hash(role, section, launchTarget, surveyId);
  }
}

extension SurveyWorkspaceLaunchTargetDetails on SurveyWorkspaceLaunchTarget {
  String get label {
    switch (this) {
      case SurveyWorkspaceLaunchTarget.workspace:
        return 'Workspace';
      case SurveyWorkspaceLaunchTarget.surveyList:
        return 'Survey list';
      case SurveyWorkspaceLaunchTarget.createSurvey:
        return 'New builder';
      case SurveyWorkspaceLaunchTarget.editSurvey:
        return 'Builder';
      case SurveyWorkspaceLaunchTarget.intake:
        return 'Intake screen';
    }
  }
}
