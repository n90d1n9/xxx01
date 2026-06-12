import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/question.dart';
import '../../models/survey_evidence.dart';
import '../../models/survey_evidence_requirement.dart';
import 'evidence_requirement_constraint_fields.dart';
import 'evidence_requirement_form_helpers.dart';

class EvidenceRequirementDialog extends StatefulWidget {
  final SurveyEvidenceRequirement? requirement;
  final List<Question> questions;
  final ValueChanged<SurveyEvidenceRequirement> onSaved;

  const EvidenceRequirementDialog({
    super.key,
    required this.requirement,
    required this.questions,
    required this.onSaved,
  });

  @override
  State<EvidenceRequirementDialog> createState() =>
      _EvidenceRequirementDialogState();
}

class _EvidenceRequirementDialogState extends State<EvidenceRequirementDialog> {
  late SurveyEvidenceKind _kind;
  late SurveyEvidenceScope _scope;
  late String? _questionId;
  late bool _required;
  late bool _requireUploaded;
  late final TextEditingController _labelController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _minCountController;
  late final TextEditingController _maxSizeController;
  late final TextEditingController _minDurationController;
  late final TextEditingController _maxAccuracyController;

  @override
  void initState() {
    super.initState();
    final requirement = widget.requirement;
    final hasQuestions = widget.questions.isNotEmpty;
    _kind = requirement?.kind ?? SurveyEvidenceKind.location;
    _scope = hasQuestions
        ? requirement?.scope ?? SurveyEvidenceScope.response
        : SurveyEvidenceScope.response;
    _questionId = _validQuestionId(requirement?.questionId);
    _required = requirement?.required ?? true;
    _requireUploaded = requirement?.requireUploaded ?? false;
    _labelController = TextEditingController(text: requirement?.label ?? '');
    _instructionsController = TextEditingController(
      text: requirement?.instructions ?? '',
    );
    _minCountController = TextEditingController(
      text: (requirement?.minCount ?? 1).toString(),
    );
    _maxSizeController = TextEditingController(
      text: bytesToMegabytesText(requirement?.maxAttachmentSizeBytes),
    );
    _minDurationController = TextEditingController(
      text: millisecondsToSecondsText(
        requirement?.minAudioDurationMilliseconds,
      ),
    );
    _maxAccuracyController = TextEditingController(
      text: compactNumberText(requirement?.maxLocationAccuracyMeters),
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _instructionsController.dispose();
    _minCountController.dispose();
    _maxSizeController.dispose();
    _minDurationController.dispose();
    _maxAccuracyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.requirement == null ? 'Add Evidence' : 'Edit Evidence',
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _kindPicker()),
                  const SizedBox(width: 12),
                  Expanded(child: _scopePicker()),
                ],
              ),
              if (_scope == SurveyEvidenceScope.question) ...[
                const SizedBox(height: 12),
                _questionPicker(),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _minCountController,
                decoration: const InputDecoration(
                  labelText: 'Minimum captures',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Required before submit'),
                value: _required,
                onChanged: (value) => setState(() => _required = value),
              ),
              if (_kind != SurveyEvidenceKind.location)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Require uploaded media'),
                  value: _requireUploaded,
                  onChanged: (value) =>
                      setState(() => _requireUploaded = value),
                ),
              EvidenceRequirementConstraintFields(
                kind: _kind,
                maxSizeController: _maxSizeController,
                minDurationController: _minDurationController,
                maxAccuracyController: _maxAccuracyController,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _kindPicker() {
    return DropdownButtonFormField<SurveyEvidenceKind>(
      initialValue: _kind,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Evidence type',
        border: OutlineInputBorder(),
      ),
      items: SurveyEvidenceKind.values.map((kind) {
        return DropdownMenuItem(
          value: kind,
          child: Text(evidenceKindLabel(kind)),
        );
      }).toList(),
      onChanged: (kind) {
        if (kind == null) {
          return;
        }
        setState(() {
          _kind = kind;
          if (_kind == SurveyEvidenceKind.location) {
            _requireUploaded = false;
          }
        });
      },
    );
  }

  Widget _scopePicker() {
    final scopes = [
      SurveyEvidenceScope.response,
      if (widget.questions.isNotEmpty) SurveyEvidenceScope.question,
    ];

    return DropdownButtonFormField<SurveyEvidenceScope>(
      initialValue: _scope,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Scope',
        border: OutlineInputBorder(),
      ),
      items: scopes.map((scope) {
        return DropdownMenuItem(
          value: scope,
          child: Text(evidenceScopeLabel(scope)),
        );
      }).toList(),
      onChanged: (scope) {
        if (scope == null) {
          return;
        }
        setState(() {
          _scope = scope;
          if (_scope == SurveyEvidenceScope.question) {
            _questionId ??= widget.questions.first.id;
          }
        });
      },
    );
  }

  Widget _questionPicker() {
    return DropdownButtonFormField<String>(
      initialValue: _validQuestionId(_questionId) ?? widget.questions.first.id,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Question',
        border: OutlineInputBorder(),
      ),
      items: widget.questions.map((question) {
        return DropdownMenuItem(
          value: question.id,
          child: Text(
            _questionLabel(question),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (questionId) => setState(() => _questionId = questionId),
    );
  }

  void _save() {
    final minCount = int.tryParse(_minCountController.text.trim()) ?? 1;
    if (minCount <= 0) {
      _showError('Minimum captures must be at least 1');
      return;
    }

    String? questionId;
    if (_scope == SurveyEvidenceScope.question) {
      questionId = _validQuestionId(_questionId);
      if (questionId == null) {
        _showError('Choose a question for question-level evidence');
        return;
      }
    }

    final requirement = SurveyEvidenceRequirement(
      id: widget.requirement?.id ?? const Uuid().v4(),
      kind: _kind,
      scope: _scope,
      questionId: questionId,
      label: _labelController.text.trim(),
      instructions: _instructionsController.text.trim(),
      minCount: minCount,
      required: _required,
      requireUploaded: _kind == SurveyEvidenceKind.location
          ? false
          : _requireUploaded,
      maxAttachmentSizeBytes: _kind == SurveyEvidenceKind.location
          ? null
          : megabytesToBytes(_maxSizeController.text),
      minAudioDurationMilliseconds: _kind == SurveyEvidenceKind.audio
          ? secondsToMilliseconds(_minDurationController.text)
          : null,
      maxLocationAccuracyMeters: _kind == SurveyEvidenceKind.location
          ? positiveDouble(_maxAccuracyController.text)
          : null,
    );

    widget.onSaved(requirement);
    Navigator.of(context).pop();
  }

  String? _validQuestionId(String? questionId) {
    if (questionId == null) {
      return null;
    }

    return widget.questions.any((question) => question.id == questionId)
        ? questionId
        : null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _questionLabel(Question question) {
    return evidenceQuestionLabel(question);
  }
}
