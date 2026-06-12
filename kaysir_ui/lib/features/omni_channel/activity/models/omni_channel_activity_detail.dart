import 'omni_channel_activity.dart';

/// Structured summary used by the omni-channel activity detail panel.
class OmniChannelActivityDetail {
  final String title;
  final String summary;
  final String contextLabel;
  final List<OmniChannelActivityDetailField> primaryFields;
  final List<OmniChannelActivityDetailField> attributeFields;

  const OmniChannelActivityDetail({
    required this.title,
    required this.summary,
    required this.contextLabel,
    required this.primaryFields,
    required this.attributeFields,
  });

  bool get hasAttributes => attributeFields.isNotEmpty;

  factory OmniChannelActivityDetail.fromEntry(OmniChannelActivityEntry entry) {
    return OmniChannelActivityDetail(
      title: entry.title,
      summary: _firstPresent([
        entry.supportSummary,
        entry.detail,
        entry.kind.label,
      ]),
      contextLabel: _contextLabel(entry),
      primaryFields: List.unmodifiable([
        OmniChannelActivityDetailField(
          label: 'Source',
          value: entry.sourceLabel,
        ),
        if (_hasValue(entry.channelLabel ?? entry.channelId))
          OmniChannelActivityDetailField(
            label: 'Channel',
            value: entry.channelLabel ?? entry.channelId!,
          ),
        if (_hasValue(entry.orderId))
          OmniChannelActivityDetailField(label: 'Order', value: entry.orderId!),
        if (_hasValue(entry.fulfillmentModeLabel ?? entry.fulfillmentModeKey))
          OmniChannelActivityDetailField(
            label: 'Fulfillment',
            value: entry.fulfillmentModeLabel ?? entry.fulfillmentModeKey!,
          ),
        OmniChannelActivityDetailField(label: 'Event ID', value: entry.id),
      ]),
      attributeFields: List.unmodifiable(_attributeFields(entry.attributes)),
    );
  }
}

/// Display-safe label/value pair for an activity detail field.
class OmniChannelActivityDetailField {
  final String label;
  final String value;

  const OmniChannelActivityDetailField({
    required this.label,
    required this.value,
  });
}

List<OmniChannelActivityDetailField> _attributeFields(
  Map<String, String> attributes,
) {
  final fields = <OmniChannelActivityDetailField>[];

  for (final entry in attributes.entries) {
    final key = entry.key.trim();
    final value = entry.value.trim();
    if (key.isEmpty || value.isEmpty) continue;

    fields.add(
      OmniChannelActivityDetailField(label: _humanizeKey(key), value: value),
    );
  }

  fields.sort((left, right) => left.label.compareTo(right.label));
  return fields;
}

String _contextLabel(OmniChannelActivityEntry entry) {
  final parts = <String>[
    entry.sourceLabel,
    if (_hasValue(entry.channelLabel ?? entry.channelId))
      (entry.channelLabel ?? entry.channelId!).trim(),
    if (_hasValue(entry.orderId)) entry.orderId!.trim(),
  ];

  return parts.join(' / ');
}

String _firstPresent(Iterable<String?> values) {
  for (final value in values) {
    final normalized = value?.trim();
    if (normalized != null && normalized.isNotEmpty) return normalized;
  }

  return 'Activity event';
}

String _humanizeKey(String value) {
  final withWordBreaks =
      value
          .replaceAll(RegExp('[_-]+'), ' ')
          .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
          )
          .trim();
  if (withWordBreaks.isEmpty) return value;

  return withWordBreaks.split(RegExp(r'\s+')).map(_capitalize).join(' ');
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  if (value.length == 1) return value.toUpperCase();

  return '${value[0].toUpperCase()}${value.substring(1)}';
}

bool _hasValue(String? value) {
  return value?.trim().isNotEmpty ?? false;
}
