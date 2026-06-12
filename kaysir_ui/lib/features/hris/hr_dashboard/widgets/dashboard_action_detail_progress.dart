import 'package:flutter/material.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/dashboard_action_detail_section_progress.dart';

class DashboardActionDetailProgress extends StatelessWidget {
  final DashboardActionDetailSectionProgress progress;
  final VoidCallback? onReturnToOverview;
  final VoidCallback? onGoToPreviousSection;
  final VoidCallback? onGoToNextSection;

  const DashboardActionDetailProgress({
    super.key,
    required this.progress,
    this.onReturnToOverview,
    this.onGoToPreviousSection,
    this.onGoToNextSection,
  });

  @override
  Widget build(BuildContext context) {
    final canReturnToOverview =
        onReturnToOverview != null && progress.sectionIndex > 1;
    final canGoToPreviousSection =
        onGoToPreviousSection != null && progress.sectionIndex > 1;
    final canGoToNextSection =
        onGoToNextSection != null &&
        progress.sectionIndex < progress.sectionCount;

    return Tooltip(
      message: canReturnToOverview ? 'Back to overview' : 'Viewing overview',
      child: Semantics(
        container: true,
        button: canReturnToOverview,
        enabled: canReturnToOverview ? true : null,
        label: 'Action detail progress',
        value: progress.semanticLabel,
        onTapHint: canReturnToOverview ? 'Return to overview' : null,
        onTap: canReturnToOverview ? onReturnToOverview : null,
        child: Material(
          color: HrisColors.surfaceSubtle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: HrisColors.border),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: canReturnToOverview ? onReturnToOverview : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: HrisColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.route_outlined,
                      color: HrisColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                progress.sectionLabel,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  color: HrisColors.ink,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              progress.positionLabel,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: HrisColors.muted),
                            ),
                            if (canReturnToOverview) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: HrisColors.primary,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            value: progress.value.clamp(0, 1),
                            color: HrisColors.primary,
                            backgroundColor: HrisColors.primary.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.task_alt_outlined,
                              color: HrisColors.primary,
                              size: 15,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                progress.actionLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: HrisColors.muted),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (onGoToPreviousSection != null ||
                      onGoToNextSection != null) ...[
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onGoToPreviousSection != null)
                          IconButton(
                            tooltip:
                                canGoToPreviousSection
                                    ? 'Previous section'
                                    : 'First section',
                            onPressed:
                                canGoToPreviousSection
                                    ? onGoToPreviousSection
                                    : null,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints.tightFor(
                              width: 34,
                              height: 30,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_up_rounded),
                            color: HrisColors.primary,
                          ),
                        if (onGoToNextSection != null)
                          IconButton(
                            tooltip:
                                canGoToNextSection
                                    ? 'Next section'
                                    : 'Final section',
                            onPressed:
                                canGoToNextSection ? onGoToNextSection : null,
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints.tightFor(
                              width: 34,
                              height: 30,
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                            color: HrisColors.primary,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
