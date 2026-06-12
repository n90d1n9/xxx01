import 'package:flutter/material.dart';

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/action.dart' as m;
import '../models/layout_spec.dart';
import '../models/section_order.dart';
import '../models/view_state.dart';
import 'channel_strategy_panel.dart';
import 'destination_grid.dart';
import 'header.dart';
import 'health_panel.dart';
import 'kpi_grid.dart';
import 'operations_section.dart';
import 'registry_notice.dart';

export 'operations_section.dart';

class SectionDeck extends StatelessWidget {
  final ViewState workspace;
  final LayoutSpec layoutSpec;
  final SectionOrder sectionOrder;
  final VoidCallback onOpenCheckout;
  final VoidCallback onOpenOrders;
  final ValueChanged<String> onDestinationSelected;
  final ValueChanged<String> onActionSelected;
  final ValueChanged<m.Action>? onActionInvoked;
  final Map<SectionSlot, GlobalKey>? sectionFocusKeys;

  const SectionDeck({
    super.key,
    required this.workspace,
    required this.layoutSpec,
    required this.sectionOrder,
    required this.onOpenCheckout,
    required this.onOpenOrders,
    required this.onDestinationSelected,
    required this.onActionSelected,
    this.onActionInvoked,
    this.sectionFocusKeys,
  });

  @override
  Widget build(BuildContext context) {
    final sections = sectionOrder.slots
        .where(_isVisible)
        .map(
          (slot) => KeyedSubtree(
            key: ValueKey('section_${slot.name}'),
            child: _withFocusKey(slot, _buildSection(slot)),
          ),
        )
        .toList(growable: false);

    return Column(
      key: const ValueKey('section_deck'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _withSectionGaps(sections),
    );
  }

  bool _isVisible(SectionSlot slot) {
    return switch (slot) {
      SectionSlot.registryNotice => workspace.hasRegistryIssues,
      SectionSlot.channelStrategy => workspace.hasChannelStrategy,
      SectionSlot.destinations => workspace.hasDestinations,
      _ => true,
    };
  }

  Widget _buildSection(SectionSlot slot) {
    return switch (slot) {
      SectionSlot.header => Header(
        overview: workspace.overview,
        productProfile: workspace.productProfile,
        onOpenCheckout: onOpenCheckout,
        onOpenOrders: onOpenOrders,
      ),
      SectionSlot.channelStrategy => ChannelStrategyPanel(
        strategy: workspace.channelStrategy,
      ),
      SectionSlot.kpis => KpiGrid(overview: workspace.overview),
      SectionSlot.health => HealthPanel(health: workspace.health),
      SectionSlot.registryNotice => RegistryNotice(
        diagnostics: workspace.registryDiagnostics,
      ),
      SectionSlot.destinations => DestinationGrid(
        destinations: workspace.destinations,
        onDestinationSelected: onDestinationSelected,
      ),
      SectionSlot.operations => OperationsSection(
        workspace: workspace,
        layoutSpec: layoutSpec,
        onActionSelected: onActionSelected,
        onActionInvoked: onActionInvoked,
      ),
    };
  }

  Widget _withFocusKey(SectionSlot slot, Widget child) {
    final focusKey = sectionFocusKeys?[slot];
    if (focusKey == null) return child;
    return KeyedSubtree(key: focusKey, child: child);
  }
}

class PrimarySections extends StatelessWidget {
  final ViewState workspace;
  final VoidCallback onOpenCheckout;
  final VoidCallback onOpenOrders;
  final ValueChanged<String> onDestinationSelected;

  const PrimarySections({
    super.key,
    required this.workspace,
    required this.onOpenCheckout,
    required this.onOpenOrders,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('primary_sections'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Header(
          overview: workspace.overview,
          productProfile: workspace.productProfile,
          onOpenCheckout: onOpenCheckout,
          onOpenOrders: onOpenOrders,
        ),
        const SizedBox(height: POSUiTokens.gapLarge),
        ChannelStrategyPanel(strategy: workspace.channelStrategy),
        if (workspace.hasChannelStrategy)
          const SizedBox(height: POSUiTokens.gapLarge),
        KpiGrid(overview: workspace.overview),
        const SizedBox(height: POSUiTokens.gapLarge),
        HealthPanel(health: workspace.health),
        const SizedBox(height: POSUiTokens.gapLarge),
        RegistryNotice(diagnostics: workspace.registryDiagnostics),
        if (workspace.hasRegistryIssues)
          const SizedBox(height: POSUiTokens.gapLarge),
        DestinationGrid(
          destinations: workspace.destinations,
          onDestinationSelected: onDestinationSelected,
        ),
      ],
    );
  }
}

List<Widget> _withSectionGaps(List<Widget> sections) {
  if (sections.isEmpty) return const [];

  final widgets = <Widget>[];
  for (final section in sections) {
    if (widgets.isNotEmpty) {
      widgets.add(const SizedBox(height: POSUiTokens.gapLarge));
    }
    widgets.add(section);
  }
  return widgets;
}
