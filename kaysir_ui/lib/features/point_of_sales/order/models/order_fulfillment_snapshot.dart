class OrderFulfillmentSnapshot {
  final String commerceChannelId;
  final String commerceChannelLabel;
  final String fulfillmentModeKey;
  final String fulfillmentModeLabel;
  final String contactName;
  final String destination;
  final String tableName;
  final String scheduleLabel;
  final String note;
  final String statusLabel;
  final String summaryLabel;

  const OrderFulfillmentSnapshot({
    required this.commerceChannelId,
    required this.commerceChannelLabel,
    required this.fulfillmentModeKey,
    required this.fulfillmentModeLabel,
    this.contactName = '',
    this.destination = '',
    this.tableName = '',
    this.scheduleLabel = '',
    this.note = '',
    this.statusLabel = '',
    this.summaryLabel = '',
  });

  String get detailLabel {
    final normalizedSummary = summaryLabel.trim();
    if (normalizedSummary.isEmpty ||
        normalizedSummary == fulfillmentModeLabel.trim()) {
      return '';
    }

    return normalizedSummary;
  }

  bool get hasDetails {
    return contactName.trim().isNotEmpty ||
        destination.trim().isNotEmpty ||
        tableName.trim().isNotEmpty ||
        scheduleLabel.trim().isNotEmpty ||
        note.trim().isNotEmpty ||
        detailLabel.isNotEmpty;
  }
}
