enum BillingPaymentScheduleStrategy {
  singleDueDate,
  splitEqual,
  upfrontAndBalance,
  milestones,
}

class BillingPaymentScheduleMilestone {
  final String id;
  final String label;
  final double amountRatio;
  final int dueAfterDays;
  final Map<String, String> attributes;

  BillingPaymentScheduleMilestone({
    required this.id,
    required this.label,
    required this.amountRatio,
    required this.dueAfterDays,
    Map<String, String> attributes = const {},
  }) : attributes = Map.unmodifiable(attributes);

  List<String> get validationErrors {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Payment schedule milestone id is required.');
    }
    if (label.trim().isEmpty) {
      errors.add('Payment schedule milestone label is required.');
    }
    if (amountRatio <= 0 || amountRatio > 1) {
      errors.add('Payment schedule milestone ratio must be between 0 and 1.');
    }
    if (dueAfterDays < 0) {
      errors.add('Payment schedule milestone due offset cannot be negative.');
    }

    return List.unmodifiable(errors);
  }
}

class BillingPaymentScheduleOptions {
  final BillingPaymentScheduleStrategy strategy;
  final int installments;
  final int? intervalDays;
  final double upfrontRatio;
  final List<BillingPaymentScheduleMilestone> milestones;

  BillingPaymentScheduleOptions({
    this.strategy = BillingPaymentScheduleStrategy.singleDueDate,
    this.installments = 1,
    this.intervalDays,
    this.upfrontRatio = 0.5,
    Iterable<BillingPaymentScheduleMilestone> milestones = const [],
  }) : milestones = List.unmodifiable(milestones);

  BillingPaymentScheduleOptions.singleDueDate()
    : this(strategy: BillingPaymentScheduleStrategy.singleDueDate);

  BillingPaymentScheduleOptions.splitEqual({
    required int installments,
    int? intervalDays,
  }) : this(
         strategy: BillingPaymentScheduleStrategy.splitEqual,
         installments: installments,
         intervalDays: intervalDays,
       );

  BillingPaymentScheduleOptions.upfrontAndBalance({
    required double upfrontRatio,
  }) : this(
         strategy: BillingPaymentScheduleStrategy.upfrontAndBalance,
         upfrontRatio: upfrontRatio,
       );

  BillingPaymentScheduleOptions.milestones({
    required Iterable<BillingPaymentScheduleMilestone> milestones,
  }) : this(
         strategy: BillingPaymentScheduleStrategy.milestones,
         milestones: milestones,
       );
}

class BillingPaymentScheduleItem {
  final String id;
  final String label;
  final double amount;
  final double amountRatio;
  final DateTime dueDate;
  final Map<String, String> attributes;

  BillingPaymentScheduleItem({
    required this.id,
    required this.label,
    required this.amount,
    required this.amountRatio,
    required this.dueDate,
    Map<String, String> attributes = const {},
  }) : attributes = Map.unmodifiable(attributes);

  List<String> get validationErrors {
    final errors = <String>[];

    if (id.trim().isEmpty) {
      errors.add('Payment schedule item id is required.');
    }
    if (label.trim().isEmpty) {
      errors.add('Payment schedule item label is required.');
    }
    if (amount < 0) {
      errors.add('Payment schedule item amount cannot be negative.');
    }
    if (amountRatio < 0 || amountRatio > 1) {
      errors.add('Payment schedule item ratio must be between 0 and 1.');
    }

    return List.unmodifiable(errors);
  }

  Map<String, Object?> toPayload() {
    return Map.unmodifiable({
      'id': id,
      'label': label,
      'amount': amount,
      'amountRatio': amountRatio,
      'dueDate': dueDate.toIso8601String(),
      'attributes': Map<String, String>.unmodifiable(attributes),
    });
  }
}

class BillingPaymentSchedule {
  final BillingPaymentScheduleStrategy strategy;
  final double total;
  final List<BillingPaymentScheduleItem> items;

  BillingPaymentSchedule({
    required this.strategy,
    required this.total,
    required Iterable<BillingPaymentScheduleItem> items,
  }) : items = List.unmodifiable(items);

  bool get isSinglePayment => items.length <= 1;

  int get paymentCount => items.length;

  double get scheduledTotal {
    return items.fold<double>(0, (sum, item) => sum + item.amount);
  }

  double get balanceDifference => scheduledTotal - total;

  DateTime? get firstDueDate {
    if (items.isEmpty) return null;
    return items.first.dueDate;
  }

  DateTime? get finalDueDate {
    if (items.isEmpty) return null;

    return items
        .map((item) => item.dueDate)
        .reduce((current, next) => current.isAfter(next) ? current : next);
  }

  bool isBalanced({double tolerance = 0.01}) {
    return balanceDifference.abs() <= tolerance;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    final seenIds = <String>{};

    if (total < 0) {
      errors.add('Payment schedule total cannot be negative.');
    }
    if (items.isEmpty) {
      errors.add('Payment schedule needs at least one item.');
    }

    for (final item in items) {
      errors.addAll(item.validationErrors);
      if (!seenIds.add(item.id.trim())) {
        errors.add('Duplicate payment schedule item ${item.id}.');
      }
    }

    if (!isBalanced()) {
      errors.add('Payment schedule items must match the invoice total.');
    }

    return List.unmodifiable(errors);
  }

  Map<String, Object?> toPayload() {
    return Map.unmodifiable({
      'strategy': strategy.name,
      'paymentCount': paymentCount,
      'total': total,
      'scheduledTotal': scheduledTotal,
      'firstDueDate': firstDueDate?.toIso8601String(),
      'finalDueDate': finalDueDate?.toIso8601String(),
      'items': List<Map<String, Object?>>.unmodifiable(
        items.map((item) => item.toPayload()),
      ),
    });
  }
}
