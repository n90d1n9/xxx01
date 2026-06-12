import 'package:flutter/material.dart';
import 'package:kaysir/widgets/ui/app_action_button.dart';

import '../services/project_domain_gap_repair_domain_mix_service.dart';
import '../services/project_domain_gap_repair_field_type_mix_service.dart';
import '../services/project_domain_gap_repair_project_cluster_service.dart';
import '../services/project_domain_gap_repair_service.dart';
import 'project_domain_gap_repair_domain_mix_strip.dart';
import 'project_domain_gap_repair_field_type_mix_strip.dart';
import 'project_domain_gap_repair_focus_bar.dart';
import 'project_domain_gap_repair_project_cluster_strip.dart';
import 'project_domain_gap_repair_queue_header.dart';
import 'project_domain_gap_repair_session_overview.dart';
import 'project_domain_gap_repair_target_row.dart';

class ProjectDomainGapRepairQueue extends StatefulWidget {
  ProjectDomainGapRepairQueue({
    required List<ProjectDomainGapRepairTarget> targets,
    required this.onRepair,
    this.onFocusPriority,
    super.key,
  }) : plan = ProjectDomainGapRepairPlan.fromTargets(targets);

  const ProjectDomainGapRepairQueue.fromPlan({
    required this.plan,
    required this.onRepair,
    this.onFocusPriority,
    super.key,
  });

  final ProjectDomainGapRepairPlan plan;
  final ValueChanged<ProjectDomainGapRepairTarget> onRepair;
  final ValueChanged<ProjectDomainGapRepairPriority>? onFocusPriority;

  @override
  State<ProjectDomainGapRepairQueue> createState() =>
      _ProjectDomainGapRepairQueueState();
}

class _ProjectDomainGapRepairQueueState
    extends State<ProjectDomainGapRepairQueue> {
  var _isExpanded = false;

  List<ProjectDomainGapRepairTarget> get _targets =>
      _isExpanded ? widget.plan.allTargets : widget.plan.visibleTargets;

  @override
  Widget build(BuildContext context) {
    if (widget.plan.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final targets = _targets;
    final domainMixSummary = buildProjectDomainGapRepairDomainMixSummary(
      plan: widget.plan,
    );
    final fieldTypeMixSummary = buildProjectDomainGapRepairFieldTypeMixSummary(
      plan: widget.plan,
    );
    final projectClusterSummary =
        buildProjectDomainGapRepairProjectClusterSummary(plan: widget.plan);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          primary: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProjectDomainGapRepairQueueHeader(
                plan: widget.plan,
                isExpanded: _isExpanded,
              ),
              const SizedBox(height: 10),
              ProjectDomainGapRepairSessionOverview(
                plan: widget.plan,
                onRepair: widget.onRepair,
              ),
              if (domainMixSummary.hasMix) ...[
                const SizedBox(height: 10),
                ProjectDomainGapRepairDomainMixStrip(
                  summary: domainMixSummary,
                  onRepair: widget.onRepair,
                ),
              ],
              if (fieldTypeMixSummary.hasMix) ...[
                const SizedBox(height: 10),
                ProjectDomainGapRepairFieldTypeMixStrip(
                  summary: fieldTypeMixSummary,
                  onRepair: widget.onRepair,
                ),
              ],
              if (projectClusterSummary.hasClusters) ...[
                const SizedBox(height: 10),
                ProjectDomainGapRepairProjectClusterStrip(
                  summary: projectClusterSummary,
                  onRepair: widget.onRepair,
                ),
              ],
              if (widget.onFocusPriority != null &&
                  ProjectDomainGapRepairFocusBar.hasActionsFor(
                    widget.plan,
                  )) ...[
                const SizedBox(height: 10),
                ProjectDomainGapRepairFocusBar(
                  plan: widget.plan,
                  onFocusPriority: widget.onFocusPriority!,
                ),
              ],
              const SizedBox(height: 10),
              for (var index = 0; index < targets.length; index++) ...[
                ProjectDomainGapRepairTargetRow(
                  target: targets[index],
                  onRepair: () => widget.onRepair(targets[index]),
                ),
                if (index != targets.length - 1)
                  Divider(
                    height: 16,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
              ],
              if (widget.plan.hasHiddenTargets) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppActionButton(
                    key: const ValueKey('project-domain-gap-repair-toggle'),
                    label:
                        _isExpanded
                            ? 'Show Top Fixes'
                            : 'Show All ${widget.plan.totalTargetCount}',
                    icon:
                        _isExpanded
                            ? Icons.unfold_less_rounded
                            : Icons.unfold_more_rounded,
                    variant: AppActionButtonVariant.text,
                    compact: true,
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
