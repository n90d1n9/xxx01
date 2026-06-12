import '../models/restaurant_operation_activity.dart';

/// Provides reusable helpers for immutable workspace command mutations.
class RestaurantWorkspaceMutationToolkit {
  const RestaurantWorkspaceMutationToolkit();

  RestaurantOperationActivity activity(
    DateTime now,
    RestaurantOperationActivityKind kind, {
    required String title,
    required String description,
  }) {
    return RestaurantOperationActivity(
      id: '${kind.name}-${now.microsecondsSinceEpoch}',
      kind: kind,
      title: title,
      description: description,
      createdAt: now,
    );
  }

  List<T> replaceWhere<T>(
    Iterable<T> values, {
    required bool Function(T value) test,
    required T Function(T value) update,
  }) {
    return [
      for (final value in values)
        if (test(value)) update(value) else value,
    ];
  }

  List<String> replaceTag(
    List<String> tags,
    String target,
    String replacement,
  ) {
    final updated = [
      for (final tag in tags)
        if (tag == target) replacement else tag,
    ];

    return updated.contains(replacement) ? updated : [...updated, replacement];
  }

  T? firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
    for (final value in values) {
      if (test(value)) return value;
    }
    return null;
  }
}
