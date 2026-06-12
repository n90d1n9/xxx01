import 'package:flutter/material.dart';

import '../logic/survey_response_question_status.dart';
import '../logic/survey_response_section_flow.dart';
import '../models/question.dart';
import '../validation/survey_response_validator.dart';
import 'survey_response_question_card.dart';
import 'survey_response_question_status_map.dart';
import 'survey_response_section_header.dart';

typedef SurveyResponseQuestionValueResolver =
    dynamic Function(String questionId);

typedef SurveyResponseQuestionIssuesResolver =
    List<SurveyResponseValidationIssue> Function(String questionId);

typedef SurveyResponseQuestionAnswerChanged =
    void Function(Question question, dynamic value);

/// Renders one response section with question status, focus, and fields.
class SurveyResponseSectionQuestionList extends StatefulWidget {
  final SurveyResponseSectionPage page;
  final SurveyResponseSectionPageStatus? status;
  final String? focusedQuestionId;
  final Object? focusRequestKey;
  final SurveyResponseQuestionValueResolver valueForQuestion;
  final SurveyResponseQuestionIssuesResolver issuesForQuestion;
  final SurveyResponseQuestionAnswerChanged onAnswerChanged;

  const SurveyResponseSectionQuestionList({
    super.key,
    required this.page,
    required this.valueForQuestion,
    required this.issuesForQuestion,
    required this.onAnswerChanged,
    this.status,
    this.focusedQuestionId,
    this.focusRequestKey,
  });

  @override
  State<SurveyResponseSectionQuestionList> createState() =>
      _SurveyResponseSectionQuestionListState();
}

/// Manages per-question focus keys for a reusable response section list.
class _SurveyResponseSectionQuestionListState
    extends State<SurveyResponseSectionQuestionList> {
  String? _selectedQuestionId;
  final Map<String, GlobalKey> _questionKeys = {};

  @override
  void initState() {
    super.initState();
    _selectedQuestionId = _visibleQuestionId(widget.focusedQuestionId);
    _scheduleFocus(_selectedQuestionId);
  }

  @override
  void didUpdateWidget(covariant SurveyResponseSectionQuestionList oldWidget) {
    super.didUpdateWidget(oldWidget);

    final pageChanged =
        _pageSignature(oldWidget.page) != _pageSignature(widget.page);
    final focusChanged =
        pageChanged ||
        oldWidget.focusedQuestionId != widget.focusedQuestionId ||
        oldWidget.focusRequestKey != widget.focusRequestKey;

    if (pageChanged) {
      _questionKeys.clear();
    }

    if (focusChanged) {
      _selectedQuestionId = _visibleQuestionId(widget.focusedQuestionId);
      _scheduleFocus(_selectedQuestionId);
      return;
    }

    if (_selectedQuestionId != null &&
        !widget.page.questions.any(
          (question) => question.id == _selectedQuestionId,
        )) {
      _selectedQuestionId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status =
        widget.status ??
        SurveyResponseSectionPageStatus(page: widget.page, issues: const []);
    final questionStatusSummary =
        SurveyResponseQuestionStatusSummary.fromPageStatus(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurveyResponseSectionHeader(page: widget.page, status: status),
        if (questionStatusSummary.hasItems) ...[
          const SizedBox(height: 12),
          SurveyResponseQuestionStatusMap(
            summary: questionStatusSummary,
            selectedQuestionId: _selectedQuestionId,
            onQuestionSelected: _focusQuestion,
          ),
        ],
        const SizedBox(height: 16),
        ...widget.page.questions.asMap().entries.map((entry) {
          final question = entry.value;
          return SurveyResponseQuestionCard(
            key: _questionKey(question.id),
            questionNumber: widget.page.questionNumberAt(entry.key),
            question: question.withAnswer(widget.valueForQuestion(question.id)),
            highlighted: _selectedQuestionId == question.id,
            issues: widget.issuesForQuestion(question.id),
            onAnswerChanged: (value) {
              widget.onAnswerChanged(question, value);
            },
          );
        }),
      ],
    );
  }

  GlobalKey _questionKey(String questionId) {
    return _questionKeys.putIfAbsent(questionId, () => GlobalKey());
  }

  void _focusQuestion(String questionId) {
    setState(() => _selectedQuestionId = questionId);
    _scheduleFocus(questionId);
  }

  void _scheduleFocus(String? questionId) {
    if (questionId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedQuestionId != questionId) {
        return;
      }

      _ensureQuestionVisible(questionId);
    });
  }

  void _ensureQuestionVisible(String questionId) {
    final questionContext = _questionKeys[questionId]?.currentContext;
    if (questionContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      questionContext,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  String? _visibleQuestionId(String? questionId) {
    if (questionId == null) {
      return null;
    }

    final isVisible = widget.page.questions.any(
      (question) => question.id == questionId,
    );
    return isVisible ? questionId : null;
  }

  String _pageSignature(SurveyResponseSectionPage page) {
    return page.questions.map((question) => question.id).join('|');
  }
}
