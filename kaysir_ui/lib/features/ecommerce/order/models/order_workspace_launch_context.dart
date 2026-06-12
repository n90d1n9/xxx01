enum OrderWorkspaceLaunchReason { commerceWorkspace, profileDetails }

extension OrderWorkspaceLaunchReasonCopy on OrderWorkspaceLaunchReason {
  String get code {
    return switch (this) {
      OrderWorkspaceLaunchReason.commerceWorkspace => 'commerce_workspace',
      OrderWorkspaceLaunchReason.profileDetails => 'profile_details',
    };
  }

  String get label {
    return switch (this) {
      OrderWorkspaceLaunchReason.commerceWorkspace => 'Commerce workspace',
      OrderWorkspaceLaunchReason.profileDetails => 'Profile details',
    };
  }
}

class OrderWorkspaceLaunchContext {
  static const sourceProfileIdQueryKey = 'source_profile_id';
  static const sourceProfileLabelQueryKey = 'source_profile_label';
  static const orderWorkspaceProfileIdQueryKey = 'order_workspace_profile_id';
  static const workspaceViewIdQueryKey = 'workspace_view_id';
  static const workspaceViewLabelQueryKey = 'workspace_view_label';
  static const reasonQueryKey = 'launch_reason';

  final String sourceProfileId;
  final String sourceProfileLabel;
  final String orderWorkspaceProfileId;
  final String workspaceViewId;
  final String workspaceViewLabel;
  final OrderWorkspaceLaunchReason reason;

  const OrderWorkspaceLaunchContext({
    required this.sourceProfileId,
    required this.sourceProfileLabel,
    required this.orderWorkspaceProfileId,
    this.workspaceViewId = '',
    this.workspaceViewLabel = '',
    required this.reason,
  });

  bool get hasSourceProfile {
    return sourceProfileId.trim().isNotEmpty ||
        sourceProfileLabel.trim().isNotEmpty;
  }

  String get sourceProfileDisplayLabel {
    final label = sourceProfileLabel.trim();
    if (label.isNotEmpty) return label;

    final id = sourceProfileId.trim();
    if (id.isNotEmpty) return id;

    return 'Commerce profile';
  }

  String get orderProfileDisplayLabel {
    final id = orderWorkspaceProfileId.trim();
    if (id.isNotEmpty) return id;

    return 'default';
  }

  bool get hasWorkspaceView {
    return workspaceViewId.trim().isNotEmpty ||
        workspaceViewLabel.trim().isNotEmpty;
  }

  String get workspaceViewDisplayLabel {
    final label = workspaceViewLabel.trim();
    if (label.isNotEmpty) return label;

    final id = workspaceViewId.trim();
    if (id.isNotEmpty) return id;

    return 'Default view';
  }

  Map<String, String> toQueryParameters() {
    return {
      if (sourceProfileId.trim().isNotEmpty)
        sourceProfileIdQueryKey: sourceProfileId.trim(),
      if (sourceProfileLabel.trim().isNotEmpty)
        sourceProfileLabelQueryKey: sourceProfileLabel.trim(),
      if (orderWorkspaceProfileId.trim().isNotEmpty)
        orderWorkspaceProfileIdQueryKey: orderWorkspaceProfileId.trim(),
      if (workspaceViewId.trim().isNotEmpty)
        workspaceViewIdQueryKey: workspaceViewId.trim(),
      if (workspaceViewLabel.trim().isNotEmpty)
        workspaceViewLabelQueryKey: workspaceViewLabel.trim(),
      reasonQueryKey: reason.code,
    };
  }

  String locationForPath(String path) {
    return Uri(
      path: path.trim(),
      queryParameters: toQueryParameters(),
    ).toString();
  }

  static OrderWorkspaceLaunchContext? fromQueryParameters(
    Map<String, String> queryParameters,
  ) {
    final sourceProfileId =
        queryParameters[sourceProfileIdQueryKey]?.trim() ?? '';
    final sourceProfileLabel =
        queryParameters[sourceProfileLabelQueryKey]?.trim() ?? '';
    final orderWorkspaceProfileId =
        queryParameters[orderWorkspaceProfileIdQueryKey]?.trim() ?? '';
    final workspaceViewId =
        queryParameters[workspaceViewIdQueryKey]?.trim() ?? '';
    final workspaceViewLabel =
        queryParameters[workspaceViewLabelQueryKey]?.trim() ?? '';
    final reasonCode = queryParameters[reasonQueryKey]?.trim() ?? '';

    if (sourceProfileId.isEmpty &&
        sourceProfileLabel.isEmpty &&
        orderWorkspaceProfileId.isEmpty &&
        workspaceViewId.isEmpty &&
        workspaceViewLabel.isEmpty &&
        reasonCode.isEmpty) {
      return null;
    }

    return OrderWorkspaceLaunchContext(
      sourceProfileId: sourceProfileId,
      sourceProfileLabel: sourceProfileLabel,
      orderWorkspaceProfileId: orderWorkspaceProfileId,
      workspaceViewId: workspaceViewId,
      workspaceViewLabel: workspaceViewLabel,
      reason: ecommerceOrderWorkspaceLaunchReasonFromCode(reasonCode),
    );
  }
}

OrderWorkspaceLaunchReason ecommerceOrderWorkspaceLaunchReasonFromCode(
  String code,
) {
  final normalizedCode = code.trim();
  for (final reason in OrderWorkspaceLaunchReason.values) {
    if (reason.code == normalizedCode) return reason;
  }

  return OrderWorkspaceLaunchReason.commerceWorkspace;
}
