import '../../order/models/order.dart';
import 'pos_experience.dart';
import 'pos_experience_manifest.dart';
import 'pos_mode_switch_availability.dart';
import 'pos_mode_switch_controller.dart';
import 'pos_mode_switch_filter.dart';
import 'pos_mode_switch_policy.dart';
import 'pos_mode_switch_preview.dart';

class POSModeSwitchAvailabilityFilter {
  final String query;
  final POSModeSwitchFilterStatus status;
  final Order? order;
  final POSExperience? currentExperience;

  const POSModeSwitchAvailabilityFilter({
    this.query = '',
    this.status = POSModeSwitchFilterStatus.all,
    this.order,
    this.currentExperience,
  });

  bool get isActive =>
      query.trim().isNotEmpty || status != POSModeSwitchFilterStatus.all;

  POSModeSwitchAvailabilityFilterResult apply(POSModeSwitchState state) {
    final effectiveCurrentExperience =
        currentExperience ?? state.currentExperience;
    final sections = <POSModeSwitchAvailabilitySection>[];

    for (final section in state.sections) {
      final availabilities = section.options
          .map(
            (option) => POSModeSwitchAvailability.evaluate(
              option: option,
              order: order,
            ),
          )
          .where(
            (availability) => _matchesAvailability(
              section,
              availability,
              effectiveCurrentExperience,
            ),
          )
          .toList(growable: false);
      if (availabilities.isEmpty) continue;

      sections.add(
        POSModeSwitchAvailabilitySection(
          productLine: section.productLine,
          availabilities: availabilities,
        ),
      );
    }

    return POSModeSwitchAvailabilityFilterResult(
      filter: this,
      sections: sections,
      totalCount: state.options.length,
    );
  }

  bool _matchesAvailability(
    POSModeSwitchSection section,
    POSModeSwitchAvailability availability,
    POSExperience currentExperience,
  ) {
    return _matchesStatus(availability) &&
        _matchesQuery(section, availability, currentExperience);
  }

  bool _matchesStatus(
    POSModeSwitchAvailability availability, [
    POSModeSwitchFilterStatus? targetStatus,
  ]) {
    final decision = availability.option.decision;
    final resolvedStatus = targetStatus ?? status;

    switch (resolvedStatus) {
      case POSModeSwitchFilterStatus.all:
        return true;
      case POSModeSwitchFilterStatus.launchReady:
        final warningCount = decision.launchChecklist?.warningCount ?? 0;
        return decision.disposition == POSModeSwitchDisposition.allowed &&
            warningCount == 0 &&
            !availability.orderDecision.needsConfirmation &&
            !availability.orderDecision.isBlocked;
      case POSModeSwitchFilterStatus.review:
        final warningCount = decision.launchChecklist?.warningCount ?? 0;
        return decision.disposition == POSModeSwitchDisposition.allowed &&
            warningCount > 0 &&
            !availability.orderDecision.needsConfirmation &&
            !availability.orderDecision.isBlocked;
      case POSModeSwitchFilterStatus.confirm:
        return availability.needsConfirmation;
      case POSModeSwitchFilterStatus.blocked:
        return availability.isBlocked;
    }
  }

  bool _matchesQuery(
    POSModeSwitchSection section,
    POSModeSwitchAvailability availability,
    POSExperience currentExperience,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return _searchableTerms(
      section,
      availability,
      currentExperience,
    ).any((term) => term.toLowerCase().contains(normalizedQuery));
  }

  Iterable<String> _searchableTerms(
    POSModeSwitchSection section,
    POSModeSwitchAvailability availability,
    POSExperience currentExperience,
  ) sync* {
    final option = availability.option;
    final experience = option.experience;
    final manifest = experience.manifest;
    final profile = option.productProfile;
    final preview = POSModeSwitchPreview.evaluate(
      availability: availability,
      currentExperience: currentExperience,
    );

    yield section.productLine;
    yield experience.id;
    yield experience.label;
    yield experience.description;
    yield manifest.productLine;
    yield manifest.archetypeKey;
    yield manifest.archetypeLabel;
    yield manifest.releaseStage.label;
    yield option.decision.statusLabel;
    yield availability.statusLabel;
    yield availability.orderDecision.statusLabel;

    for (final formFactor in manifest.supportedFormFactors) {
      yield formFactor.label;
    }
    for (final trait in manifest.traits) {
      yield trait;
    }
    for (final dataTrait in manifest.dataTraits) {
      yield dataTrait;
    }
    for (final previewTerm in preview.searchTerms) {
      yield previewTerm;
    }

    if (profile != null) {
      yield profile.id;
      yield profile.label;
      yield profile.description;
      for (final label in profile.dataTraitLabels) {
        yield label;
      }
    }
  }

  POSModeSwitchAvailabilityFilter copyWith({
    String? query,
    POSModeSwitchFilterStatus? status,
    Order? order,
    POSExperience? currentExperience,
  }) {
    return POSModeSwitchAvailabilityFilter(
      query: query ?? this.query,
      status: status ?? this.status,
      order: order ?? this.order,
      currentExperience: currentExperience ?? this.currentExperience,
    );
  }
}

class POSModeSwitchAvailabilitySection {
  final String productLine;
  final List<POSModeSwitchAvailability> availabilities;

  POSModeSwitchAvailabilitySection({
    required this.productLine,
    required Iterable<POSModeSwitchAvailability> availabilities,
  }) : availabilities = List.unmodifiable(availabilities);

  int get optionCount => availabilities.length;
}

class POSModeSwitchAvailabilityFilterResult {
  final POSModeSwitchAvailabilityFilter filter;
  final List<POSModeSwitchAvailabilitySection> sections;
  final int totalCount;

  POSModeSwitchAvailabilityFilterResult({
    required this.filter,
    required Iterable<POSModeSwitchAvailabilitySection> sections,
    required this.totalCount,
  }) : sections = List.unmodifiable(sections);

  Iterable<POSModeSwitchAvailability> get availabilities {
    return sections.expand((section) => section.availabilities);
  }

  Iterable<POSModeSwitchOption> get options {
    return availabilities.map((availability) => availability.option);
  }

  int get matchCount => availabilities.length;

  bool get isEmpty => matchCount == 0;
}

class POSModeSwitchAvailabilityCounts {
  final int all;
  final int launchReady;
  final int review;
  final int confirm;
  final int blocked;

  const POSModeSwitchAvailabilityCounts({
    required this.all,
    required this.launchReady,
    required this.review,
    required this.confirm,
    required this.blocked,
  });

  factory POSModeSwitchAvailabilityCounts.fromState(
    POSModeSwitchState state, {
    String query = '',
    Order? order,
    POSExperience? currentExperience,
  }) {
    final effectiveCurrentExperience =
        currentExperience ?? state.currentExperience;
    final filter = POSModeSwitchAvailabilityFilter(
      query: query,
      order: order,
      currentExperience: effectiveCurrentExperience,
    );
    var all = 0;
    var launchReady = 0;
    var review = 0;
    var confirm = 0;
    var blocked = 0;

    for (final section in state.sections) {
      for (final option in section.options) {
        final availability = POSModeSwitchAvailability.evaluate(
          option: option,
          order: order,
        );
        if (!filter._matchesQuery(
          section,
          availability,
          effectiveCurrentExperience,
        )) {
          continue;
        }

        all += 1;
        if (filter._matchesStatus(
          availability,
          POSModeSwitchFilterStatus.launchReady,
        )) {
          launchReady += 1;
        }
        if (filter._matchesStatus(
          availability,
          POSModeSwitchFilterStatus.review,
        )) {
          review += 1;
        }
        if (filter._matchesStatus(
          availability,
          POSModeSwitchFilterStatus.confirm,
        )) {
          confirm += 1;
        }
        if (filter._matchesStatus(
          availability,
          POSModeSwitchFilterStatus.blocked,
        )) {
          blocked += 1;
        }
      }
    }

    return POSModeSwitchAvailabilityCounts(
      all: all,
      launchReady: launchReady,
      review: review,
      confirm: confirm,
      blocked: blocked,
    );
  }

  int countFor(POSModeSwitchFilterStatus status) {
    switch (status) {
      case POSModeSwitchFilterStatus.all:
        return all;
      case POSModeSwitchFilterStatus.launchReady:
        return launchReady;
      case POSModeSwitchFilterStatus.review:
        return review;
      case POSModeSwitchFilterStatus.confirm:
        return confirm;
      case POSModeSwitchFilterStatus.blocked:
        return blocked;
    }
  }
}
