import 'package:flutter/widgets.dart';

import '../utils/pos_browser_filter_controller.dart';

typedef POSBrowserFilterHostBuilder<T extends Object> =
    Widget Function(
      BuildContext context,
      POSBrowserFilterController<T> filterController,
      POSBrowserFilterHostActions<T> actions,
    );

class POSBrowserFilterHost<T extends Object> extends StatefulWidget {
  final T initialFilter;
  final String initialQuery;
  final POSBrowserFilterHostBuilder<T> builder;

  const POSBrowserFilterHost({
    super.key,
    required this.initialFilter,
    required this.builder,
    this.initialQuery = '',
  });

  @override
  State<POSBrowserFilterHost<T>> createState() =>
      _POSBrowserFilterHostState<T>();
}

class _POSBrowserFilterHostState<T extends Object>
    extends State<POSBrowserFilterHost<T>> {
  late final POSBrowserFilterController<T> _filterController;
  late final POSBrowserFilterHostActions<T> _actions;

  @override
  void initState() {
    super.initState();
    _filterController = POSBrowserFilterController<T>(
      initialFilter: widget.initialFilter,
      initialQuery: widget.initialQuery,
    );
    _actions = POSBrowserFilterHostActions._(_filterController, _rebuild);
  }

  @override
  void didUpdateWidget(POSBrowserFilterHost<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter ||
        oldWidget.initialQuery != widget.initialQuery) {
      _actions.replaceInitial(
        initialFilter: widget.initialFilter,
        initialQuery: widget.initialQuery,
      );
    }
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _filterController, _actions);
  }

  void _rebuild() {
    if (!mounted) return;
    setState(() {});
  }
}

class POSBrowserFilterHostActions<T extends Object> {
  final POSBrowserFilterController<T> _controller;
  final VoidCallback _requestRebuild;

  const POSBrowserFilterHostActions._(this._controller, this._requestRebuild);

  void setFilter(T filter) {
    if (_controller.setFilter(filter)) _requestRebuild();
  }

  void setQuery(String query) {
    _controller.setQuery(query);
    _requestRebuild();
  }

  void clearSearch() {
    if (_controller.clearSearch()) _requestRebuild();
  }

  void reset({T? filter, String query = ''}) {
    if (_controller.reset(filter: filter, query: query)) _requestRebuild();
  }

  void replaceInitial({
    required T initialFilter,
    String initialQuery = '',
    bool apply = true,
  }) {
    if (_controller.replaceInitial(
      initialFilter: initialFilter,
      initialQuery: initialQuery,
      apply: apply,
    )) {
      _requestRebuild();
    }
  }
}
