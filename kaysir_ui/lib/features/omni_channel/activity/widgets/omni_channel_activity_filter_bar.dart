import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../widgets/ui/app_filter_chip_group.dart';
import '../../../../widgets/ui/app_search_field.dart';
import '../models/omni_channel_activity_filter.dart';
import '../models/omni_channel_activity_scope.dart';
import 'omni_channel_activity_presentation.dart';

/// Search and status controls for the omni-channel activity center.
class OmniChannelActivityFilterBar extends StatefulWidget {
  final OmniChannelActivityFilter filter;
  final OmniChannelActivityFilterCounts counts;
  final OmniChannelActivityScopeOptions scopeOptions;
  final ValueChanged<OmniChannelActivityFilter> onFilterChanged;

  const OmniChannelActivityFilterBar({
    super.key,
    required this.filter,
    required this.counts,
    this.scopeOptions = const OmniChannelActivityScopeOptions(
      sources: [],
      channels: [],
      fulfillmentModes: [],
    ),
    required this.onFilterChanged,
  });

  @override
  State<OmniChannelActivityFilterBar> createState() =>
      _OmniChannelActivityFilterBarState();
}

/// Keeps the search text field synchronized with the external filter state.
class _OmniChannelActivityFilterBarState
    extends State<OmniChannelActivityFilterBar> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.filter.query);
  }

  @override
  void didUpdateWidget(OmniChannelActivityFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextQuery = widget.filter.query;
    if (_queryController.text != nextQuery) {
      _queryController.value = TextEditingValue(
        text: nextQuery,
        selection: TextSelection.collapsed(offset: nextQuery.length),
      );
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = omniChannelActivityFilterOptionPresentations(
      counts: widget.counts,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppSearchField(
              key: const ValueKey('omni-channel-activity-search'),
              controller: _queryController,
              hintText: 'Search activity, order, channel, or source',
              width: 360,
              onChanged:
                  (query) => widget.onFilterChanged(
                    widget.filter.copyWith(query: query),
                  ),
            ),
            if (widget.filter.hasConstraints)
              OutlinedButton.icon(
                key: const ValueKey('omni-channel-activity-reset-filter'),
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Reset'),
                onPressed: () {
                  _queryController.clear();
                  widget.onFilterChanged(const OmniChannelActivityFilter());
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        AppFilterChipGroup<OmniChannelActivityFilterStatus>(
          value: widget.filter.status,
          options: [
            for (final option in options)
              AppFilterChipOption(
                value: option.status,
                label: option.label,
                count: option.count,
                icon: option.icon,
                tooltip: '${option.count} ${option.label.toLowerCase()} events',
              ),
          ],
          onChanged:
              (status) => widget.onFilterChanged(
                widget.filter.copyWith(status: status),
              ),
        ),
        if (widget.scopeOptions.hasSources ||
            widget.scopeOptions.hasChannels ||
            widget.scopeOptions.hasFulfillmentModes) ...[
          const SizedBox(height: 12),
          _ActivityScopeFilters(
            filter: widget.filter,
            scopeOptions: widget.scopeOptions,
            onFilterChanged: widget.onFilterChanged,
          ),
        ],
      ],
    );
  }
}

@Preview(name: 'Omni-channel activity filter bar')
Widget omniChannelActivityFilterBarPreview() {
  var filter = const OmniChannelActivityFilter();
  final counts = OmniChannelActivityFilterCounts.fromEntries(const []);
  const scopeOptions = OmniChannelActivityScopeOptions(
    sources: [
      OmniChannelActivityScopeOption(
        id: 'ecommerce',
        label: 'Ecommerce',
        count: 3,
      ),
      OmniChannelActivityScopeOption(
        id: 'point_of_sales',
        label: 'Point of sale',
        count: 2,
      ),
    ],
    channels: [
      OmniChannelActivityScopeOption(
        id: 'marketplace',
        label: 'Marketplace',
        count: 2,
      ),
      OmniChannelActivityScopeOption(
        id: 'web_store',
        label: 'Web store',
        count: 1,
      ),
    ],
    fulfillmentModes: [
      OmniChannelActivityScopeOption(id: 'pickup', label: 'Pickup', count: 2),
      OmniChannelActivityScopeOption(
        id: 'delivery',
        label: 'Delivery',
        count: 1,
      ),
    ],
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StatefulBuilder(
          builder:
              (context, setState) => OmniChannelActivityFilterBar(
                filter: filter,
                counts: counts,
                scopeOptions: scopeOptions,
                onFilterChanged: (value) => setState(() => filter = value),
              ),
        ),
      ),
    ),
  );
}

/// Source, channel, and fulfillment facet controls for scoping activity.
class _ActivityScopeFilters extends StatelessWidget {
  final OmniChannelActivityFilter filter;
  final OmniChannelActivityScopeOptions scopeOptions;
  final ValueChanged<OmniChannelActivityFilter> onFilterChanged;

  const _ActivityScopeFilters({
    required this.filter,
    required this.scopeOptions,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        if (scopeOptions.hasSources)
          _ActivityScopeGroup(
            title: 'Source',
            selectedId: filter.sourceId,
            allLabel: 'All sources',
            allCount: _totalCount(scopeOptions.sources),
            options: scopeOptions.sources,
            icon: Icons.hub_outlined,
            onChanged:
                (sourceId) => onFilterChanged(
                  filter.copyWith(
                    sourceId: sourceId,
                    clearSourceId: sourceId == null,
                  ),
                ),
          ),
        if (scopeOptions.hasChannels)
          _ActivityScopeGroup(
            title: 'Channel',
            selectedId: filter.channelId,
            allLabel: 'All channels',
            allCount: _totalCount(scopeOptions.channels),
            options: scopeOptions.channels,
            icon: Icons.storefront_outlined,
            onChanged:
                (channelId) => onFilterChanged(
                  filter.copyWith(
                    channelId: channelId,
                    clearChannelId: channelId == null,
                  ),
                ),
          ),
        if (scopeOptions.hasFulfillmentModes)
          _ActivityScopeGroup(
            title: 'Fulfillment',
            selectedId: filter.fulfillmentModeKey,
            allLabel: 'All fulfillment',
            allCount: _totalCount(scopeOptions.fulfillmentModes),
            options: scopeOptions.fulfillmentModes,
            icon: Icons.local_shipping_outlined,
            onChanged:
                (fulfillmentModeKey) => onFilterChanged(
                  filter.copyWith(
                    fulfillmentModeKey: fulfillmentModeKey,
                    clearFulfillmentModeKey: fulfillmentModeKey == null,
                  ),
                ),
          ),
      ],
    );
  }
}

/// Labeled chip group for one activity scope dimension.
class _ActivityScopeGroup extends StatelessWidget {
  final String title;
  final String? selectedId;
  final String allLabel;
  final int allCount;
  final List<OmniChannelActivityScopeOption> options;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _ActivityScopeGroup({
    required this.title,
    required this.selectedId,
    required this.allLabel,
    required this.allCount,
    required this.options,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          AppFilterChipGroup<String?>(
            value: selectedId,
            options: [
              AppFilterChipOption<String?>(
                value: null,
                label: allLabel,
                count: allCount,
                chipKey: ValueKey(
                  'omni-channel-activity-${_scopeKey(title)}-scope-all',
                ),
                icon: Icons.all_inclusive_outlined,
                tooltip: '$allCount ${allLabel.toLowerCase()} events',
              ),
              for (final option in options)
                AppFilterChipOption<String?>(
                  value: option.id,
                  label: option.label,
                  count: option.count,
                  chipKey: ValueKey(
                    'omni-channel-activity-${_scopeKey(title)}-scope-${option.id}',
                  ),
                  icon: icon,
                  tooltip: '${option.count} ${option.label} events',
                ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

int _totalCount(List<OmniChannelActivityScopeOption> options) {
  return options.fold(0, (total, option) => total + option.count);
}

String _scopeKey(String title) {
  return title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');
}
