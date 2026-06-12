import 'package:flutter/widgets.dart';

import 'pos_switch_filter_state.dart';

typedef POSSwitchFilterHostBuilder<T> =
    Widget Function(BuildContext context, POSSwitchFilterState<T> filterState);

class POSSwitchFilterHost<T> extends StatefulWidget {
  final T initialStatus;
  final String initialQuery;
  final POSSwitchFilterHostBuilder<T> builder;

  const POSSwitchFilterHost({
    super.key,
    required this.initialStatus,
    required this.builder,
    this.initialQuery = '',
  });

  @override
  State<POSSwitchFilterHost<T>> createState() => _POSSwitchFilterHostState<T>();
}

class _POSSwitchFilterHostState<T> extends State<POSSwitchFilterHost<T>> {
  late final POSSwitchFilterState<T> _filterState;

  @override
  void initState() {
    super.initState();
    _filterState = POSSwitchFilterState(
      initialStatus: widget.initialStatus,
      initialQuery: widget.initialQuery,
    );
  }

  @override
  void dispose() {
    _filterState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _filterState,
      builder: (context, _) => widget.builder(context, _filterState),
    );
  }
}
