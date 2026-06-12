import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_career_framework_level_models.dart';
import '../states/incoming_talent_career_framework_level_provider.dart';
import 'incoming_talent_career_framework_level_fields.dart';
import 'incoming_talent_development_program_form_widgets.dart';

/// Form for defining role-family ladder levels and promotion evidence.
class IncomingTalentCareerFrameworkLevelForm extends ConsumerStatefulWidget {
  const IncomingTalentCareerFrameworkLevelForm({super.key});

  @override
  ConsumerState<IncomingTalentCareerFrameworkLevelForm> createState() =>
      _IncomingTalentCareerFrameworkLevelFormState();
}

class _IncomingTalentCareerFrameworkLevelFormState
    extends ConsumerState<IncomingTalentCareerFrameworkLevelForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _departmentController;
  late final TextEditingController _familyController;
  late final TextEditingController _levelCodeController;
  late final TextEditingController _roleController;
  late final TextEditingController _ownerController;
  late final TextEditingController _competencyController;
  late final TextEditingController _successController;
  late final TextEditingController _evidenceController;
  String? _selectedCareerPathId;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(incomingTalentCareerFrameworkLevelDraftProvider);
    _selectedCareerPathId =
        draft.sourceCareerPathId.isEmpty ? null : draft.sourceCareerPathId;
    _departmentController = TextEditingController(text: draft.department);
    _familyController = TextEditingController(text: draft.familyName);
    _levelCodeController = TextEditingController(text: draft.levelCode);
    _roleController = TextEditingController(text: draft.roleTitle);
    _ownerController = TextEditingController(text: draft.ownerName);
    _competencyController = TextEditingController(text: draft.competencyName);
    _successController = TextEditingController(text: draft.successCriteria);
    _evidenceController = TextEditingController(
      text: draft.evidenceRequirement,
    );
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _familyController.dispose();
    _levelCodeController.dispose();
    _roleController.dispose();
    _ownerController.dispose();
    _competencyController.dispose();
    _successController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final careerPaths = ref.watch(careerFrameworkReadyCareerPathsProvider);
    final draft = ref.watch(incomingTalentCareerFrameworkLevelDraftProvider);

    syncIncomingTalentDevelopmentProgramController(
      _departmentController,
      draft.department,
    );
    syncIncomingTalentDevelopmentProgramController(
      _familyController,
      draft.familyName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _levelCodeController,
      draft.levelCode,
    );
    syncIncomingTalentDevelopmentProgramController(
      _roleController,
      draft.roleTitle,
    );
    syncIncomingTalentDevelopmentProgramController(
      _ownerController,
      draft.ownerName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _competencyController,
      draft.competencyName,
    );
    syncIncomingTalentDevelopmentProgramController(
      _successController,
      draft.successCriteria,
    );
    syncIncomingTalentDevelopmentProgramController(
      _evidenceController,
      draft.evidenceRequirement,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IncomingTalentCareerFrameworkLevelCareerPathPicker(
            careerPaths: careerPaths,
            selectedCareerPathId: _selectedCareerPathId,
            onCareerPathChanged: _selectCareerPath,
          ),
          if (careerPaths.isEmpty) ...[
            const SizedBox(height: 12),
            const HrisListSurface(
              child: Text(
                'All visible career paths already have framework coverage.',
              ),
            ),
          ],
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramResponsiveRow(
            children: [
              IncomingTalentDevelopmentProgramTextInput(
                controller: _departmentController,
                label: 'Department',
                icon: Icons.apartment_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentCareerFrameworkLevelDraftProvider
                              .notifier,
                        )
                        .setDepartment,
                validator:
                    (value) => validateIncomingTalentCareerFrameworkRequired(
                      value,
                      'a department',
                    ),
              ),
              IncomingTalentDevelopmentProgramTextInput(
                controller: _familyController,
                label: 'Role family',
                icon: Icons.schema_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentCareerFrameworkLevelDraftProvider
                              .notifier,
                        )
                        .setFamilyName,
                validator:
                    (value) => validateIncomingTalentCareerFrameworkRequired(
                      value,
                      'a role family',
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramResponsiveRow(
            children: [
              IncomingTalentDevelopmentProgramTextInput(
                controller: _levelCodeController,
                label: 'Level code',
                icon: Icons.layers_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentCareerFrameworkLevelDraftProvider
                              .notifier,
                        )
                        .setLevelCode,
                validator: validateIncomingTalentCareerFrameworkLevelCode,
              ),
              IncomingTalentDevelopmentProgramTextInput(
                controller: _roleController,
                label: 'Role title',
                icon: Icons.badge_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentCareerFrameworkLevelDraftProvider
                              .notifier,
                        )
                        .setRoleTitle,
                validator:
                    (value) => validateIncomingTalentCareerFrameworkRequired(
                      value,
                      'a role title',
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramResponsiveRow(
            children: [
              IncomingTalentDevelopmentProgramTextInput(
                controller: _ownerController,
                label: 'Owner',
                icon: Icons.supervisor_account_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentCareerFrameworkLevelDraftProvider
                              .notifier,
                        )
                        .setOwnerName,
                validator:
                    (value) => validateIncomingTalentCareerFrameworkRequired(
                      value,
                      'an owner',
                    ),
              ),
              IncomingTalentDevelopmentProgramTextInput(
                controller: _competencyController,
                label: 'Competency',
                icon: Icons.psychology_outlined,
                onChanged:
                    ref
                        .read(
                          incomingTalentCareerFrameworkLevelDraftProvider
                              .notifier,
                        )
                        .setCompetencyName,
                validator: validateIncomingTalentCareerFrameworkFocus,
              ),
            ],
          ),
          const SizedBox(height: 12),
          IncomingTalentCareerFrameworkLevelClassificationFields(
            draft: draft,
            onScopeChanged:
                ref
                    .read(
                      incomingTalentCareerFrameworkLevelDraftProvider.notifier,
                    )
                    .setScope,
            onStatusChanged:
                ref
                    .read(
                      incomingTalentCareerFrameworkLevelDraftProvider.notifier,
                    )
                    .setStatus,
            onReviewCadenceChanged:
                ref
                    .read(
                      incomingTalentCareerFrameworkLevelDraftProvider.notifier,
                    )
                    .setReviewCadence,
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramTextInput(
            controller: _successController,
            label: 'Success criteria',
            icon: Icons.verified_outlined,
            minLines: 2,
            onChanged:
                ref
                    .read(
                      incomingTalentCareerFrameworkLevelDraftProvider.notifier,
                    )
                    .setSuccessCriteria,
            validator:
                (value) => validateIncomingTalentCareerFrameworkLongText(
                  value,
                  'success criteria',
                ),
          ),
          const SizedBox(height: 12),
          IncomingTalentDevelopmentProgramTextInput(
            controller: _evidenceController,
            label: 'Evidence requirement',
            icon: Icons.fact_check_outlined,
            minLines: 2,
            onChanged:
                ref
                    .read(
                      incomingTalentCareerFrameworkLevelDraftProvider.notifier,
                    )
                    .setEvidenceRequirement,
            validator:
                (value) => validateIncomingTalentCareerFrameworkLongText(
                  value,
                  'evidence requirement',
                ),
          ),
          const SizedBox(height: 10),
          IncomingTalentCareerFrameworkLevelFormActions(
            completionRatio: draft.completionRatio,
            canSubmit: draft.isReadyToSubmit,
            onClear: _clear,
            onSubmit: _submitLevel,
          ),
        ],
      ),
    );
  }

  void _selectCareerPath(String? value) {
    setState(() => _selectedCareerPathId = value);
    if (value == null) return;

    final careerPaths = ref.read(careerFrameworkReadyCareerPathsProvider);
    final careerPath = careerPaths.firstWhere((item) => item.id == value);
    ref
        .read(incomingTalentCareerFrameworkLevelDraftProvider.notifier)
        .initializeFromCareerPath(careerPath);
  }

  void _submitLevel() {
    final isValid = _formKey.currentState?.validate() == true;
    final draft = ref.read(incomingTalentCareerFrameworkLevelDraftProvider);
    if (!isValid || !draft.isReadyToSubmit) return;

    try {
      final level = ref
          .read(incomingTalentCareerFrameworkLevelsProvider.notifier)
          .submitDraft(draft);
      _clear();
      _showMessage('${level.id} added for ${level.roleTitle}');
    } on StateError catch (error) {
      _showMessage(error.message);
    }
  }

  void _clear() {
    ref.read(incomingTalentCareerFrameworkLevelDraftProvider.notifier).clear();
    setState(() => _selectedCareerPathId = null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@Preview(name: 'Talent career framework form')
Widget incomingTalentCareerFrameworkLevelFormPreview() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentCareerFrameworkLevelForm(),
        ),
      ),
    ),
  );
}
