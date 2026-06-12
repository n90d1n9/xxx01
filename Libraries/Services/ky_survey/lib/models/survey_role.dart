enum SurveyRole { admin, interviewer, participant, analyst, reportViewer }

enum SurveyWorkspaceSection {
  overview,
  builder,
  fieldwork,
  participants,
  analytics,
  reports,
}

extension SurveyRoleDetails on SurveyRole {
  String get label {
    switch (this) {
      case SurveyRole.admin:
        return 'Admin';
      case SurveyRole.interviewer:
        return 'Interviewer';
      case SurveyRole.participant:
        return 'Participant';
      case SurveyRole.analyst:
        return 'Analyst';
      case SurveyRole.reportViewer:
        return 'Report';
    }
  }

  String get workspaceTitle {
    switch (this) {
      case SurveyRole.admin:
        return 'Survey Command Center';
      case SurveyRole.interviewer:
        return 'Fieldwork Console';
      case SurveyRole.participant:
        return 'Survey Intake';
      case SurveyRole.analyst:
        return 'Insight Lab';
      case SurveyRole.reportViewer:
        return 'Report Room';
    }
  }

  List<SurveyWorkspaceSection> get sections {
    switch (this) {
      case SurveyRole.admin:
        return const [
          SurveyWorkspaceSection.overview,
          SurveyWorkspaceSection.builder,
          SurveyWorkspaceSection.fieldwork,
          SurveyWorkspaceSection.participants,
          SurveyWorkspaceSection.analytics,
          SurveyWorkspaceSection.reports,
        ];
      case SurveyRole.interviewer:
        return const [
          SurveyWorkspaceSection.fieldwork,
          SurveyWorkspaceSection.participants,
          SurveyWorkspaceSection.overview,
        ];
      case SurveyRole.participant:
        return const [
          SurveyWorkspaceSection.participants,
          SurveyWorkspaceSection.overview,
        ];
      case SurveyRole.analyst:
        return const [
          SurveyWorkspaceSection.analytics,
          SurveyWorkspaceSection.reports,
          SurveyWorkspaceSection.overview,
        ];
      case SurveyRole.reportViewer:
        return const [
          SurveyWorkspaceSection.reports,
          SurveyWorkspaceSection.analytics,
          SurveyWorkspaceSection.overview,
        ];
    }
  }
}

extension SurveyWorkspaceSectionDetails on SurveyWorkspaceSection {
  String get label {
    switch (this) {
      case SurveyWorkspaceSection.overview:
        return 'Overview';
      case SurveyWorkspaceSection.builder:
        return 'Builder';
      case SurveyWorkspaceSection.fieldwork:
        return 'Fieldwork';
      case SurveyWorkspaceSection.participants:
        return 'Participants';
      case SurveyWorkspaceSection.analytics:
        return 'Analytics';
      case SurveyWorkspaceSection.reports:
        return 'Reports';
    }
  }
}
