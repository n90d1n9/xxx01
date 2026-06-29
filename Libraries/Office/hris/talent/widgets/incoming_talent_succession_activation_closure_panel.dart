import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../models/incoming_talent_succession_models.dart';
import '../states/incoming_talent_succession_activation_closure_provider.dart';
import 'incoming_talent_succession_activation_closure_form.dart';
import 'incoming_talent_succession_activation_closure_tile.dart';

class IncomingTalentSuccessionActivationClosurePanel extends ConsumerWidget {
  const IncomingTalentSuccessionActivationClosurePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readyReviews = ref.watch(
      closureReadySuccessionActivationResolutionReviewsProvider,
    );
    final closures = ref.watch(
      filteredIncomingTalentSuccessionActivationClosuresProvider,
    );
    final summary = ref.watch(
      incomingTalentSuccessionActivationClosureSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.verified_outlined,
      title: 'Transition closures',
      subtitle: summary.nextAction,
      emptyMessage: 'No transition closures',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Ready',
              value: '${readyReviews.length}',
            ),
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.activeCount + summary.scheduledCount}',
            ),
            HrisMetricStripItem(
              label: 'Deferred',
              value: '${summary.deferredCount}',
            ),
          ],
        ),
        const IncomingTalentSuccessionActivationClosureForm(),
        if (closures.isEmpty)
          const HrisListSurface(child: Text('No transition closures yet.'))
        else
          for (final closure in closures.take(3))
            IncomingTalentSuccessionActivationClosureTile(
              closure: closure,
              onActivate:
                  () => _setStatus(
                    ref,
                    closure,
                    IncomingTalentSuccessionActivationClosureStatus.active,
                  ),
              onComplete:
                  () => _setStatus(
                    ref,
                    closure,
                    IncomingTalentSuccessionActivationClosureStatus.completed,
                  ),
              onDefer:
                  () => _setStatus(
                    ref,
                    closure,
                    IncomingTalentSuccessionActivationClosureStatus.deferred,
                  ),
            ),
      ],
    );
  }

  void _setStatus(
    WidgetRef ref,
    IncomingTalentSuccessionActivationClosure closure,
    IncomingTalentSuccessionActivationClosureStatus status,
  ) {
    final notifier = ref.read(
      incomingTalentSuccessionActivationClosuresProvider.notifier,
    );
    switch (status) {
      case IncomingTalentSuccessionActivationClosureStatus.active:
        notifier.activate(closure.id);
      case IncomingTalentSuccessionActivationClosureStatus.completed:
        notifier.complete(closure.id);
      case IncomingTalentSuccessionActivationClosureStatus.deferred:
        notifier.defer(closure.id);
      case IncomingTalentSuccessionActivationClosureStatus.scheduled:
        break;
    }
  }
}
