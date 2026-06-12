import 'billing_product_release_channel_registry.dart';
import 'billing_product_release_edition.dart';

enum BillingProductReleaseChannelCellState {
  publishNow,
  review,
  blocked,
  notTargeted,
}

class BillingProductReleaseChannelCell {
  final BillingProductReleaseChannelDefinition channel;
  final BillingProductReleaseEditionPlan editionPlan;
  final BillingProductReleaseChannelCellState state;

  BillingProductReleaseChannelCell({
    required this.channel,
    required this.editionPlan,
    required this.state,
  });

  factory BillingProductReleaseChannelCell.forEdition({
    required BillingProductReleaseChannelDefinition channel,
    required BillingProductReleaseEditionPlan editionPlan,
  }) {
    if (!channel.targetsEdition(editionPlan.id)) {
      return BillingProductReleaseChannelCell(
        channel: channel,
        editionPlan: editionPlan,
        state: BillingProductReleaseChannelCellState.notTargeted,
      );
    }

    return BillingProductReleaseChannelCell(
      channel: channel,
      editionPlan: editionPlan,
      state: _stateForEdition(editionPlan),
    );
  }

  bool get isTargeted {
    return state != BillingProductReleaseChannelCellState.notTargeted;
  }

  bool get canPublish {
    return state == BillingProductReleaseChannelCellState.publishNow;
  }

  bool get needsReview {
    return state == BillingProductReleaseChannelCellState.review;
  }

  bool get isBlocked {
    return state == BillingProductReleaseChannelCellState.blocked;
  }

  String get stateLabel {
    return switch (state) {
      BillingProductReleaseChannelCellState.publishNow => 'Publish',
      BillingProductReleaseChannelCellState.review => 'Review',
      BillingProductReleaseChannelCellState.blocked => 'Blocked',
      BillingProductReleaseChannelCellState.notTargeted => 'Not targeted',
    };
  }

  String get actionLabel {
    return switch (state) {
      BillingProductReleaseChannelCellState.publishNow => 'Publish channel',
      BillingProductReleaseChannelCellState.review => 'Review channel',
      BillingProductReleaseChannelCellState.blocked => 'Clear blockers',
      BillingProductReleaseChannelCellState.notTargeted => 'Not targeted',
    };
  }

  String get actionDetail {
    return switch (state) {
      BillingProductReleaseChannelCellState.publishNow =>
        '${editionPlan.label} can launch on ${channel.label}.',
      BillingProductReleaseChannelCellState.review =>
        '${editionPlan.label} can stage on ${channel.label} after review.',
      BillingProductReleaseChannelCellState.blocked =>
        '${editionPlan.label} needs blockers cleared before ${channel.label}.',
      BillingProductReleaseChannelCellState.notTargeted =>
        '${editionPlan.label} is not planned for ${channel.label}.',
    };
  }

  Map<String, Object?> get payload {
    return {
      'channelKey': channel.key,
      'editionKey': editionPlan.id,
      'state': state.name,
      'stateLabel': stateLabel,
      'isTargeted': isTargeted,
    };
  }
}

class BillingProductReleaseChannelRow {
  final BillingProductReleaseChannelDefinition channel;
  final List<BillingProductReleaseChannelCell> cells;

  BillingProductReleaseChannelRow({
    required this.channel,
    Iterable<BillingProductReleaseChannelCell> cells = const [],
  }) : cells = List.unmodifiable(cells);

  int get targetedCount => cells.where((cell) => cell.isTargeted).length;

  int get publishNowCount => cells.where((cell) => cell.canPublish).length;

  int get reviewCount => cells.where((cell) => cell.needsReview).length;

  int get blockedCount => cells.where((cell) => cell.isBlocked).length;

  List<BillingProductReleaseChannelCell> get targetedCells {
    return List.unmodifiable(cells.where((cell) => cell.isTargeted));
  }

  Map<String, Object?> get payload {
    return {
      'channelKey': channel.key,
      'channelLabel': channel.label,
      'targetedCount': targetedCount,
      'publishNowCount': publishNowCount,
      'reviewCount': reviewCount,
      'blockedCount': blockedCount,
      'cells': cells.map((cell) => cell.payload).toList(growable: false),
    };
  }
}

class BillingProductReleaseChannelMatrix {
  final List<BillingProductReleaseChannelRow> rows;

  BillingProductReleaseChannelMatrix({
    Iterable<BillingProductReleaseChannelRow> rows = const [],
  }) : rows = List.unmodifiable(rows);

  factory BillingProductReleaseChannelMatrix.forEditionCatalog({
    required BillingProductReleaseChannelRegistry registry,
    required BillingProductReleaseEditionCatalog editionCatalog,
  }) {
    return BillingProductReleaseChannelMatrix(
      rows: registry.channels.map(
        (channel) => BillingProductReleaseChannelRow(
          channel: channel,
          cells: editionCatalog.plans.map(
            (plan) => BillingProductReleaseChannelCell.forEdition(
              channel: channel,
              editionPlan: plan,
            ),
          ),
        ),
      ),
    );
  }

  bool get isEmpty => rows.isEmpty;

  int get channelCount => rows.length;

  int get targetedCellCount {
    return rows.fold(0, (total, row) => total + row.targetedCount);
  }

  int get publishNowCellCount {
    return rows.fold(0, (total, row) => total + row.publishNowCount);
  }

  int get reviewCellCount {
    return rows.fold(0, (total, row) => total + row.reviewCount);
  }

  int get blockedCellCount {
    return rows.fold(0, (total, row) => total + row.blockedCount);
  }

  List<BillingProductReleaseChannelCell> get targetedCells {
    return List.unmodifiable(rows.expand((row) => row.targetedCells));
  }

  BillingProductReleaseChannelRow? rowForChannel(String id) {
    final key = billingProductReleaseChannelKey(id);

    for (final row in rows) {
      if (row.channel.key == key) return row;
    }

    return null;
  }

  BillingProductReleaseChannelRow requireRowForChannel(String id) {
    final row = rowForChannel(id);
    if (row == null) {
      throw StateError('No billing product release channel row for $id.');
    }

    return row;
  }

  Map<String, Object?> get payload {
    return {
      'channelCount': channelCount,
      'targetedCellCount': targetedCellCount,
      'publishNowCellCount': publishNowCellCount,
      'reviewCellCount': reviewCellCount,
      'blockedCellCount': blockedCellCount,
      'rows': rows.map((row) => row.payload).toList(growable: false),
    };
  }

  String get summaryLabel {
    if (isEmpty) {
      return 'No billing product release channels are available.';
    }
    if (targetedCellCount == 0) {
      return 'No product release editions are targeted to channels yet.';
    }
    if (blockedCellCount > 0) {
      return '$blockedCellCount ${_plural(blockedCellCount, 'channel release')} '
          'need blockers cleared.';
    }
    if (publishNowCellCount > 0 && reviewCellCount > 0) {
      return '$publishNowCellCount '
          '${_plural(publishNowCellCount, 'channel release')} can publish; '
          '$reviewCellCount need review.';
    }
    if (reviewCellCount > 0) {
      return '$reviewCellCount ${_plural(reviewCellCount, 'channel release')} '
          'need review.';
    }

    return '$publishNowCellCount '
        '${_plural(publishNowCellCount, 'channel release')} can publish now.';
  }
}

BillingProductReleaseChannelCellState _stateForEdition(
  BillingProductReleaseEditionPlan editionPlan,
) {
  if (editionPlan.canPublish) {
    return BillingProductReleaseChannelCellState.publishNow;
  }
  if (editionPlan.needsReview) {
    return BillingProductReleaseChannelCellState.review;
  }

  return BillingProductReleaseChannelCellState.blocked;
}

String _plural(int count, String singular) {
  return count == 1 ? singular : '${singular}s';
}
