import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import 'release_profile_domain_filter.dart';
import 'release_profile_status_filter.dart';

/// Restores diagnostics release profile filters from route or saved-view state.
class BillingDiagnosticsReleaseProfileFilterHydrator
    extends ConsumerStatefulWidget {
  final BillingDiagnosticsReleaseProfileFilterState initialState;
  final bool clearWhenInactive;
  final Widget child;

  const BillingDiagnosticsReleaseProfileFilterHydrator({
    super.key,
    required this.child,
    this.initialState = const BillingDiagnosticsReleaseProfileFilterState(),
    this.clearWhenInactive = true,
  });

  @override
  ConsumerState<BillingDiagnosticsReleaseProfileFilterHydrator> createState() =>
      _BillingDiagnosticsReleaseProfileFilterHydratorState();
}

class _BillingDiagnosticsReleaseProfileFilterHydratorState
    extends ConsumerState<BillingDiagnosticsReleaseProfileFilterHydrator> {
  BillingDiagnosticsReleaseProfileFilterScope? _hydratedScope;
  BillingDiagnosticsReleaseProfileFilterState? _hydratedState;

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(
      billingDiagnosticsReleaseProfileFilterScopeProvider,
    );
    _scheduleHydration(scope);

    return widget.child;
  }

  void _scheduleHydration(BillingDiagnosticsReleaseProfileFilterScope scope) {
    if (!widget.clearWhenInactive && !widget.initialState.hasActiveFilters) {
      return;
    }
    if (_hydratedScope == scope && _hydratedState == widget.initialState) {
      return;
    }

    _hydratedScope = scope;
    _hydratedState = widget.initialState;

    Future<void>.microtask(() {
      if (!mounted) return;

      ref
          .read(billingDiagnosticsReleaseProfileFilterProvider(scope).notifier)
          .hydrate(widget.initialState);
    });
  }
}

@Preview(name: 'Diagnostics release profile filter hydrator')
Widget billingDiagnosticsReleaseProfileFilterHydratorPreview() {
  return ProviderScope(
    child: MaterialApp(
      home: BillingDiagnosticsReleaseProfileFilterHydrator(
        initialState: BillingDiagnosticsReleaseProfileFilterState(
          statusOption: BillingReleaseProfileStatusFilterOption.standard,
          domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
            'commerce',
          ),
        ),
        child: const Scaffold(
          body: Center(child: Text('Hydrated diagnostics route')),
        ),
      ),
    ),
  );
}
