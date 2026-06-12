import 'restaurant_workspace_panel_filters.dart';
import 'restaurant_workspace_panel_focus.dart';
import 'restaurant_workspace_view.dart';

const Object _focusNotProvided = Object();

/// Stores the selected workspace view, panel lenses, and optional target focus.
class RestaurantWorkspacePreferences {
  const RestaurantWorkspacePreferences({
    this.view = RestaurantWorkspaceView.pulse,
    this.filters = const RestaurantWorkspacePanelFilters(),
    this.focus,
  });

  factory RestaurantWorkspacePreferences.fromJson(Map<String, Object?>? json) {
    if (json == null) return const RestaurantWorkspacePreferences();

    return RestaurantWorkspacePreferences(
      view: RestaurantWorkspaceView.fromId(_stringValue(json['view'])),
      filters: RestaurantWorkspacePanelFilters.fromJson(
        _objectMap(json['filters']),
      ),
      focus: RestaurantWorkspacePanelFocus.fromJson(_objectMap(json['focus'])),
    );
  }

  final RestaurantWorkspaceView view;
  final RestaurantWorkspacePanelFilters filters;
  final RestaurantWorkspacePanelFocus? focus;

  bool get hasActiveFilters => filters.hasActivePreferences;

  bool get hasFocus => focus != null;

  Map<String, Object?> toJson() {
    return {
      'view': view.id,
      'filters': filters.toJson(),
      if (focus case final focus?) 'focus': focus.toJson(),
    };
  }

  RestaurantWorkspacePreferences copyWith({
    RestaurantWorkspaceView? view,
    RestaurantWorkspacePanelFilters? filters,
    Object? focus = _focusNotProvided,
  }) {
    return RestaurantWorkspacePreferences(
      view: view ?? this.view,
      filters: filters ?? this.filters,
      focus: identical(focus, _focusNotProvided)
          ? this.focus
          : focus as RestaurantWorkspacePanelFocus?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RestaurantWorkspacePreferences &&
            view == other.view &&
            filters == other.filters &&
            focus == other.focus;
  }

  @override
  int get hashCode => Object.hash(view, filters, focus);
}

Map<String, Object?>? _objectMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is! Map) return null;

  return {
    for (final entry in value.entries)
      if (entry.key is String) entry.key as String: entry.value,
  };
}

String? _stringValue(Object? value) {
  return value is String ? value : null;
}
