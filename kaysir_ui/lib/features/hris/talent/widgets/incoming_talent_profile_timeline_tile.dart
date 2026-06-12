import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:intl/intl.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_profile_timeline_models.dart';
import 'talent_meta_label.dart';

class IncomingTalentProfileTimelineTile extends StatelessWidget {
  final IncomingTalentProfileTimeline timeline;

  const IncomingTalentProfileTimelineTile({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    final color =
        timeline.needsAttention
            ? const Color(0xFFD97706)
            : const Color(0xFF059669);

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: HrisColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeline.candidateName,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: HrisColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      timeline.role,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
              ),
              HrisStatusPill(
                label: timeline.latestCalibrationDecisionLabel,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          HrisProgressBar(
            value: timeline.readinessRatio,
            color: color,
            label:
                '${timeline.readinessScore}% readiness, ${timeline.confidenceScore}/5 confidence',
          ),
          const SizedBox(height: 10),
          Text(
            timeline.nextAction,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: HrisColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              TalentMetaLabel(
                icon: Icons.apartment_outlined,
                label: timeline.department,
              ),
              TalentMetaLabel(
                icon: Icons.task_alt_outlined,
                label: '${timeline.openTalentActionCount} open actions',
              ),
              TalentMetaLabel(
                icon: Icons.insights_outlined,
                label:
                    '${timeline.watchCareerSupportOutcomeCount} support outcomes',
              ),
              if (timeline.watchDevelopmentResolutionCount > 0)
                TalentMetaLabel(
                  icon: Icons.fact_check_outlined,
                  label:
                      '${timeline.watchDevelopmentResolutionCount} follow-up reviews',
                ),
              if (timeline.programMilestoneRevisionCount > 0)
                TalentMetaLabel(
                  icon: Icons.fact_check_outlined,
                  label:
                      '${timeline.programMilestoneRevisionCount} milestone revisions',
                ),
              if (timeline.programCompletionExtensionCount > 0)
                TalentMetaLabel(
                  icon: Icons.workspace_premium_outlined,
                  label:
                      '${timeline.programCompletionExtensionCount} completion extensions',
                ),
              if (timeline.watchPromotionFollowUpCount > 0)
                TalentMetaLabel(
                  icon: Icons.playlist_add_check_outlined,
                  label:
                      '${timeline.watchPromotionFollowUpCount} promotion follow-ups',
                ),
              if (timeline.watchPromotionResolutionCount > 0)
                TalentMetaLabel(
                  icon: Icons.fact_check_outlined,
                  label:
                      '${timeline.watchPromotionResolutionCount} promotion resolutions',
                ),
              if (timeline.watchPromotionStabilizationCount > 0)
                TalentMetaLabel(
                  icon: Icons.rate_review_outlined,
                  label:
                      '${timeline.watchPromotionStabilizationCount} promotion reviews',
                ),
              if (timeline.latestEventDate != null)
                TalentMetaLabel(
                  icon: Icons.event_available_outlined,
                  label: DateFormat('MMM d').format(timeline.latestEventDate!),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final event in timeline.events.take(4))
            _TimelineEventRow(event: event),
        ],
      ),
    );
  }
}

class _TimelineEventRow extends StatelessWidget {
  final IncomingTalentProfileTimelineEvent event;

  const _TimelineEventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = _eventColor(event.tone);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_eventIcon(event.type), size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: HrisColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d').format(event.eventDate),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    HrisStatusPill(label: event.type.label, color: color),
                    HrisStatusPill(label: event.statusLabel, color: color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _eventColor(IncomingTalentProfileTimelineEventTone tone) {
  return switch (tone) {
    IncomingTalentProfileTimelineEventTone.positive => const Color(0xFF059669),
    IncomingTalentProfileTimelineEventTone.neutral => const Color(0xFF2563EB),
    IncomingTalentProfileTimelineEventTone.watch => const Color(0xFFD97706),
    IncomingTalentProfileTimelineEventTone.critical => const Color(0xFFDC2626),
  };
}

IconData _eventIcon(IncomingTalentProfileTimelineEventType type) {
  return switch (type) {
    IncomingTalentProfileTimelineEventType.outcome => Icons.fact_check_outlined,
    IncomingTalentProfileTimelineEventType.roadmap => Icons.route_outlined,
    IncomingTalentProfileTimelineEventType.checkIn => Icons.forum_outlined,
    IncomingTalentProfileTimelineEventType.intervention =>
      Icons.build_circle_outlined,
    IncomingTalentProfileTimelineEventType.interventionOutcome =>
      Icons.health_and_safety_outlined,
    IncomingTalentProfileTimelineEventType.interventionOutcomeFollowUp =>
      Icons.add_task_outlined,
    IncomingTalentProfileTimelineEventType
        .interventionOutcomeFollowUpResolution =>
      Icons.fact_check_outlined,
    IncomingTalentProfileTimelineEventType.calibration => Icons.rule_outlined,
    IncomingTalentProfileTimelineEventType.careerSupportAction =>
      Icons.support_agent_outlined,
    IncomingTalentProfileTimelineEventType.careerSupportOutcome =>
      Icons.insights_outlined,
    IncomingTalentProfileTimelineEventType.programMilestone =>
      Icons.fact_check_outlined,
    IncomingTalentProfileTimelineEventType.programCompletion =>
      Icons.workspace_premium_outlined,
    IncomingTalentProfileTimelineEventType.promotionStabilization =>
      Icons.rate_review_outlined,
    IncomingTalentProfileTimelineEventType.promotionFollowUp =>
      Icons.playlist_add_check_outlined,
    IncomingTalentProfileTimelineEventType.promotionFollowUpResolution =>
      Icons.fact_check_outlined,
  };
}

@Preview(name: 'Talent profile timeline tile')
Widget incomingTalentProfileTimelineTilePreview() {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: IncomingTalentProfileTimelineTile(timeline: _previewTimeline),
      ),
    ),
  );
}

final _previewTimeline = IncomingTalentProfileTimeline(
  candidateId: 'candidate-preview',
  candidateName: 'Nadia Prameswari',
  role: 'Senior HRIS Analyst',
  department: 'People Operations',
  readinessScore: 86,
  confidenceScore: 4,
  openInterventionCount: 0,
  watchDevelopmentOutcomeCount: 0,
  openDevelopmentFollowUpCount: 0,
  watchDevelopmentFollowUpCount: 0,
  watchDevelopmentResolutionCount: 0,
  openCareerSupportCount: 0,
  watchCareerSupportOutcomeCount: 1,
  programMilestoneRevisionCount: 0,
  programCompletionExtensionCount: 0,
  watchPromotionStabilizationCount: 0,
  openPromotionFollowUpCount: 0,
  watchPromotionFollowUpCount: 0,
  watchPromotionResolutionCount: 1,
  latestCalibrationDecisionLabel: 'Accelerate growth',
  nextAction: 'Resolve 1 promotion resolution review.',
  events: [
    IncomingTalentProfileTimelineEvent(
      id: 'promotion-follow-up-resolution-preview',
      candidateId: 'candidate-preview',
      candidateName: 'Nadia Prameswari',
      role: 'People Operations Lead',
      department: 'People Operations',
      type: IncomingTalentProfileTimelineEventType.promotionFollowUpResolution,
      tone: IncomingTalentProfileTimelineEventTone.watch,
      title: 'Monitor',
      description: 'Keep one manager checkpoint before closing residual risk.',
      eventDate: DateTime(2026, 6, 10),
      statusLabel: '3/5 confidence',
    ),
    IncomingTalentProfileTimelineEvent(
      id: 'program-completion-preview',
      candidateId: 'candidate-preview',
      candidateName: 'Nadia Prameswari',
      role: 'Senior HRIS Analyst',
      department: 'People Operations',
      type: IncomingTalentProfileTimelineEventType.programCompletion,
      tone: IncomingTalentProfileTimelineEventTone.positive,
      title: 'Role-ready',
      description: 'Completed career accelerator with manager evidence.',
      eventDate: DateTime(2026, 6, 3),
      statusLabel: 'Advanced',
    ),
  ],
);
