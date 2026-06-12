import 'order_workspace_launch_context.dart';
import 'order_workspace_profile.dart';
import 'order_workspace_view.dart';

enum OrderWorkspaceLaunchResolutionStatus {
  requestedViewApplied,
  profileDefaultApplied,
  requestedViewUnavailable,
}

extension OrderWorkspaceLaunchResolutionStatusCopy
    on OrderWorkspaceLaunchResolutionStatus {
  String get label {
    return switch (this) {
      OrderWorkspaceLaunchResolutionStatus.requestedViewApplied =>
        'Requested view applied',
      OrderWorkspaceLaunchResolutionStatus.profileDefaultApplied =>
        'Profile default applied',
      OrderWorkspaceLaunchResolutionStatus.requestedViewUnavailable =>
        'Requested view unavailable',
    };
  }
}

class OrderWorkspaceLaunchResolution {
  final OrderWorkspaceLaunchContext launchContext;
  final String appliedOrderProfileId;
  final String appliedOrderProfileLabel;
  final OrderWorkspaceView appliedWorkspaceView;
  final OrderWorkspaceLaunchResolutionStatus status;

  const OrderWorkspaceLaunchResolution({
    required this.launchContext,
    required this.appliedOrderProfileId,
    required this.appliedOrderProfileLabel,
    required this.appliedWorkspaceView,
    required this.status,
  });

  bool get usedFallback {
    return usedProfileFallback || usedWorkspaceViewFallback;
  }

  bool get usedProfileFallback {
    final requestedProfileId = launchContext.orderWorkspaceProfileId.trim();
    return requestedProfileId.isNotEmpty &&
        requestedProfileId != appliedOrderProfileId.trim();
  }

  bool get usedWorkspaceViewFallback {
    return status ==
        OrderWorkspaceLaunchResolutionStatus.requestedViewUnavailable;
  }

  String get orderProfileDisplayLabel {
    final id = appliedOrderProfileId.trim();
    if (id.isNotEmpty) return id;

    return launchContext.orderProfileDisplayLabel;
  }

  String get orderProfileTitleLabel {
    final label = appliedOrderProfileLabel.trim();
    if (label.isNotEmpty) return label;

    return orderProfileDisplayLabel;
  }

  String get workspaceViewDisplayLabel => appliedWorkspaceView.label;

  String get detailLabel {
    return [
      launchContext.reason.label,
      orderProfileDisplayLabel,
      workspaceViewDisplayLabel,
    ].join(' - ');
  }

  String get fallbackMessage {
    final messages = [
      if (usedProfileFallback)
        'Requested order profile ${launchContext.orderProfileDisplayLabel} is unavailable here. Opened $orderProfileTitleLabel.',
      if (usedWorkspaceViewFallback)
        'Requested ${launchContext.workspaceViewDisplayLabel} is unavailable. Opened $workspaceViewDisplayLabel.',
    ];

    return messages.join(' ');
  }
}

OrderWorkspaceLaunchResolution? ecommerceOrderWorkspaceLaunchResolutionFor({
  required OrderWorkspaceProfile profile,
  required OrderWorkspaceLaunchContext launchContext,
}) {
  final requestedView = ecommerceOrderWorkspaceViewById(
    views: profile.workspaceViews,
    viewId: launchContext.workspaceViewId,
  );
  if (requestedView != null) {
    return OrderWorkspaceLaunchResolution(
      launchContext: launchContext,
      appliedOrderProfileId: profile.id,
      appliedOrderProfileLabel: profile.title,
      appliedWorkspaceView: requestedView,
      status: OrderWorkspaceLaunchResolutionStatus.requestedViewApplied,
    );
  }

  final defaultView = ecommerceInitialOrderWorkspaceViewForProfile(profile);
  if (defaultView == null) return null;

  return OrderWorkspaceLaunchResolution(
    launchContext: launchContext,
    appliedOrderProfileId: profile.id,
    appliedOrderProfileLabel: profile.title,
    appliedWorkspaceView: defaultView,
    status:
        launchContext.hasWorkspaceView
            ? OrderWorkspaceLaunchResolutionStatus.requestedViewUnavailable
            : OrderWorkspaceLaunchResolutionStatus.profileDefaultApplied,
  );
}
