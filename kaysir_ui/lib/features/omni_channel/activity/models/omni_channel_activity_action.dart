import 'omni_channel_activity.dart';

typedef OmniChannelActivityActionResolver =
    OmniChannelActivityAction? Function(OmniChannelActivityEntry entry);

typedef OmniChannelActivityActionContributor =
    Iterable<OmniChannelActivityAction> Function(
      OmniChannelActivityEntry entry,
    );

typedef OmniChannelActivityActionSelection =
    void Function(
      OmniChannelActivityEntry entry,
      OmniChannelActivityAction action,
    );

enum OmniChannelActivityActionIntent { navigate, retry, review, inspect }

/// Human-readable metadata for one registered activity action contributor.
class OmniChannelActivityActionContributorDescriptor {
  final String id;
  final String label;
  final String description;

  const OmniChannelActivityActionContributorDescriptor({
    required this.id,
    required this.label,
    this.description = '',
  });
}

/// Navigation or workflow action resolved from an omni-channel activity event.
class OmniChannelActivityAction {
  final String id;
  final String label;
  final String location;
  final String tooltip;
  final OmniChannelActivityActionIntent intent;
  final int priority;
  final bool enabled;
  final String? disabledReason;

  const OmniChannelActivityAction({
    this.id = '',
    required this.label,
    required this.location,
    required this.tooltip,
    this.intent = OmniChannelActivityActionIntent.navigate,
    this.priority = 0,
    this.enabled = true,
    this.disabledReason,
  });

  String get identity => id.trim().isEmpty ? location : id;

  bool get isEnabled => enabled;

  String get effectiveTooltip {
    final reason = disabledReason?.trim() ?? '';
    if (!enabled && reason.isNotEmpty) return reason;

    return tooltip;
  }
}

/// Ordered action collection split into primary, secondary, and availability buckets.
class OmniChannelActivityActionSet {
  final List<OmniChannelActivityAction> actions;

  OmniChannelActivityActionSet(Iterable<OmniChannelActivityAction> actions)
    : actions = List.unmodifiable(actions);

  const OmniChannelActivityActionSet.empty() : actions = const [];

  bool get isEmpty => actions.isEmpty;

  bool get isNotEmpty => actions.isNotEmpty;

  OmniChannelActivityAction? get primary {
    if (actions.isEmpty) return null;

    return actions.first;
  }

  List<OmniChannelActivityAction> get secondary {
    if (actions.length <= 1) return const [];

    return actions.skip(1).toList(growable: false);
  }

  List<OmniChannelActivityAction> get enabledActions {
    return actions.where((action) => action.isEnabled).toList(growable: false);
  }

  List<OmniChannelActivityAction> get disabledActions {
    return actions.where((action) => !action.isEnabled).toList(growable: false);
  }
}

/// Composes activity actions from registered product modules.
class OmniChannelActivityActionRegistry {
  final List<OmniChannelActivityActionContributor> contributors;
  final List<OmniChannelActivityActionContributorDescriptor>
  contributorDescriptors;

  const OmniChannelActivityActionRegistry({
    required this.contributors,
    this.contributorDescriptors = const [],
  });

  List<OmniChannelActivityActionContributorDescriptor>
  get resolvedContributorDescriptors {
    return List.unmodifiable([
      for (var index = 0; index < contributors.length; index++)
        descriptorFor(index),
    ]);
  }

  OmniChannelActivityActionContributorDescriptor descriptorFor(int index) {
    if (index >= 0 && index < contributorDescriptors.length) {
      return contributorDescriptors[index];
    }

    final contributorNumber = index + 1;
    return OmniChannelActivityActionContributorDescriptor(
      id: 'action-contributor-$contributorNumber',
      label: 'Action contributor $contributorNumber',
      description: 'Registered action contributor',
    );
  }

  List<OmniChannelActivityAction> actionsFor(OmniChannelActivityEntry entry) {
    final actions = <OmniChannelActivityAction>[];
    final seen = <String>{};

    for (final contributor in contributors) {
      for (final action in contributor(entry)) {
        if (seen.add(action.identity)) actions.add(action);
      }
    }

    actions.sort((left, right) {
      final priorityComparison = left.priority.compareTo(right.priority);
      if (priorityComparison != 0) return priorityComparison;
      return left.label.compareTo(right.label);
    });
    return List.unmodifiable(actions);
  }

  OmniChannelActivityActionSet actionSetFor(OmniChannelActivityEntry entry) {
    return OmniChannelActivityActionSet(actionsFor(entry));
  }

  OmniChannelActivityAction? primaryActionFor(OmniChannelActivityEntry entry) {
    return actionSetFor(entry).primary;
  }

  OmniChannelActivityActionRegistry extendWith(
    Iterable<OmniChannelActivityActionContributor> nextContributors, {
    Iterable<OmniChannelActivityActionContributorDescriptor>
        contributorDescriptors =
        const [],
  }) {
    final resolvedNextContributors = nextContributors.toList(growable: false);
    final resolvedNextDescriptors = contributorDescriptors.toList(
      growable: false,
    );

    return OmniChannelActivityActionRegistry(
      contributors: [...contributors, ...resolvedNextContributors],
      contributorDescriptors: [
        ...resolvedContributorDescriptors,
        for (var index = 0; index < resolvedNextContributors.length; index++)
          index < resolvedNextDescriptors.length
              ? resolvedNextDescriptors[index]
              : OmniChannelActivityActionContributorDescriptor(
                id: 'action-contributor-${contributors.length + index + 1}',
                label: 'Action contributor ${contributors.length + index + 1}',
                description: 'Registered action contributor',
              ),
      ],
    );
  }
}
