import 'package:flutter/material.dart';

import '../services/project_domain_extension_intake_plan_service.dart';

class ProjectDomainExtensionIntakePlanStrip extends StatelessWidget {
  const ProjectDomainExtensionIntakePlanStrip({
    required this.plan,
    required this.onFocusField,
    super.key,
  });

  final ProjectDomainExtensionIntakePlan plan;
  final ValueChanged<String> onFocusField;

  @override
  Widget build(BuildContext context) {
    if (plan.lanes.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 720.0;
        const gap = 8.0;
        final columnCount =
            availableWidth >= 860
                ? 4
                : availableWidth >= 560
                ? 2
                : 1;
        final tileWidth =
            (availableWidth - (gap * (columnCount - 1))) / columnCount;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final lane in plan.lanes)
              SizedBox(
                width: tileWidth,
                child: _ProjectDomainExtensionIntakeLaneTile(
                  lane: lane,
                  onFocusField: onFocusField,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProjectDomainExtensionIntakeLaneTile extends StatelessWidget {
  const _ProjectDomainExtensionIntakeLaneTile({
    required this.lane,
    required this.onFocusField,
  });

  final ProjectDomainExtensionIntakeLane lane;
  final ValueChanged<String> onFocusField;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tone = _toneColor(colorScheme);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: tone.withValues(alpha: 0.28)),
    );

    final content = Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon(), color: tone, size: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lane.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lane.metricLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (lane.canFocusField)
                Icon(Icons.center_focus_strong_outlined, color: tone, size: 17),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: lane.completionRatio,
              minHeight: 5,
              color: tone,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            lane.detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: lane.hasGaps ? tone : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Material(
      key: ValueKey('project-domain-extension-intake-lane-${lane.id}'),
      color: colorScheme.surfaceContainerLow,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child:
          lane.canFocusField
              ? InkWell(
                customBorder: shape,
                onTap: () => onFocusField(lane.focusFieldKey!),
                child: content,
              )
              : content,
    );
  }

  IconData _icon() {
    switch (lane.kind) {
      case ProjectDomainExtensionIntakeLaneKind.requiredContext:
        return Icons.priority_high_rounded;
      case ProjectDomainExtensionIntakeLaneKind.riskWatch:
        return Icons.sensors_outlined;
      case ProjectDomainExtensionIntakeLaneKind.recommendedContext:
        return Icons.fact_check_outlined;
      case ProjectDomainExtensionIntakeLaneKind.customContext:
        return Icons.extension_outlined;
    }
  }

  Color _toneColor(ColorScheme colorScheme) {
    switch (lane.kind) {
      case ProjectDomainExtensionIntakeLaneKind.requiredContext:
        return colorScheme.error;
      case ProjectDomainExtensionIntakeLaneKind.riskWatch:
        return colorScheme.tertiary;
      case ProjectDomainExtensionIntakeLaneKind.recommendedContext:
        return colorScheme.primary;
      case ProjectDomainExtensionIntakeLaneKind.customContext:
        return colorScheme.secondary;
    }
  }
}
