import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_detail.dart';

class DashboardActionDetailPlaybook extends StatelessWidget {
  final List<DashboardActionPlaybookStep> steps;
  final int? activeStepIndex;
  final bool marksAllStepsComplete;

  const DashboardActionDetailPlaybook({
    super.key,
    required this.steps,
    this.activeStepIndex,
    this.marksAllStepsComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return HrisListSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                color: HrisColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Guided playbook',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${steps.length} steps',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < steps.length; index++)
            _PlaybookStepTile(
              number: index + 1,
              step: steps[index],
              isActive: index == activeStepIndex,
              isComplete:
                  marksAllStepsComplete ||
                  (activeStepIndex != null && index < activeStepIndex!),
              isLast: index == steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _PlaybookStepTile extends StatelessWidget {
  final int number;
  final DashboardActionPlaybookStep step;
  final bool isActive;
  final bool isComplete;
  final bool isLast;

  const _PlaybookStepTile({
    required this.number,
    required this.step,
    required this.isActive,
    required this.isComplete,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final markerColor =
        isComplete
            ? Colors.green
            : isActive
            ? HrisColors.primary
            : HrisColors.muted;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: markerColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                isComplete
                    ? const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 18,
                    )
                    : Text(
                      '$number',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: markerColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isActive ? HrisColors.primary : HrisColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  step.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
