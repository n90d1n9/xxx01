import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/hris/shared/widgets/hris_ui.dart';

import '../states/incoming_talent_development_portfolio_provider.dart';
import 'incoming_talent_development_portfolio_form.dart';
import 'incoming_talent_development_portfolio_tile.dart';

class IncomingTalentDevelopmentPortfolioPanel extends ConsumerWidget {
  const IncomingTalentDevelopmentPortfolioPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolios = ref.watch(
      filteredIncomingTalentDevelopmentPortfoliosProvider,
    );
    final summary = ref.watch(
      incomingTalentDevelopmentPortfolioSummaryProvider,
    );

    return HrisSectionPanel(
      icon: Icons.assignment_turned_in_outlined,
      title: 'IDP portfolios',
      subtitle: summary.nextAction,
      emptyMessage: 'No IDP portfolio data',
      children: [
        HrisMetricStrip(
          items: [
            HrisMetricStripItem(
              label: 'Active',
              value: '${summary.activeCount}',
            ),
            HrisMetricStripItem(label: 'Watch', value: '${summary.watchCount}'),
            HrisMetricStripItem(
              label: 'Due soon',
              value: '${summary.dueSoonCount}',
            ),
          ],
        ),
        const IncomingTalentDevelopmentPortfolioForm(),
        if (portfolios.isEmpty)
          const HrisListSurface(child: Text('No IDP portfolios created yet.'))
        else
          for (final portfolio in portfolios)
            IncomingTalentDevelopmentPortfolioTile(portfolio: portfolio),
      ],
    );
  }
}
