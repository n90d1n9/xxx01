import '../models/project_form_draft.dart';
import '../services/project_form_validation_service.dart';

/// Coordinates project form draft state, validation, reset, and submit attempts.
class ProjectFormDraftController {
  ProjectFormDraftController({
    required ProjectFormDraft initialDraft,
    ProjectFormValidationService validationService =
        const ProjectFormValidationService(),
  }) : _draft = initialDraft,
       _initialDraft = initialDraft,
       _validationService = validationService;

  ProjectFormDraft _draft;
  ProjectFormDraft _initialDraft;
  ProjectFormValidationService _validationService;
  List<ProjectFormIssue> _issues = const [];

  ProjectFormDraft get draft => _draft;
  List<ProjectFormIssue> get issues => _issues;

  List<ProjectFormIssue> previewIssues() {
    return _validatedIssues(_draft);
  }

  void updateValidationService(ProjectFormValidationService validationService) {
    _validationService = validationService;
    if (_issues.isNotEmpty) _issues = _validatedIssues(_draft);
  }

  void updateDraft(ProjectFormDraft draft) {
    _draft = draft;
    if (_issues.isNotEmpty) _issues = _validatedIssues(_draft);
  }

  void replaceInitialDraft(ProjectFormDraft draft) {
    _initialDraft = draft;
    applyDraft(draft, clearIssues: true);
  }

  void reset() {
    applyDraft(_initialDraft, clearIssues: true);
  }

  void applyDraft(ProjectFormDraft draft, {required bool clearIssues}) {
    _draft = draft;
    _issues = clearIssues ? const [] : _validatedIssues(_draft);
  }

  ProjectFormSubmitAttempt submit() {
    final issues = _validatedIssues(_draft);
    _issues = issues;

    return ProjectFormSubmitAttempt(draft: _draft, issues: issues);
  }

  List<ProjectFormIssue> _validatedIssues(ProjectFormDraft draft) {
    return List.unmodifiable(_validationService.validate(draft));
  }
}

/// Result of a project form submit attempt with the validated draft and issues.
class ProjectFormSubmitAttempt {
  const ProjectFormSubmitAttempt({required this.draft, required this.issues});

  final ProjectFormDraft draft;
  final List<ProjectFormIssue> issues;

  bool get canSubmit => issues.isEmpty;
}
