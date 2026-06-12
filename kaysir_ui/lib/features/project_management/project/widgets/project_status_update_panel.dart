import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';
import 'package:kaysir/widgets/ui/app_filter_chip_group.dart';
import 'package:kaysir/widgets/ui/app_info_row.dart';
import 'package:kaysir/widgets/ui/app_metric_grid.dart';
import 'package:kaysir/widgets/ui/app_status_pill.dart';

import '../../gantt/gantt_dashboard.dart' as gantt;
import '../models/project_portfolio_item.dart';
import '../services/project_status_update_preferences_service.dart';
import '../services/project_status_update_recommendation_service.dart';
import '../services/project_status_update_service.dart';
import 'project_status_update_draft_card.dart';

class ProjectStatusUpdateComposerPanel extends StatefulWidget {
  const ProjectStatusUpdateComposerPanel({
    required this.project,
    required this.timelineTasks,
    this.dependencyTasks,
    this.availableVocabularies = ProjectStatusUpdateVocabulary.defaults,
    this.availableAudiences = const [
      ProjectStatusUpdateAudience.stakeholder,
      ProjectStatusUpdateAudience.sponsor,
      ProjectStatusUpdateAudience.team,
      ProjectStatusUpdateAudience.client,
    ],
    this.initialVocabulary = ProjectStatusUpdateVocabulary.general,
    this.initialAudience = ProjectStatusUpdateAudience.stakeholder,
    this.selectedVocabulary,
    this.selectedAudience,
    this.onVocabularyChanged,
    this.onAudienceChanged,
    this.showRecommendation = true,
    this.today,
    super.key,
  });

  final ProjectPortfolioItem project;
  final List<gantt.GanttTask> timelineTasks;
  final List<gantt.GanttTask>? dependencyTasks;
  final List<ProjectStatusUpdateVocabulary> availableVocabularies;
  final List<ProjectStatusUpdateAudience> availableAudiences;
  final ProjectStatusUpdateVocabulary initialVocabulary;
  final ProjectStatusUpdateAudience initialAudience;
  final ProjectStatusUpdateVocabulary? selectedVocabulary;
  final ProjectStatusUpdateAudience? selectedAudience;
  final ValueChanged<ProjectStatusUpdateVocabulary>? onVocabularyChanged;
  final ValueChanged<ProjectStatusUpdateAudience>? onAudienceChanged;
  final bool showRecommendation;
  final DateTime? today;

  @override
  State<ProjectStatusUpdateComposerPanel> createState() =>
      _ProjectStatusUpdateComposerPanelState();
}

class _ProjectStatusUpdateComposerPanelState
    extends State<ProjectStatusUpdateComposerPanel> {
  late ProjectStatusUpdateVocabulary _vocabulary;
  late ProjectStatusUpdateAudience _audience;
  var _copiedDraft = false;

  @override
  void initState() {
    super.initState();
    _vocabulary = widget.selectedVocabulary ?? widget.initialVocabulary;
    _audience = widget.selectedAudience ?? widget.initialAudience;
  }

  @override
  void didUpdateWidget(ProjectStatusUpdateComposerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final vocabularies = _effectiveVocabularies;
    final selectedVocabulary = widget.selectedVocabulary;
    if (selectedVocabulary != null) {
      _vocabulary = resolveStatusUpdateVocabulary(
        availableVocabularies: vocabularies,
        vocabularyId: selectedVocabulary.id,
      );
    } else if (!vocabularies.contains(_vocabulary)) {
      _vocabulary = resolveStatusUpdateVocabulary(
        availableVocabularies: vocabularies,
        vocabularyId: widget.initialVocabulary.id,
      );
    }

    final audiences = _effectiveAudiences;
    final selectedAudience = widget.selectedAudience;
    if (selectedAudience != null) {
      _audience = resolveStatusUpdateAudience(
        availableAudiences: audiences,
        audienceId: selectedAudience.id,
      );
    } else if (!audiences.contains(_audience)) {
      _audience = resolveStatusUpdateAudience(
        availableAudiences: audiences,
        audienceId: widget.initialAudience.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocabularies = _effectiveVocabularies;
    final vocabulary = resolveStatusUpdateVocabulary(
      availableVocabularies: vocabularies,
      vocabularyId: (widget.selectedVocabulary ?? _vocabulary).id,
    );
    final audiences = _effectiveAudiences;
    final audience = resolveStatusUpdateAudience(
      availableAudiences: audiences,
      audienceId: (widget.selectedAudience ?? _audience).id,
    );
    final brief = buildProjectStatusUpdateBrief(
      project: widget.project,
      timelineTasks: widget.timelineTasks,
      dependencyTasks: widget.dependencyTasks,
      vocabulary: vocabulary,
      audience: audience,
      today: widget.today,
    );
    final recommendation = recommendProjectStatusUpdateProfile(
      project: widget.project,
      timelineTasks: widget.timelineTasks,
      availableVocabularies: vocabularies,
      availableAudiences: audiences,
    );
    final showRecommendation =
        widget.showRecommendation &&
        !recommendation.matches(vocabulary: vocabulary, audience: audience);
    final colorScheme = Theme.of(context).colorScheme;
    final signalColor = brief.signal.color(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showRecommendation) ...[
          _StatusUpdateRecommendationRow(
            recommendation: recommendation,
            onApply:
                _canApplyRecommendation
                    ? () => _applyRecommendation(recommendation)
                    : null,
          ),
          const SizedBox(height: 12),
        ],
        AppFilterChipGroup<ProjectStatusUpdateVocabulary>(
          value: vocabulary,
          options: [
            for (final vocabulary in vocabularies)
              AppFilterChipOption(
                value: vocabulary,
                label: vocabulary.label,
                icon: vocabulary.icon,
              ),
          ],
          onChanged: _changeVocabulary,
        ),
        const SizedBox(height: 8),
        AppFilterChipGroup<ProjectStatusUpdateAudience>(
          value: audience,
          options: [
            for (final audience in audiences)
              AppFilterChipOption(
                value: audience,
                label: audience.label,
                icon: audience.icon,
              ),
          ],
          onChanged: _changeAudience,
        ),
        const SizedBox(height: 12),
        AppInfoRow(
          title: brief.headline,
          subtitle: brief.summary,
          icon: brief.signal.icon,
          iconStyle: AppInfoRowIconStyle.badge,
          contained: true,
          iconBackgroundColor: signalColor.withValues(alpha: 0.12),
          iconForegroundColor: signalColor,
          titleMaxLines: 2,
          subtitleMaxLines: 3,
          trailing: AppStatusPill(
            label: brief.signal.label,
            icon: brief.signal.icon,
            color: signalColor,
            maxWidth: 150,
          ),
        ),
        const SizedBox(height: 12),
        AppMetricGrid(
          minTileWidth: 150,
          maxColumns: 4,
          metrics: [
            AppMetricGridItem(
              title: 'Progress',
              value: '${brief.progressPercent}%',
              icon: Icons.trending_up_rounded,
              accentColor: colorScheme.primary,
              helper: brief.vocabulary.workLabel,
            ),
            AppMetricGridItem(
              title: 'Schedule',
              value: '${brief.scheduleProgressPercent}%',
              icon: Icons.timeline_outlined,
              accentColor: colorScheme.primary,
              helper: brief.vocabulary.scheduleLabel,
            ),
            AppMetricGridItem(
              title: 'Budget',
              value: '${brief.budgetPercent}%',
              icon: Icons.account_balance_wallet_outlined,
              accentColor: Colors.indigo.shade600,
              helper: brief.vocabulary.budgetLabel,
            ),
            AppMetricGridItem(
              title: 'Readiness',
              value: '${brief.readinessScore}',
              icon: Icons.speed_outlined,
              accentColor: signalColor,
              helper: brief.vocabulary.readinessLabel,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatusUpdateSection(
          title: 'Highlights',
          icon: Icons.check_circle_outline,
          items: brief.highlights,
          color: Colors.green.shade700,
        ),
        const SizedBox(height: 10),
        _StatusUpdateSection(
          title: 'Watch Items',
          icon: Icons.visibility_outlined,
          items: brief.watchItems,
          color: signalColor,
        ),
        const SizedBox(height: 10),
        _StatusUpdateSection(
          title: 'Next Actions',
          icon: Icons.task_alt_outlined,
          items: brief.nextActions,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        ProjectStatusUpdateDraftCard(
          draftText: brief.draftText,
          copied: _copiedDraft,
          onCopy: () => _copyDraft(brief.draftText),
        ),
      ],
    );
  }

  List<ProjectStatusUpdateVocabulary> get _effectiveVocabularies {
    return widget.availableVocabularies.isEmpty
        ? ProjectStatusUpdateVocabulary.defaults
        : widget.availableVocabularies;
  }

  List<ProjectStatusUpdateAudience> get _effectiveAudiences {
    return widget.availableAudiences.isEmpty
        ? ProjectStatusUpdateAudience.values
        : widget.availableAudiences;
  }

  bool get _canApplyRecommendation {
    final canSetVocabulary =
        widget.selectedVocabulary == null || widget.onVocabularyChanged != null;
    final canSetAudience =
        widget.selectedAudience == null || widget.onAudienceChanged != null;

    return canSetVocabulary && canSetAudience;
  }

  void _applyRecommendation(ProjectStatusUpdateRecommendation recommendation) {
    final onVocabularyChanged = widget.onVocabularyChanged;
    final onAudienceChanged = widget.onAudienceChanged;
    final shouldUpdateLocalVocabulary = widget.selectedVocabulary == null;
    final shouldUpdateLocalAudience = widget.selectedAudience == null;
    final shouldSetState =
        _copiedDraft ||
        shouldUpdateLocalVocabulary ||
        shouldUpdateLocalAudience;

    if (shouldSetState) {
      setState(() {
        if (shouldUpdateLocalVocabulary) {
          _vocabulary = recommendation.vocabulary;
        }
        if (shouldUpdateLocalAudience) {
          _audience = recommendation.audience;
        }
        _copiedDraft = false;
      });
    }

    onVocabularyChanged?.call(recommendation.vocabulary);
    onAudienceChanged?.call(recommendation.audience);
  }

  void _changeVocabulary(ProjectStatusUpdateVocabulary vocabulary) {
    final onVocabularyChanged = widget.onVocabularyChanged;
    if (onVocabularyChanged != null) {
      if (_copiedDraft) setState(() => _copiedDraft = false);
      onVocabularyChanged(vocabulary);
      return;
    }

    setState(() {
      _vocabulary = vocabulary;
      _copiedDraft = false;
    });
  }

  void _changeAudience(ProjectStatusUpdateAudience audience) {
    final onAudienceChanged = widget.onAudienceChanged;
    if (onAudienceChanged != null) {
      if (_copiedDraft) setState(() => _copiedDraft = false);
      onAudienceChanged(audience);
      return;
    }

    setState(() {
      _audience = audience;
      _copiedDraft = false;
    });
  }

  Future<void> _copyDraft(String draftText) async {
    await Clipboard.setData(ClipboardData(text: draftText));
    if (!mounted) return;

    setState(() => _copiedDraft = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Status update copied')));
  }
}

class _StatusUpdateRecommendationRow extends StatelessWidget {
  const _StatusUpdateRecommendationRow({
    required this.recommendation,
    required this.onApply,
  });

  final ProjectStatusUpdateRecommendation recommendation;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final recommendationColor = colorScheme.tertiary;

    return AppInfoRow(
      title:
          'Suggested: ${recommendation.vocabulary.label} / ${recommendation.audience.label}',
      subtitle:
          '${recommendation.confidencePercent}% match - ${recommendation.reasons.join(' ')}',
      icon: Icons.auto_awesome_outlined,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: recommendationColor.withValues(alpha: 0.12),
      iconForegroundColor: recommendationColor,
      titleMaxLines: 2,
      subtitleMaxLines: 3,
      trailing: AppActionButton(
        label: 'Apply',
        icon: Icons.check_rounded,
        variant: AppActionButtonVariant.secondary,
        compact: true,
        height: 36,
        onPressed: onApply,
      ),
    );
  }
}

class _StatusUpdateSection extends StatelessWidget {
  const _StatusUpdateSection({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppInfoRow(
      title: title,
      subtitle: items.join('\n'),
      icon: icon,
      iconStyle: AppInfoRowIconStyle.badge,
      contained: true,
      iconBackgroundColor: color.withValues(alpha: 0.12),
      iconForegroundColor: color,
      titleMaxLines: 1,
      subtitleMaxLines: items.length.clamp(2, 4),
      subtitleOverflow: TextOverflow.ellipsis,
      trailing: AppStatusPill(
        label: items.length.toString(),
        icon: Icons.format_list_numbered_rounded,
        color: colorScheme.primary,
        maxWidth: 64,
      ),
    );
  }
}
