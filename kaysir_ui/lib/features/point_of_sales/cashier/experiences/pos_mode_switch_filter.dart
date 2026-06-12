import 'pos_experience_manifest.dart';
import 'pos_mode_switch_controller.dart';
import 'pos_mode_switch_policy.dart';

enum POSModeSwitchFilterStatus { all, launchReady, review, confirm, blocked }

class POSModeSwitchFilter {
  final String query;
  final POSModeSwitchFilterStatus status;

  const POSModeSwitchFilter({
    this.query = '',
    this.status = POSModeSwitchFilterStatus.all,
  });

  bool get isActive =>
      query.trim().isNotEmpty || status != POSModeSwitchFilterStatus.all;

  POSModeSwitchFilterResult apply(POSModeSwitchState state) {
    final sections = <POSModeSwitchSection>[];

    for (final section in state.sections) {
      final options = section.options
          .where((option) => _matchesOption(section, option))
          .toList(growable: false);
      if (options.isEmpty) continue;

      sections.add(
        POSModeSwitchSection(
          productLine: section.productLine,
          options: options,
        ),
      );
    }

    return POSModeSwitchFilterResult(
      filter: this,
      sections: sections,
      totalCount: state.options.length,
    );
  }

  bool _matchesOption(
    POSModeSwitchSection section,
    POSModeSwitchOption option,
  ) {
    return _matchesStatus(option) && _matchesQuery(section, option);
  }

  bool _matchesStatus(POSModeSwitchOption option) {
    final decision = option.decision;

    switch (status) {
      case POSModeSwitchFilterStatus.all:
        return true;
      case POSModeSwitchFilterStatus.launchReady:
        final warningCount = decision.launchChecklist?.warningCount ?? 0;
        return decision.disposition == POSModeSwitchDisposition.allowed &&
            warningCount == 0;
      case POSModeSwitchFilterStatus.review:
        final warningCount = decision.launchChecklist?.warningCount ?? 0;
        return decision.disposition == POSModeSwitchDisposition.allowed &&
            warningCount > 0;
      case POSModeSwitchFilterStatus.confirm:
        return decision.needsConfirmation;
      case POSModeSwitchFilterStatus.blocked:
        return decision.isBlocked;
    }
  }

  bool _matchesQuery(POSModeSwitchSection section, POSModeSwitchOption option) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return _searchableTerms(
      section,
      option,
    ).any((term) => term.toLowerCase().contains(normalizedQuery));
  }

  Iterable<String> _searchableTerms(
    POSModeSwitchSection section,
    POSModeSwitchOption option,
  ) sync* {
    final experience = option.experience;
    final manifest = experience.manifest;
    final profile = option.productProfile;

    yield section.productLine;
    yield experience.id;
    yield experience.label;
    yield experience.description;
    yield manifest.productLine;
    yield manifest.archetypeKey;
    yield manifest.archetypeLabel;
    yield manifest.releaseStage.label;
    yield option.decision.statusLabel;

    for (final formFactor in manifest.supportedFormFactors) {
      yield formFactor.label;
    }
    for (final trait in manifest.traits) {
      yield trait;
    }
    for (final dataTrait in manifest.dataTraits) {
      yield dataTrait;
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

  POSModeSwitchFilter copyWith({
    String? query,
    POSModeSwitchFilterStatus? status,
  }) {
    return POSModeSwitchFilter(
      query: query ?? this.query,
      status: status ?? this.status,
    );
  }
}

class POSModeSwitchFilterResult {
  final POSModeSwitchFilter filter;
  final List<POSModeSwitchSection> sections;
  final int totalCount;

  POSModeSwitchFilterResult({
    required this.filter,
    required Iterable<POSModeSwitchSection> sections,
    required this.totalCount,
  }) : sections = List.unmodifiable(sections);

  Iterable<POSModeSwitchOption> get options {
    return sections.expand((section) => section.options);
  }

  int get matchCount => options.length;

  bool get isEmpty => matchCount == 0;
}

extension POSModeSwitchFilterStatusLabel on POSModeSwitchFilterStatus {
  String get label {
    switch (this) {
      case POSModeSwitchFilterStatus.all:
        return 'All';
      case POSModeSwitchFilterStatus.launchReady:
        return 'Ready';
      case POSModeSwitchFilterStatus.review:
        return 'Review';
      case POSModeSwitchFilterStatus.confirm:
        return 'Confirm';
      case POSModeSwitchFilterStatus.blocked:
        return 'Blocked';
    }
  }
}
