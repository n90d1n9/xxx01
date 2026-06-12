import 'order_filter.dart';
import 'order_saved_workspace_codec.dart';
import 'order_saved_workspace_identity.dart';
import 'order_sort.dart';
import 'order_workspace_view.dart';

class OrderSavedWorkspace {
  final String id;
  final String label;
  final String description;
  final bool isDescriptionCustom;
  final OrderFilter filter;
  final OrderSortMode sortMode;
  final bool isPinned;

  const OrderSavedWorkspace({
    required this.id,
    required this.label,
    required this.description,
    this.isDescriptionCustom = false,
    required this.filter,
    required this.sortMode,
    this.isPinned = false,
  });

  factory OrderSavedWorkspace.fromJson(Map<String, Object?> json) {
    final filter = orderSavedWorkspaceFilterFromJson(
      orderSavedWorkspaceJsonMap(json['filter']),
    );
    final sortMode =
        orderSavedWorkspaceEnumByName(OrderSortMode.values, json['sortMode']) ??
        OrderSortMode.newest;

    return OrderSavedWorkspace(
      id:
          orderSavedWorkspaceStringOrNull(json['id']) ??
          orderSavedWorkspaceIdForState(filter: filter, sortMode: sortMode),
      label:
          orderSavedWorkspaceStringOrNull(json['label']) ??
          orderSavedWorkspaceLabelFromSummary(summaryItems: const []),
      description:
          orderSavedWorkspaceStringOrNull(json['description']) ??
          ecommerceOrderSavedWorkspaceDescriptionFromSummary(const []),
      isDescriptionCustom: json['isDescriptionCustom'] == true,
      filter: filter,
      sortMode: sortMode,
      isPinned: json['isPinned'] == true,
    );
  }

  bool matches(OrderFilter activeFilter, OrderSortMode sort) {
    return sortMode == sort && ecommerceOrderFiltersEqual(filter, activeFilter);
  }

  OrderSavedWorkspace copyWith({
    String? id,
    String? label,
    String? description,
    bool? isDescriptionCustom,
    OrderFilter? filter,
    OrderSortMode? sortMode,
    bool? isPinned,
  }) {
    return OrderSavedWorkspace(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      isDescriptionCustom: isDescriptionCustom ?? this.isDescriptionCustom,
      filter: filter ?? this.filter,
      sortMode: sortMode ?? this.sortMode,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'isDescriptionCustom': isDescriptionCustom,
      'filter': orderSavedWorkspaceFilterToJson(filter),
      'sortMode': sortMode.name,
      'isPinned': isPinned,
    };
  }

  OrderWorkspaceContext toWorkspaceContext() {
    return OrderWorkspaceContext(
      id: id,
      label: label,
      description: description,
      isPreset: false,
      filter: filter,
      sortMode: sortMode,
    );
  }
}

enum OrderSavedWorkspaceMoveDirection { earlier, later }
