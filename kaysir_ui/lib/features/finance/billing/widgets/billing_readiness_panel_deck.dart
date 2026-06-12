import 'package:flutter/material.dart';

import 'billing_readiness_panel_descriptor.dart';

class BillingReadinessPanelDeck extends StatelessWidget {
  final BillingReadinessPanelDescriptorRegistry registry;
  final List<Object> sources;
  final Widget? emptyState;

  BillingReadinessPanelDeck({
    super.key,
    required this.registry,
    Iterable<Object> sources = const [],
    this.emptyState,
  }) : sources = List.unmodifiable(sources);

  @override
  Widget build(BuildContext context) {
    final panels = <Widget>[];
    for (final source in sources) {
      panels.addAll(registry.buildForSource(source));
    }

    if (panels.isEmpty) {
      return emptyState ?? const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: panels,
    );
  }
}
