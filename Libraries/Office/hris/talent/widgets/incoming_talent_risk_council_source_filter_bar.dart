import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_risk_council_queue_models.dart';
import '../states/incoming_talent_risk_council_source_filter_provider.dart';

/// Source focus control for risk council queue, decision, and follow-up work.
class IncomingTalentRiskCouncilSourceFilterBar extends ConsumerWidget {
  const IncomingTalentRiskCouncilSourceFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSource = ref.watch(
      incomingTalentRiskCouncilSourceFilterProvider,
    );

    return HrisListSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final selector = _SourceSelector(
            selectedSource: selectedSource,
            onChanged:
                (source) =>
                    ref
                        .read(
                          incomingTalentRiskCouncilSourceFilterProvider
                              .notifier,
                        )
                        .state = source,
          );

          if (constraints.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SourceFilterHeading(),
                const SizedBox(height: 12),
                selector,
              ],
            );
          }

          return Row(
            children: [
              const Expanded(child: _SourceFilterHeading()),
              const SizedBox(width: 16),
              SizedBox(width: 320, child: selector),
            ],
          );
        },
      ),
    );
  }
}

class _SourceFilterHeading extends StatelessWidget {
  const _SourceFilterHeading();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.account_tree_outlined, color: HrisColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Risk council source focus',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: HrisColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Queue, decisions, and follow-ups',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HrisColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SourceSelector extends StatelessWidget {
  final IncomingTalentRiskCouncilQueueSource? selectedSource;
  final ValueChanged<IncomingTalentRiskCouncilQueueSource?> onChanged;

  const _SourceSelector({
    required this.selectedSource,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<IncomingTalentRiskCouncilQueueSource?>(
      initialValue: selectedSource,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Council source',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.filter_list_outlined),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(incomingTalentRiskCouncilSourceFilterLabel(null)),
        ),
        for (final source in IncomingTalentRiskCouncilQueueSource.values)
          DropdownMenuItem(
            value: source,
            child: Text(
              incomingTalentRiskCouncilSourceFilterLabel(source),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

@Preview(name: 'Talent risk council source filter')
Widget incomingTalentRiskCouncilSourceFilterBarPreview() {
  return ProviderScope(
    overrides: [
      incomingTalentRiskCouncilSourceFilterProvider.overrideWith(
        (ref) => IncomingTalentRiskCouncilQueueSource.promotionResolutionReview,
      ),
    ],
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: IncomingTalentRiskCouncilSourceFilterBar(),
        ),
      ),
    ),
  );
}
