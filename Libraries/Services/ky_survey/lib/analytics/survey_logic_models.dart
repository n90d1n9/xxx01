import '../models/question.dart';
import '../models/question_visibility_rule.dart';

class SurveyLogicQuestionSummary {
  final Question question;
  final int dependencyCount;
  final int dependentQuestionCount;
  final int dependencyDepth;
  final List<SurveyLogicIssue> issues;

  const SurveyLogicQuestionSummary({
    required this.question,
    required this.dependencyCount,
    required this.dependentQuestionCount,
    required this.dependencyDepth,
    required this.issues,
  });

  bool get isConditional => dependencyCount > 0;

  bool get hasIssues => issues.isNotEmpty;
}

class SurveyLogicSectionSummary {
  final String id;
  final String title;
  final int questionCount;
  final int conditionalQuestionCount;
  final int visibilityRuleCount;
  final int issueCount;
  final int maxDependencyDepth;

  const SurveyLogicSectionSummary({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.conditionalQuestionCount,
    required this.visibilityRuleCount,
    required this.issueCount,
    required this.maxDependencyDepth,
  });
}

class SurveyLogicIssue {
  final SurveyLogicIssueType type;
  final SurveyLogicIssueSeverity severity;
  final Question question;
  final Question? sourceQuestion;
  final QuestionVisibilityRule? rule;
  final String message;

  const SurveyLogicIssue({
    required this.type,
    required this.severity,
    required this.question,
    required this.message,
    this.sourceQuestion,
    this.rule,
  });

  const SurveyLogicIssue.blocker({
    required SurveyLogicIssueType type,
    required Question question,
    required String message,
    Question? sourceQuestion,
    QuestionVisibilityRule? rule,
  }) : this(
         type: type,
         severity: SurveyLogicIssueSeverity.blocker,
         question: question,
         sourceQuestion: sourceQuestion,
         rule: rule,
         message: message,
       );

  const SurveyLogicIssue.warning({
    required SurveyLogicIssueType type,
    required Question question,
    required String message,
    Question? sourceQuestion,
    QuestionVisibilityRule? rule,
  }) : this(
         type: type,
         severity: SurveyLogicIssueSeverity.warning,
         question: question,
         sourceQuestion: sourceQuestion,
         rule: rule,
         message: message,
       );
}

enum SurveyLogicIssueSeverity { blocker, warning }

enum SurveyLogicIssueType {
  missingSource,
  selfDependency,
  forwardDependency,
  incompleteValue,
  numericOnNonNumeric,
  optionValueMismatch,
  cycle,
}
