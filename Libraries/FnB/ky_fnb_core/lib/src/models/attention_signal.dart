import 'kitchen_station.dart';
import 'menu_catalog_entry.dart';
import 'menu_recipe_readiness.dart';
import 'menu_signal.dart';
import 'recipe_production_entry.dart';
import 'service_alert_entry.dart';
import 'service_status.dart';

/// Cross-FnB category for an operational attention signal.
enum FnbAttentionSignalKind {
  serviceAlert,
  kitchenStation,
  menuRisk,
  menuCatalog,
  recipeProduction,
  reservation,
  floorZone,
  shiftTask,
  custom;

  String get label => switch (this) {
    FnbAttentionSignalKind.serviceAlert => 'Service alert',
    FnbAttentionSignalKind.kitchenStation => 'Kitchen station',
    FnbAttentionSignalKind.menuRisk => 'Menu risk',
    FnbAttentionSignalKind.menuCatalog => 'Menu catalog',
    FnbAttentionSignalKind.recipeProduction => 'Recipe production',
    FnbAttentionSignalKind.reservation => 'Reservation',
    FnbAttentionSignalKind.floorZone => 'Floor zone',
    FnbAttentionSignalKind.shiftTask => 'Shift task',
    FnbAttentionSignalKind.custom => 'Custom',
  };
}

/// Normalized attention record for ranking cross-functional FnB work.
class FnbAttentionSignal {
  const FnbAttentionSignal({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
    required this.status,
    required this.urgencyScore,
    this.valueLabel,
    this.sourceId,
    this.targetId,
    this.dueAt,
    this.tags = const [],
  }) : assert(id != '', 'id must not be empty.'),
       assert(title != '', 'title must not be empty.'),
       assert(urgencyScore >= 0, 'urgencyScore must not be negative.');

  /// Builds a signal from an actionable service alert entry.
  factory FnbAttentionSignal.fromServiceAlertEntry(
    FnbServiceAlertEntry entry, {
    required DateTime now,
    String? id,
  }) {
    final actionable = entry.isActionableAt(now);
    final status = actionable
        ? entry.alert.critical
              ? FnbServiceStatus.critical
              : entry.serviceStatus.needsAttention
              ? entry.serviceStatus
              : FnbServiceStatus.busy
        : FnbServiceStatus.calm;

    return FnbAttentionSignal(
      id:
          id ??
          'service-alert-${entry.sourceId}-${entry.alert.type.name}-'
              '${_slug(entry.alert.titleLabel)}',
      kind: FnbAttentionSignalKind.serviceAlert,
      title: entry.titleLabel,
      detail: entry.subtitleLabel,
      valueLabel: entry.lifecycle.statusLabel,
      status: status,
      urgencyScore: actionable ? entry.priorityScore : 0,
      sourceId: entry.sourceId,
      targetId: entry.sourceId,
      dueAt: entry.dueAt,
      tags: [
        entry.alert.type.label,
        if (entry.alert.critical) 'Critical',
        entry.lifecycle.statusLabel,
      ],
    );
  }

  /// Builds a signal from a shared kitchen station pressure snapshot.
  factory FnbAttentionSignal.fromKitchenStation(FnbKitchenStation station) {
    return FnbAttentionSignal(
      id: 'kitchen-station-${station.id}',
      kind: FnbAttentionSignalKind.kitchenStation,
      title: station.name,
      detail: station.queueLeadLabel,
      valueLabel: station.fireTimeLabel,
      status: station.status,
      urgencyScore: station.ticketsInProgress * 10 + station.averageFireMinutes,
      sourceId: station.id,
      targetId: station.id,
      tags: [station.ticketLabel, station.status.label],
    );
  }

  /// Builds a signal from live menu demand and sold-out risk.
  factory FnbAttentionSignal.fromMenuSignal(FnbMenuSignal signal) {
    final status = signal.soldOutRiskPercent >= 70
        ? FnbServiceStatus.critical
        : signal.soldOutRiskPercent >= 50
        ? FnbServiceStatus.busy
        : FnbServiceStatus.calm;

    return FnbAttentionSignal(
      id: 'menu-risk-${signal.id}',
      kind: FnbAttentionSignalKind.menuRisk,
      title: signal.name,
      detail: '${signal.category} - ${signal.orders} orders',
      valueLabel: '${signal.soldOutRiskPercent}% risk',
      status: status,
      urgencyScore: signal.soldOutRiskPercent * 10 + signal.orders,
      sourceId: signal.id,
      targetId: signal.id,
      tags: signal.tags,
    );
  }

  /// Builds a signal from shared menu catalog readiness review.
  factory FnbAttentionSignal.fromMenuCatalogEntry(FnbMenuCatalogEntry entry) {
    final issue = entry.readiness.primaryIssue;
    final status = !entry.needsReview
        ? FnbServiceStatus.calm
        : issue == FnbMenuRecipeReadinessIssue.missingRecipe ||
              issue == FnbMenuRecipeReadinessIssue.soldOut
        ? FnbServiceStatus.critical
        : FnbServiceStatus.busy;

    return FnbAttentionSignal(
      id: 'menu-catalog-${entry.id}',
      kind: FnbAttentionSignalKind.menuCatalog,
      title: entry.name,
      detail: '${entry.categoryLabel} - ${entry.routeLabel}',
      valueLabel: entry.reviewLabel,
      status: status,
      urgencyScore: entry.needsReview ? 100 - entry.reviewRank * 10 : 0,
      sourceId: entry.id,
      targetId: entry.id,
      tags: [entry.availabilityLabel, entry.recipeLabel],
    );
  }

  /// Builds a signal from shared recipe production review data.
  factory FnbAttentionSignal.fromRecipeProductionEntry(
    FnbRecipeProductionEntry entry,
  ) {
    final status = !entry.needsAttention
        ? FnbServiceStatus.calm
        : entry.attentionRank <= 1
        ? FnbServiceStatus.critical
        : FnbServiceStatus.busy;

    return FnbAttentionSignal(
      id: 'recipe-production-${entry.id}',
      kind: FnbAttentionSignalKind.recipeProduction,
      title: entry.name,
      detail: '${entry.stationLabel} - ${entry.productionLabel}',
      valueLabel: entry.attentionLabel,
      status: status,
      urgencyScore: entry.needsAttention ? 100 - entry.attentionRank * 10 : 0,
      sourceId: entry.id,
      targetId: entry.id,
      tags: [entry.menuStatusLabel, entry.dietaryLabel],
    );
  }

  final String id;
  final FnbAttentionSignalKind kind;
  final String title;
  final String detail;
  final String? valueLabel;
  final FnbServiceStatus status;
  final int urgencyScore;
  final String? sourceId;
  final String? targetId;
  final DateTime? dueAt;
  final List<String> tags;

  bool get needsAttention => status.needsAttention;

  int get priorityScore => status.priorityScore * 100000 + urgencyScore;

  String get kindLabel => kind.label;

  String get statusLabel => status.label;

  String get accessibilityLabel {
    return [kind.label, title, ?valueLabel, detail, status.label].join(', ');
  }

  FnbAttentionSignal copyWith({
    String? title,
    String? detail,
    String? valueLabel,
    FnbServiceStatus? status,
    int? urgencyScore,
    String? sourceId,
    String? targetId,
    DateTime? dueAt,
    List<String>? tags,
  }) {
    return FnbAttentionSignal(
      id: id,
      kind: kind,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      valueLabel: valueLabel ?? this.valueLabel,
      status: status ?? this.status,
      urgencyScore: urgencyScore ?? this.urgencyScore,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      dueAt: dueAt ?? this.dueAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Orders attention signals by pressure, score, due time, and title.
int compareFnbAttentionSignals(
  FnbAttentionSignal first,
  FnbAttentionSignal second,
) {
  final priority = second.priorityScore.compareTo(first.priorityScore);
  if (priority != 0) return priority;

  final firstDueAt = first.dueAt;
  final secondDueAt = second.dueAt;
  if (firstDueAt != null && secondDueAt != null) {
    final due = firstDueAt.compareTo(secondDueAt);
    if (due != 0) return due;
  } else if (firstDueAt != null) {
    return -1;
  } else if (secondDueAt != null) {
    return 1;
  }

  final kind = first.kind.index.compareTo(second.kind.index);
  if (kind != 0) return kind;

  return first.title.compareTo(second.title);
}

String _slug(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('(^-|-\$)'), '');
  return normalized.isEmpty ? 'signal' : normalized;
}
