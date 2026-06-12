import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/reservation_qr_session_controller.dart';
import '../models/reservation_intake_action.dart';
import '../models/reservation_qr_link.dart';
import '../models/reservation_qr_scan_action_plan.dart';
import '../models/reservation_qr_scan_workflow.dart';
import '../services/reservation_qr_action_handler.dart';
import 'reservation_intake_options.dart';
import 'reservation_qr_action_feedback_notice.dart';
import 'reservation_qr_intake_launcher_options.dart';
import 'reservation_qr_panel_binding.dart';
import 'reservation_qr_scan_entry.dart';
import 'reservation_qr_session_controller_panel.dart';
import 'reservation_qr_session_callbacks.dart';
import 'reservation_qr_refresh_feedback_notice.dart';

/// Composes reservation intake, QR scan entry, and QR session state together.
class RestaurantReservationQrHandoffSection extends StatefulWidget {
  const RestaurantReservationQrHandoffSection({
    super.key,
    this.onIntakeActionSelected,
    this.binding,
    this.scanEntry,
    this.sessionPanel,
    this.spacing = 14,
  });

  final ValueChanged<RestaurantReservationIntakeAction>? onIntakeActionSelected;
  final RestaurantReservationQrPanelBinding? binding;
  final Widget? scanEntry;
  final Widget? sessionPanel;
  final double spacing;

  @override
  State<RestaurantReservationQrHandoffSection> createState() {
    return _RestaurantReservationQrHandoffSectionState();
  }
}

/// Owns transient action feedback while leaving QR session state external.
class _RestaurantReservationQrHandoffSectionState
    extends State<RestaurantReservationQrHandoffSection> {
  RestaurantReservationQrActionHandlingResult? _lastActionResult;
  RestaurantReservationQrScanWorkflow? _lastActionWorkflow;
  RestaurantReservationQrLink? _lastRefreshedLink;
  RestaurantReservationQrScanAction? _pendingAction;
  RestaurantReservationQrSessionController? _observedController;
  int _actionRunId = 0;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(
    covariant RestaurantReservationQrHandoffSection oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    final previousController = oldWidget.binding?.controller;
    final nextController = widget.binding?.controller;
    if (identical(previousController, nextController)) return;

    _detachController();
    _attachController();
    _clearActionResult();
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveScanEntry = _effectiveScanEntry;
    final effectiveSessionPanel = _effectiveSessionPanel;
    final effectiveRefreshFeedback = _effectiveRefreshFeedback;
    final effectiveActionFeedback = _effectiveActionFeedback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntakeOptions(),
        if (effectiveScanEntry != null) ...[
          SizedBox(height: widget.spacing),
          effectiveScanEntry,
        ],
        if (effectiveSessionPanel != null) ...[
          SizedBox(height: widget.spacing),
          effectiveSessionPanel,
        ],
        if (effectiveRefreshFeedback != null) ...[
          SizedBox(height: widget.spacing),
          effectiveRefreshFeedback,
        ],
        if (effectiveActionFeedback != null) ...[
          SizedBox(height: widget.spacing),
          effectiveActionFeedback,
        ],
      ],
    );
  }

  Widget _buildIntakeOptions() {
    final binding = widget.binding;
    if (binding == null) {
      return RestaurantReservationIntakeOptions(
        onActionSelected: widget.onIntakeActionSelected,
      );
    }

    return RestaurantReservationQrIntakeControllerOptions(
      controller: binding.controller,
      config: binding.launchConfig,
      actions: binding.actions,
      launchConfigForAction: binding.launchConfigForAction,
      onActionSelected: widget.onIntakeActionSelected,
      onLinkLaunched: binding.onLinkLaunched,
      onFallbackActionSelected: binding.onFallbackActionSelected,
    );
  }

  Widget? get _effectiveScanEntry {
    final customEntry = widget.scanEntry;
    if (customEntry != null) return customEntry;

    final binding = widget.binding;
    if (binding == null || !binding.scanEntryBinding.visible) return null;

    final scanEntryBinding = binding.scanEntryBinding;
    return scanEntryBinding.entry ??
        RestaurantReservationQrScanControllerEntry(
          controller: binding.controller,
          includeDismiss: scanEntryBinding.includeDismiss,
          onScanResolved: (workflow) {
            _clearActionResult();
            _clearRefreshFeedback();
            scanEntryBinding.onResolved?.call(workflow);
          },
          onClear: () {
            _clearActionResult();
            _clearRefreshFeedback();
            scanEntryBinding.onCleared?.call();
          },
        );
  }

  Widget? get _effectiveSessionPanel {
    final customPanel = widget.sessionPanel;
    if (customPanel != null) return customPanel;

    final binding = widget.binding;
    if (binding == null) return null;

    return RestaurantReservationQrSessionControllerPanel(
      controller: binding.controller,
      callbacks: _sessionCallbacksFor(binding),
    );
  }

  Widget? get _effectiveActionFeedback {
    final pendingAction = _pendingAction;
    if (pendingAction != null) {
      return RestaurantReservationQrActionFeedbackNotice(
        result: RestaurantReservationQrActionHandlingResult.pending(
          pendingAction,
        ),
      );
    }

    final result = _lastActionResult;
    if (result == null) return null;

    return RestaurantReservationQrActionFeedbackNotice(
      result: result,
      onDismiss: _clearActionResult,
    );
  }

  Widget? get _effectiveRefreshFeedback {
    final link = _lastRefreshedLink;
    if (link == null) return null;

    return RestaurantReservationQrRefreshFeedbackNotice(
      link: link,
      onDismiss: _clearRefreshFeedback,
    );
  }

  RestaurantReservationQrSessionCallbacks _sessionCallbacksFor(
    RestaurantReservationQrPanelBinding binding,
  ) {
    final actionHandler = binding.actionHandler;
    final callbacks = binding.sessionCallbacks.mergeWith(
      onRefreshLink: () {
        _refreshActiveLink(binding);
      },
      onRefreshScan: () => _refreshActiveScanLink(binding),
    );
    if (actionHandler == null) return callbacks;

    return callbacks.mergeWith(
      onScanActionSelected: (action) {
        if (action == RestaurantReservationQrScanAction.refreshLink) {
          binding.sessionCallbacks.onScanActionSelected?.call(action);
          return;
        }

        unawaited(
          _handleScanActionSelection(binding, binding.sessionCallbacks, action),
        );
      },
    );
  }

  bool _refreshActiveLink(RestaurantReservationQrPanelBinding binding) {
    final activeLink = binding.controller.activeLink;
    if (activeLink == null) return false;

    final refreshConfig =
        binding.launchConfigForAction?.call(activeLink.action) ??
        binding.launchConfig;
    final refreshedLink = binding.controller.refreshLink(
      baseUri: refreshConfig.baseUri,
      lifetime: refreshConfig.lifetime,
      queryParameters: refreshConfig.queryParameters,
    );
    if (refreshedLink == null) return false;

    setState(() {
      _lastRefreshedLink = refreshedLink;
    });
    binding.onLinkLaunched?.call(refreshedLink);
    binding.sessionCallbacks.onRefreshLink?.call();
    return true;
  }

  void _refreshActiveScanLink(RestaurantReservationQrPanelBinding binding) {
    if (!_refreshActiveLink(binding)) return;

    binding.sessionCallbacks.onRefreshScan?.call();
  }

  Future<void> _handleScanActionSelection(
    RestaurantReservationQrPanelBinding binding,
    RestaurantReservationQrSessionCallbacks callbacks,
    RestaurantReservationQrScanAction action,
  ) async {
    final workflow = binding.controller.scanWorkflow;
    if (workflow == null) return;

    final actionRunId = ++_actionRunId;
    setState(() {
      _pendingAction = action;
      _lastActionResult = null;
      _lastActionWorkflow = workflow;
      _lastRefreshedLink = null;
    });
    callbacks.onScanActionSelected?.call(action);

    final result = await binding.actionHandler!.handleAsync(
      workflow: workflow,
      action: action,
    );

    if (!mounted || actionRunId != _actionRunId) return;
    if (!identical(binding.controller.scanWorkflow, workflow)) {
      _clearActionResult();
      return;
    }

    setState(() {
      _pendingAction = null;
      _lastActionResult = result;
      _lastActionWorkflow = workflow;
    });
    binding.controller.recordActionHandled(result);
    callbacks.onScanActionHandled?.call(result);
  }

  void _clearActionResult() {
    if (_lastActionResult == null && _pendingAction == null) return;

    _actionRunId++;
    setState(() {
      _pendingAction = null;
      _lastActionResult = null;
      _lastActionWorkflow = null;
    });
  }

  void _clearRefreshFeedback() {
    if (_lastRefreshedLink == null) return;

    setState(() {
      _lastRefreshedLink = null;
    });
  }

  void _attachController() {
    final controller = widget.binding?.controller;
    if (controller == null) return;

    _observedController = controller;
    controller.addListener(_handleControllerChanged);
  }

  void _detachController() {
    final controller = _observedController;
    if (controller == null) return;

    controller.removeListener(_handleControllerChanged);
    _observedController = null;
  }

  void _handleControllerChanged() {
    _handleRefreshFeedbackControllerChange();
    if (_lastActionResult == null && _pendingAction == null) return;

    final workflow = _lastActionWorkflow;
    final currentWorkflow = _observedController?.scanWorkflow;
    if (currentWorkflow == null) {
      _clearActionResult();
      return;
    }

    if (workflow == null || identical(workflow, currentWorkflow)) return;

    _clearActionResult();
  }

  void _handleRefreshFeedbackControllerChange() {
    final refreshedLink = _lastRefreshedLink;
    if (refreshedLink == null) return;

    if (!identical(_observedController?.activeLink, refreshedLink)) {
      _clearRefreshFeedback();
    }
  }
}
