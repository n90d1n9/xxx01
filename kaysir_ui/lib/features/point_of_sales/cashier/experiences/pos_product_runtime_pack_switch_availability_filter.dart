import '../../order/models/order.dart';
import '../states/pos_layout_provider.dart';
import 'pos_commerce_channel.dart';
import 'pos_experience_manifest.dart';
import 'pos_product_runtime_pack.dart';
import 'pos_product_runtime_pack_catalog.dart';
import 'pos_product_runtime_pack_switch_availability.dart';
import 'pos_product_runtime_pack_switch_plan.dart';

enum POSProductRuntimePackSwitchAvailabilityFilterStatus {
  all,
  current,
  available,
  confirm,
  blocked,
}

extension POSProductRuntimePackSwitchAvailabilityFilterStatusLabel
    on POSProductRuntimePackSwitchAvailabilityFilterStatus {
  String get label {
    switch (this) {
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.all:
        return 'All';
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.current:
        return 'Current';
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.available:
        return 'Available';
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.confirm:
        return 'Review';
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.blocked:
        return 'Blocked';
    }
  }
}

class POSProductRuntimePackSwitchAvailabilityFilter {
  final String query;
  final POSProductRuntimePackSwitchAvailabilityFilterStatus status;
  final Order? order;
  final bool preserveCurrentSelections;

  const POSProductRuntimePackSwitchAvailabilityFilter({
    this.query = '',
    this.status = POSProductRuntimePackSwitchAvailabilityFilterStatus.all,
    this.order,
    this.preserveCurrentSelections = true,
  });

  bool get isActive {
    return query.trim().isNotEmpty ||
        status != POSProductRuntimePackSwitchAvailabilityFilterStatus.all;
  }

  POSProductRuntimePackSwitchAvailabilityFilterResult apply({
    required POSProductRuntimePackCatalog catalog,
    required POSProductRuntimePack currentPack,
    required String currentExperienceId,
    required String currentCommerceChannelId,
  }) {
    final sections = <POSProductRuntimePackSwitchAvailabilitySection>[];

    for (final section in catalog.sections) {
      final availabilities = section.packs
          .map(
            (pack) => _availabilityFor(
              pack,
              currentPack: currentPack,
              currentExperienceId: currentExperienceId,
              currentCommerceChannelId: currentCommerceChannelId,
            ),
          )
          .where((availability) => _matchesAvailability(section, availability))
          .toList(growable: false);
      if (availabilities.isEmpty) continue;

      sections.add(
        POSProductRuntimePackSwitchAvailabilitySection(
          productLine: section.productLine,
          availabilities: availabilities,
        ),
      );
    }

    return POSProductRuntimePackSwitchAvailabilityFilterResult(
      filter: this,
      sections: sections,
      totalCount: catalog.packs.length,
    );
  }

  bool _matchesAvailability(
    POSProductRuntimePackCatalogSection section,
    POSProductRuntimePackSwitchAvailability availability,
  ) {
    return _matchesStatus(availability) && _matchesQuery(section, availability);
  }

  bool _matchesStatus(
    POSProductRuntimePackSwitchAvailability availability, [
    POSProductRuntimePackSwitchAvailabilityFilterStatus? targetStatus,
  ]) {
    final resolvedStatus = targetStatus ?? status;

    switch (resolvedStatus) {
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.all:
        return true;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.current:
        return availability.status ==
            POSProductRuntimePackSwitchAvailabilityStatus.current;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.available:
        return availability.status ==
            POSProductRuntimePackSwitchAvailabilityStatus.available;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.confirm:
        return availability.status ==
            POSProductRuntimePackSwitchAvailabilityStatus.confirm;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.blocked:
        return availability.status ==
            POSProductRuntimePackSwitchAvailabilityStatus.blocked;
    }
  }

  bool _matchesQuery(
    POSProductRuntimePackCatalogSection section,
    POSProductRuntimePackSwitchAvailability availability,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return _searchableTerms(
      section,
      availability,
    ).any((term) => term.toLowerCase().contains(normalizedQuery));
  }

  Iterable<String> _searchableTerms(
    POSProductRuntimePackCatalogSection section,
    POSProductRuntimePackSwitchAvailability availability,
  ) sync* {
    final plan = availability.plan;
    final pack = plan.pack;
    final experience = plan.experience;
    final commerceChannel = plan.commerceChannel;

    yield section.productLine;
    yield pack.id;
    yield pack.label;
    yield pack.description;
    yield pack.productLine;
    yield availability.statusLabel;
    yield plan.impactLabel;
    yield plan.selectionLabel;
    yield plan.experienceLabel;
    yield plan.commerceChannelLabel;

    if (experience != null) {
      yield experience.id;
      yield experience.label;
      yield experience.description;
      yield experience.manifest.productLine;
      yield experience.manifest.archetypeKey;
      yield experience.manifest.archetypeLabel;
      yield experience.manifest.releaseStage.label;
      yield experience.preferredLayout.label;
      for (final trait in experience.manifest.traits) {
        yield trait;
      }
      for (final dataTrait in experience.manifest.dataTraits) {
        yield dataTrait;
      }
    }

    if (commerceChannel != null) {
      yield commerceChannel.id;
      yield commerceChannel.label;
      yield commerceChannel.description;
      yield commerceChannel.kind.label;
      yield commerceChannel.preferredLayout.label;
      yield commerceChannel.capabilitySummary;
      yield commerceChannel.fulfillmentSummary;
      yield commerceChannel.traitSummary;
    }

    for (final profile in pack.productProfileCatalog.profiles) {
      yield profile.id;
      yield profile.label;
      yield profile.description;
      yield profile.experience.id;
      yield profile.experience.label;
      yield profile.launchChecklist.statusLabel;
      for (final label in profile.dataTraitLabels) {
        yield label;
      }
    }

    for (final channel in pack.commerceChannelRegistry.channels) {
      yield channel.id;
      yield channel.label;
      yield channel.kind.label;
      yield channel.capabilitySummary;
      yield channel.fulfillmentSummary;
    }
  }

  POSProductRuntimePackSwitchAvailability _availabilityFor(
    POSProductRuntimePack pack, {
    required POSProductRuntimePack currentPack,
    required String currentExperienceId,
    required String currentCommerceChannelId,
  }) {
    final plan = POSProductRuntimePackSwitchPlan.resolve(
      pack: pack,
      currentExperienceId: currentExperienceId,
      currentCommerceChannelId: currentCommerceChannelId,
      preserveCurrentSelections: preserveCurrentSelections,
    );

    return POSProductRuntimePackSwitchAvailability.evaluate(
      plan: plan,
      currentPack: currentPack,
      order: order,
    );
  }

  POSProductRuntimePackSwitchAvailabilityFilter copyWith({
    String? query,
    POSProductRuntimePackSwitchAvailabilityFilterStatus? status,
    Order? order,
    bool? preserveCurrentSelections,
  }) {
    return POSProductRuntimePackSwitchAvailabilityFilter(
      query: query ?? this.query,
      status: status ?? this.status,
      order: order ?? this.order,
      preserveCurrentSelections:
          preserveCurrentSelections ?? this.preserveCurrentSelections,
    );
  }
}

class POSProductRuntimePackSwitchAvailabilitySection {
  final String productLine;
  final List<POSProductRuntimePackSwitchAvailability> availabilities;

  POSProductRuntimePackSwitchAvailabilitySection({
    required this.productLine,
    required Iterable<POSProductRuntimePackSwitchAvailability> availabilities,
  }) : availabilities = List.unmodifiable(availabilities);

  int get packCount => availabilities.length;
}

class POSProductRuntimePackSwitchAvailabilityFilterResult {
  final POSProductRuntimePackSwitchAvailabilityFilter filter;
  final List<POSProductRuntimePackSwitchAvailabilitySection> sections;
  final int totalCount;

  POSProductRuntimePackSwitchAvailabilityFilterResult({
    required this.filter,
    required Iterable<POSProductRuntimePackSwitchAvailabilitySection> sections,
    required this.totalCount,
  }) : sections = List.unmodifiable(sections);

  Iterable<POSProductRuntimePackSwitchAvailability> get availabilities {
    return sections.expand((section) => section.availabilities);
  }

  Iterable<POSProductRuntimePack> get packs {
    return availabilities.map((availability) => availability.plan.pack);
  }

  int get matchCount => availabilities.length;

  bool get isEmpty => matchCount == 0;
}

class POSProductRuntimePackSwitchAvailabilityCounts {
  final int all;
  final int current;
  final int available;
  final int confirm;
  final int blocked;

  const POSProductRuntimePackSwitchAvailabilityCounts({
    required this.all,
    required this.current,
    required this.available,
    required this.confirm,
    required this.blocked,
  });

  factory POSProductRuntimePackSwitchAvailabilityCounts.fromCatalog({
    required POSProductRuntimePackCatalog catalog,
    required POSProductRuntimePack currentPack,
    required String currentExperienceId,
    required String currentCommerceChannelId,
    String query = '',
    Order? order,
    bool preserveCurrentSelections = true,
  }) {
    final filter = POSProductRuntimePackSwitchAvailabilityFilter(
      query: query,
      order: order,
      preserveCurrentSelections: preserveCurrentSelections,
    );
    var all = 0;
    var current = 0;
    var available = 0;
    var confirm = 0;
    var blocked = 0;

    for (final section in catalog.sections) {
      for (final pack in section.packs) {
        final availability = filter._availabilityFor(
          pack,
          currentPack: currentPack,
          currentExperienceId: currentExperienceId,
          currentCommerceChannelId: currentCommerceChannelId,
        );
        if (!filter._matchesQuery(section, availability)) continue;

        all += 1;
        if (filter._matchesStatus(
          availability,
          POSProductRuntimePackSwitchAvailabilityFilterStatus.current,
        )) {
          current += 1;
        }
        if (filter._matchesStatus(
          availability,
          POSProductRuntimePackSwitchAvailabilityFilterStatus.available,
        )) {
          available += 1;
        }
        if (filter._matchesStatus(
          availability,
          POSProductRuntimePackSwitchAvailabilityFilterStatus.confirm,
        )) {
          confirm += 1;
        }
        if (filter._matchesStatus(
          availability,
          POSProductRuntimePackSwitchAvailabilityFilterStatus.blocked,
        )) {
          blocked += 1;
        }
      }
    }

    return POSProductRuntimePackSwitchAvailabilityCounts(
      all: all,
      current: current,
      available: available,
      confirm: confirm,
      blocked: blocked,
    );
  }

  int countFor(POSProductRuntimePackSwitchAvailabilityFilterStatus status) {
    switch (status) {
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.all:
        return all;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.current:
        return current;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.available:
        return available;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.confirm:
        return confirm;
      case POSProductRuntimePackSwitchAvailabilityFilterStatus.blocked:
        return blocked;
    }
  }
}
