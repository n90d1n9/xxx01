import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import 'project_status_update_preferences_service.dart';
import 'project_status_update_service.dart';

class ProjectStatusUpdateRecommendation {
  const ProjectStatusUpdateRecommendation({
    required this.vocabulary,
    required this.audience,
    required this.confidencePercent,
    required this.reasons,
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final ProjectStatusUpdateAudience audience;
  final int confidencePercent;
  final List<String> reasons;

  bool matches({
    required ProjectStatusUpdateVocabulary vocabulary,
    required ProjectStatusUpdateAudience audience,
  }) {
    return this.vocabulary == vocabulary && this.audience == audience;
  }
}

ProjectStatusUpdateRecommendation recommendProjectStatusUpdateProfile({
  required ProjectPortfolioItem project,
  required List<gantt.GanttTask> timelineTasks,
  List<ProjectStatusUpdateVocabulary> availableVocabularies =
      ProjectStatusUpdateVocabulary.defaults,
  List<ProjectStatusUpdateAudience> availableAudiences =
      ProjectStatusUpdateAudience.values,
}) {
  final vocabularies =
      availableVocabularies.isEmpty
          ? ProjectStatusUpdateVocabulary.defaults
          : availableVocabularies;
  final audiences =
      availableAudiences.isEmpty
          ? ProjectStatusUpdateAudience.values
          : availableAudiences;
  final corpus = _ProjectSignalCorpus.fromProject(
    project: project,
    timelineTasks: timelineTasks,
  );
  final scoredDomains = [
    for (final vocabulary in vocabularies)
      _scoreVocabulary(vocabulary: vocabulary, corpus: corpus),
  ]..sort((a, b) => b.score.compareTo(a.score));
  final bestDomain =
      scoredDomains.isEmpty
          ? _ScoredVocabulary(
            vocabulary: ProjectStatusUpdateVocabulary.general,
            score: 0,
            matches: const [],
          )
          : scoredDomains.first;
  final vocabulary = resolveStatusUpdateVocabulary(
    availableVocabularies: vocabularies,
    vocabularyId:
        bestDomain.score <= 0
            ? ProjectStatusUpdateVocabulary.general.id
            : bestDomain.vocabulary.id,
  );
  final audience = resolveStatusUpdateAudience(
    availableAudiences: audiences,
    audienceId: _recommendedAudienceId(
      project: project,
      vocabulary: vocabulary,
      corpus: corpus,
    ),
  );

  return ProjectStatusUpdateRecommendation(
    vocabulary: vocabulary,
    audience: audience,
    confidencePercent: _confidenceFor(bestDomain.score),
    reasons: List.unmodifiable(
      _recommendationReasons(
        project: project,
        vocabulary: vocabulary,
        audience: audience,
        matchedSignals: bestDomain.matches,
      ),
    ),
  );
}

_ScoredVocabulary _scoreVocabulary({
  required ProjectStatusUpdateVocabulary vocabulary,
  required _ProjectSignalCorpus corpus,
}) {
  final signal = _domainSignals[vocabulary.id];
  if (signal == null) {
    return _ScoredVocabulary(
      vocabulary: vocabulary,
      score: vocabulary == ProjectStatusUpdateVocabulary.general ? 1 : 0,
      matches: const [],
    );
  }

  var score = 0;
  final matches = <String>[];
  for (final keyword in signal.keywords) {
    if (corpus.contains(keyword)) {
      score += keyword.contains(' ') ? 2 : 1;
      matches.add(keyword);
    }
  }

  return _ScoredVocabulary(
    vocabulary: vocabulary,
    score: score,
    matches: matches,
  );
}

String _recommendedAudienceId({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required _ProjectSignalCorpus corpus,
}) {
  if (vocabulary == ProjectStatusUpdateVocabulary.wedding ||
      vocabulary == ProjectStatusUpdateVocabulary.eventProduction) {
    return ProjectStatusUpdateAudience.client.id;
  }

  if (project.health != ProjectHealth.onTrack ||
      project.budgetUsed - project.progress >= 0.15 ||
      project.risks.any((risk) => risk.severity == ProjectHealth.blocked)) {
    return ProjectStatusUpdateAudience.sponsor.id;
  }

  if (vocabulary == ProjectStatusUpdateVocabulary.software &&
      (corpus.contains('engineer') ||
          corpus.contains('qa') ||
          corpus.contains('developer') ||
          corpus.contains('sprint'))) {
    return ProjectStatusUpdateAudience.team.id;
  }

  if (vocabulary == ProjectStatusUpdateVocabulary.retailOperations &&
      (corpus.contains('store') ||
          corpus.contains('launch wave') ||
          corpus.contains('rollout'))) {
    return ProjectStatusUpdateAudience.team.id;
  }

  return ProjectStatusUpdateAudience.stakeholder.id;
}

int _confidenceFor(int score) {
  if (score <= 0) return 48;

  return (58 + score * 7).clamp(58, 95).toInt();
}

List<String> _recommendationReasons({
  required ProjectPortfolioItem project,
  required ProjectStatusUpdateVocabulary vocabulary,
  required ProjectStatusUpdateAudience audience,
  required List<String> matchedSignals,
}) {
  final reasons = <String>[];
  if (matchedSignals.isEmpty) {
    reasons.add('General project language fits the available signals.');
  } else {
    reasons.add(
      '${vocabulary.label} signals: ${matchedSignals.take(3).join(', ')}.',
    );
  }

  if (audience == ProjectStatusUpdateAudience.client) {
    reasons.add('Client-facing update intent.');
  } else if (audience == ProjectStatusUpdateAudience.sponsor) {
    reasons.add(
      project.health == ProjectHealth.onTrack
          ? 'Budget or risk attention needs sponsor visibility.'
          : '${project.health.label} work needs sponsor visibility.',
    );
  } else if (audience == ProjectStatusUpdateAudience.team) {
    reasons.add('Execution-team wording fits the delivery signals.');
  }

  return reasons;
}

class _ProjectSignalCorpus {
  const _ProjectSignalCorpus(this.text);

  final String text;

  factory _ProjectSignalCorpus.fromProject({
    required ProjectPortfolioItem project,
    required List<gantt.GanttTask> timelineTasks,
  }) {
    return _ProjectSignalCorpus(
      [
        project.id,
        project.name,
        project.client,
        project.businessDomain,
        project.sponsor,
        project.owner,
        project.summary,
        for (final attribute in project.customAttributes) ...[
          attribute.key,
          attribute.label,
          attribute.displayValue,
        ],
        for (final milestone in project.milestones) milestone.label,
        for (final risk in project.risks) ...[risk.title, risk.detail],
        for (final member in project.team) ...[member.name, member.role],
        for (final task in timelineTasks) task.title,
      ].join(' ').toLowerCase(),
    );
  }

  bool contains(String keyword) => text.contains(keyword.toLowerCase());
}

class _ScoredVocabulary {
  const _ScoredVocabulary({
    required this.vocabulary,
    required this.score,
    required this.matches,
  });

  final ProjectStatusUpdateVocabulary vocabulary;
  final int score;
  final List<String> matches;
}

class _DomainSignal {
  const _DomainSignal({required this.keywords});

  final List<String> keywords;
}

const _domainSignals = {
  'construction': _DomainSignal(
    keywords: [
      'construction',
      'site',
      'build',
      'contractor',
      'permit',
      'inspection',
      'mobilization',
      'civil',
      'safety',
      'work package',
      'phase gate',
    ],
  ),
  'software': _DomainSignal(
    keywords: [
      'software',
      'mobile',
      'api',
      'release',
      'sprint',
      'developer',
      'engineer',
      'qa',
      'ux',
      'offline',
      'integration',
      'product',
      'cache',
    ],
  ),
  'event-production': _DomainSignal(
    keywords: [
      'event',
      'show',
      'production',
      'stage',
      'venue',
      'artist',
      'run sheet',
      'run-of-show',
      'music',
      'ticket',
      'crew',
    ],
  ),
  'government': _DomainSignal(
    keywords: [
      'government',
      'public',
      'program',
      'policy',
      'compliance',
      'approval',
      'ministry',
      'agency',
      'regulation',
      'governance',
    ],
  ),
  'education': _DomainSignal(
    keywords: [
      'education',
      'school',
      'academic',
      'student',
      'teacher',
      'learning',
      'curriculum',
      'campus',
      'class',
      'training',
    ],
  ),
  'wedding': _DomainSignal(
    keywords: [
      'wedding',
      'planner',
      'venue',
      'vendor',
      'catering',
      'guest',
      'ceremony',
      'reception',
      'family committee',
      'client planning',
    ],
  ),
  'retail-operations': _DomainSignal(
    keywords: [
      'retail',
      'store',
      'store cluster',
      'store rollout',
      'launch wave',
      'sku',
      'skus',
      'omnichannel',
      'merchandising',
      'pos',
      'inventory',
      'branch',
      'rollout',
    ],
  ),
};
