import '../../ecommerce/order/order.dart';
import '../utils/inventory_label_utils.dart';
import '../utils/inventory_search_utils.dart';
import 'purchase_order.dart';

/// Status scopes available in the purchase-order queue.
enum InventoryPurchaseOrderFilter {
  all,
  active,
  needsReceiving,
  overdue,
  received,
  cancelled,
}

/// Sort modes available for the purchase-order queue.
enum InventoryPurchaseOrderSort {
  urgency,
  expectedDate,
  newestOrder,
  valueHigh,
  supplierName,
}

/// Receiving schedule buckets used to summarize inbound commitments.
enum InventoryPurchaseOrderScheduleBucket {
  overdue,
  dueToday,
  nextSevenDays,
  later,
  unscheduled,
}

/// View-ready purchase-order row data for the procurement workspace.
class InventoryPurchaseOrderRecord {
  const InventoryPurchaseOrderRecord({
    required this.order,
    required this.supplierLabel,
    required this.statusLabel,
    required this.totalAmount,
    required this.totalUnits,
    required this.itemCount,
    required this.isOverdue,
    required this.daysUntilExpected,
  });

  final PurchaseOrder order;
  final String supplierLabel;
  final String statusLabel;
  final double totalAmount;
  final int totalUnits;
  final int itemCount;
  final bool isOverdue;
  final int? daysUntilExpected;

  String get id => order.id;

  OrderStatus get status => order.status;

  DateTime get orderDate => order.orderDate;

  DateTime? get expectedDeliveryDate => order.expectedDeliveryDate;

  bool get isCancelled => status == OrderStatus.cancelled;

  bool get isReceived =>
      status == OrderStatus.received || status == OrderStatus.completed;

  bool get isActive => !isCancelled && !isReceived;

  bool get needsReceiving =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;
}

/// Aggregate procurement metrics used by purchase-order dashboards and panels.
class InventoryPurchaseOrderSummary {
  const InventoryPurchaseOrderSummary({
    required this.orderCount,
    required this.activeCount,
    required this.needsReceivingCount,
    required this.receivedCount,
    required this.cancelledCount,
    required this.overdueCount,
    required this.totalUnits,
    required this.totalOrderedValue,
    required this.openValue,
    required this.receivedValue,
  });

  final int orderCount;
  final int activeCount;
  final int needsReceivingCount;
  final int receivedCount;
  final int cancelledCount;
  final int overdueCount;
  final int totalUnits;
  final double totalOrderedValue;
  final double openValue;
  final double receivedValue;
}

/// Aggregated receiving workload for one schedule bucket.
class InventoryPurchaseOrderScheduleBucketSummary {
  const InventoryPurchaseOrderScheduleBucketSummary({
    required this.bucket,
    required this.count,
    required this.totalUnits,
    required this.totalValue,
  });

  final InventoryPurchaseOrderScheduleBucket bucket;
  final int count;
  final int totalUnits;
  final double totalValue;

  bool get hasOrders => count > 0;
}

List<InventoryPurchaseOrderRecord> buildInventoryPurchaseOrderRecords({
  required List<PurchaseOrder> orders,
  required DateTime asOfDate,
}) {
  return [for (final order in orders) _purchaseOrderRecord(order, asOfDate)]
    ..sort(_comparePurchaseOrderRecords);
}

InventoryPurchaseOrderSummary summarizeInventoryPurchaseOrderRecords(
  List<InventoryPurchaseOrderRecord> records,
) {
  var activeCount = 0;
  var needsReceivingCount = 0;
  var receivedCount = 0;
  var cancelledCount = 0;
  var overdueCount = 0;
  var totalUnits = 0;
  var totalOrderedValue = 0.0;
  var openValue = 0.0;
  var receivedValue = 0.0;

  for (final record in records) {
    totalUnits += record.totalUnits;
    totalOrderedValue += record.totalAmount;

    if (record.isActive) {
      activeCount += 1;
      openValue += record.totalAmount;
    }
    if (record.needsReceiving) {
      needsReceivingCount += 1;
    }
    if (record.isReceived) {
      receivedCount += 1;
      receivedValue += record.totalAmount;
    }
    if (record.isCancelled) {
      cancelledCount += 1;
    }
    if (record.isOverdue) {
      overdueCount += 1;
    }
  }

  return InventoryPurchaseOrderSummary(
    orderCount: records.length,
    activeCount: activeCount,
    needsReceivingCount: needsReceivingCount,
    receivedCount: receivedCount,
    cancelledCount: cancelledCount,
    overdueCount: overdueCount,
    totalUnits: totalUnits,
    totalOrderedValue: totalOrderedValue,
    openValue: openValue,
    receivedValue: receivedValue,
  );
}

List<InventoryPurchaseOrderScheduleBucketSummary>
buildInventoryPurchaseOrderScheduleBuckets(
  List<InventoryPurchaseOrderRecord> records,
) {
  final overdue = _InventoryPurchaseOrderScheduleBucketAccumulator(
    InventoryPurchaseOrderScheduleBucket.overdue,
  );
  final dueToday = _InventoryPurchaseOrderScheduleBucketAccumulator(
    InventoryPurchaseOrderScheduleBucket.dueToday,
  );
  final nextSevenDays = _InventoryPurchaseOrderScheduleBucketAccumulator(
    InventoryPurchaseOrderScheduleBucket.nextSevenDays,
  );
  final later = _InventoryPurchaseOrderScheduleBucketAccumulator(
    InventoryPurchaseOrderScheduleBucket.later,
  );
  final unscheduled = _InventoryPurchaseOrderScheduleBucketAccumulator(
    InventoryPurchaseOrderScheduleBucket.unscheduled,
  );

  for (final record in records) {
    if (!record.needsReceiving) continue;

    switch (_scheduleBucketFor(record)) {
      case InventoryPurchaseOrderScheduleBucket.overdue:
        overdue.add(record);
        break;
      case InventoryPurchaseOrderScheduleBucket.dueToday:
        dueToday.add(record);
        break;
      case InventoryPurchaseOrderScheduleBucket.nextSevenDays:
        nextSevenDays.add(record);
        break;
      case InventoryPurchaseOrderScheduleBucket.later:
        later.add(record);
        break;
      case InventoryPurchaseOrderScheduleBucket.unscheduled:
        unscheduled.add(record);
        break;
    }
  }

  return [
    overdue.toSummary(),
    dueToday.toSummary(),
    nextSevenDays.toSummary(),
    later.toSummary(),
    unscheduled.toSummary(),
  ];
}

List<InventoryPurchaseOrderRecord> filterInventoryPurchaseOrderRecords({
  required List<InventoryPurchaseOrderRecord> records,
  required String query,
  required InventoryPurchaseOrderFilter filter,
}) {
  final normalizedQuery = normalizeInventorySearchQuery(query);

  return records.where((record) {
    if (!_matchesFilter(record, filter)) return false;

    return inventorySearchMatchesAnyNormalized(normalizedQuery, [
          record.id,
          record.supplierLabel,
          record.statusLabel,
        ]) ||
        record.order.items.any((item) {
          return inventorySearchMatchesAnyNormalized(normalizedQuery, [
            item.name,
            item.sku,
          ]);
        });
  }).toList();
}

List<InventoryPurchaseOrderRecord>
filterInventoryPurchaseOrderRecordsBySchedule({
  required List<InventoryPurchaseOrderRecord> records,
  required InventoryPurchaseOrderScheduleBucket? scheduleBucket,
}) {
  final bucket = scheduleBucket;
  if (bucket == null) return records;

  return records.where((record) {
    return record.needsReceiving && _scheduleBucketFor(record) == bucket;
  }).toList();
}

List<InventoryPurchaseOrderRecord> sortInventoryPurchaseOrderRecords({
  required List<InventoryPurchaseOrderRecord> records,
  required InventoryPurchaseOrderSort sort,
}) {
  return [...records]..sort((first, second) {
    switch (sort) {
      case InventoryPurchaseOrderSort.urgency:
        return _comparePurchaseOrderRecords(first, second);
      case InventoryPurchaseOrderSort.expectedDate:
        return _compareByExpectedDate(first, second);
      case InventoryPurchaseOrderSort.newestOrder:
        return _compareByNewestOrder(first, second);
      case InventoryPurchaseOrderSort.valueHigh:
        return _compareByValueHigh(first, second);
      case InventoryPurchaseOrderSort.supplierName:
        return _compareBySupplierName(first, second);
    }
  });
}

String inventoryPurchaseOrderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.draft:
      return 'Draft';
    case OrderStatus.pending:
      return 'Pending';
    case OrderStatus.confirmed:
      return 'Confirmed';
    case OrderStatus.received:
      return 'Received';
    case OrderStatus.completed:
      return 'Completed';
    case OrderStatus.cancelled:
      return 'Cancelled';
  }
}

String inventoryPurchaseOrderFilterLabel(InventoryPurchaseOrderFilter filter) {
  switch (filter) {
    case InventoryPurchaseOrderFilter.all:
      return 'All';
    case InventoryPurchaseOrderFilter.active:
      return 'Active';
    case InventoryPurchaseOrderFilter.needsReceiving:
      return 'Receiving';
    case InventoryPurchaseOrderFilter.overdue:
      return 'Overdue';
    case InventoryPurchaseOrderFilter.received:
      return 'Received';
    case InventoryPurchaseOrderFilter.cancelled:
      return 'Cancelled';
  }
}

String inventoryPurchaseOrderSortLabel(InventoryPurchaseOrderSort sort) {
  switch (sort) {
    case InventoryPurchaseOrderSort.urgency:
      return 'Urgency';
    case InventoryPurchaseOrderSort.expectedDate:
      return 'Expected date';
    case InventoryPurchaseOrderSort.newestOrder:
      return 'Newest order';
    case InventoryPurchaseOrderSort.valueHigh:
      return 'Highest value';
    case InventoryPurchaseOrderSort.supplierName:
      return 'Supplier name';
  }
}

String inventoryPurchaseOrderScheduleBucketLabel(
  InventoryPurchaseOrderScheduleBucket bucket,
) {
  switch (bucket) {
    case InventoryPurchaseOrderScheduleBucket.overdue:
      return 'Overdue';
    case InventoryPurchaseOrderScheduleBucket.dueToday:
      return 'Due today';
    case InventoryPurchaseOrderScheduleBucket.nextSevenDays:
      return 'Next 7 days';
    case InventoryPurchaseOrderScheduleBucket.later:
      return 'Later';
    case InventoryPurchaseOrderScheduleBucket.unscheduled:
      return 'No ETA';
  }
}

InventoryPurchaseOrderRecord _purchaseOrderRecord(
  PurchaseOrder order,
  DateTime asOfDate,
) {
  final expectedDate = order.expectedDeliveryDate;
  final asOf = _dateOnly(asOfDate);
  final expected = expectedDate == null ? null : _dateOnly(expectedDate);
  final totalAmount =
      order.totalAmount > 0
          ? order.totalAmount
          : order.items.fold<double>(0, (total, item) => total + item.total);
  final statusLabel = inventoryPurchaseOrderStatusLabel(order.status);
  final isReceiving =
      order.status == OrderStatus.pending ||
      order.status == OrderStatus.confirmed;

  return InventoryPurchaseOrderRecord(
    order: order,
    supplierLabel: inventorySupplierLabel([
      order.supplierName,
      order.vendorName,
    ]),
    statusLabel: statusLabel,
    totalAmount: totalAmount,
    totalUnits: order.items.fold(0, (total, item) => total + item.quantity),
    itemCount: order.items.length,
    isOverdue: expected != null && expected.isBefore(asOf) && isReceiving,
    daysUntilExpected: expected?.difference(asOf).inDays,
  );
}

bool _matchesFilter(
  InventoryPurchaseOrderRecord record,
  InventoryPurchaseOrderFilter filter,
) {
  switch (filter) {
    case InventoryPurchaseOrderFilter.all:
      return true;
    case InventoryPurchaseOrderFilter.active:
      return record.isActive;
    case InventoryPurchaseOrderFilter.needsReceiving:
      return record.needsReceiving;
    case InventoryPurchaseOrderFilter.overdue:
      return record.isOverdue;
    case InventoryPurchaseOrderFilter.received:
      return record.isReceived;
    case InventoryPurchaseOrderFilter.cancelled:
      return record.isCancelled;
  }
}

InventoryPurchaseOrderScheduleBucket _scheduleBucketFor(
  InventoryPurchaseOrderRecord record,
) {
  if (record.isOverdue) return InventoryPurchaseOrderScheduleBucket.overdue;
  if (record.expectedDeliveryDate == null) {
    return InventoryPurchaseOrderScheduleBucket.unscheduled;
  }

  final days = record.daysUntilExpected;
  if (days == null) return InventoryPurchaseOrderScheduleBucket.later;
  if (days == 0) return InventoryPurchaseOrderScheduleBucket.dueToday;
  if (days > 0 && days <= 7) {
    return InventoryPurchaseOrderScheduleBucket.nextSevenDays;
  }

  return InventoryPurchaseOrderScheduleBucket.later;
}

/// Mutable collector used while building immutable receiving schedule buckets.
class _InventoryPurchaseOrderScheduleBucketAccumulator {
  _InventoryPurchaseOrderScheduleBucketAccumulator(this.bucket);

  final InventoryPurchaseOrderScheduleBucket bucket;
  var count = 0;
  var totalUnits = 0;
  var totalValue = 0.0;

  void add(InventoryPurchaseOrderRecord record) {
    count += 1;
    totalUnits += record.totalUnits;
    totalValue += record.totalAmount;
  }

  InventoryPurchaseOrderScheduleBucketSummary toSummary() {
    return InventoryPurchaseOrderScheduleBucketSummary(
      bucket: bucket,
      count: count,
      totalUnits: totalUnits,
      totalValue: totalValue,
    );
  }
}

int _comparePurchaseOrderRecords(
  InventoryPurchaseOrderRecord first,
  InventoryPurchaseOrderRecord second,
) {
  final urgencyRank = _orderUrgencyRank(
    first,
  ).compareTo(_orderUrgencyRank(second));
  if (urgencyRank != 0) return urgencyRank;

  final expectedRank = _expectedSortDate(
    first,
  ).compareTo(_expectedSortDate(second));
  if (expectedRank != 0) return expectedRank;

  final orderDateRank = second.orderDate.compareTo(first.orderDate);
  if (orderDateRank != 0) return orderDateRank;

  return first.id.compareTo(second.id);
}

int _compareByExpectedDate(
  InventoryPurchaseOrderRecord first,
  InventoryPurchaseOrderRecord second,
) {
  final expectedRank = _expectedSortDate(
    first,
  ).compareTo(_expectedSortDate(second));
  if (expectedRank != 0) return expectedRank;

  return _compareByNewestOrder(first, second);
}

int _compareByNewestOrder(
  InventoryPurchaseOrderRecord first,
  InventoryPurchaseOrderRecord second,
) {
  final orderDateRank = second.orderDate.compareTo(first.orderDate);
  if (orderDateRank != 0) return orderDateRank;

  return first.id.compareTo(second.id);
}

int _compareByValueHigh(
  InventoryPurchaseOrderRecord first,
  InventoryPurchaseOrderRecord second,
) {
  final valueRank = second.totalAmount.compareTo(first.totalAmount);
  if (valueRank != 0) return valueRank;

  return _comparePurchaseOrderRecords(first, second);
}

int _compareBySupplierName(
  InventoryPurchaseOrderRecord first,
  InventoryPurchaseOrderRecord second,
) {
  final supplierRank = first.supplierLabel.toLowerCase().compareTo(
    second.supplierLabel.toLowerCase(),
  );
  if (supplierRank != 0) return supplierRank;

  return _compareByNewestOrder(first, second);
}

int _orderUrgencyRank(InventoryPurchaseOrderRecord record) {
  if (record.isOverdue) return 0;
  if (record.needsReceiving) return 1;
  if (record.status == OrderStatus.draft) return 2;
  if (record.isReceived) return 3;
  if (record.isCancelled) return 4;
  return 2;
}

DateTime _expectedSortDate(InventoryPurchaseOrderRecord record) {
  return record.expectedDeliveryDate ?? DateTime(9999);
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
