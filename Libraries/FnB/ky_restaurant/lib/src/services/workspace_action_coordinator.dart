import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import '../models/restaurant_operational_briefing.dart';
import '../models/restaurant_reservation.dart';
import 'restaurant_workspace_action_dispatcher.dart';

typedef RestaurantWorkspaceUndoFeedback =
    void Function(String message, VoidCallback onUndo);
typedef RestaurantWorkspaceMessageFeedback = void Function(String message);

/// Coordinates workspace commands with undo and snackbar-style feedback.
class RestaurantWorkspaceActionCoordinator {
  const RestaurantWorkspaceActionCoordinator({
    required this.dispatcher,
    this.showUndoMessage,
    this.showMessage,
  });

  factory RestaurantWorkspaceActionCoordinator.forMessenger({
    required RestaurantWorkspaceActionDispatcher dispatcher,
    required ScaffoldMessengerState? messenger,
  }) {
    return RestaurantWorkspaceActionCoordinator(
      dispatcher: dispatcher,
      showUndoMessage: messenger == null
          ? null
          : (message, onUndo) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(message),
                    action: SnackBarAction(label: 'Undo', onPressed: onUndo),
                  ),
                );
            },
      showMessage: messenger == null
          ? null
          : (message) {
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(message)));
            },
    );
  }

  static const undoConfirmationMessage = 'Action undone';
  static const preferenceResetMessage = 'Workspace controls reset';

  final RestaurantWorkspaceActionDispatcher dispatcher;
  final RestaurantWorkspaceUndoFeedback? showUndoMessage;
  final RestaurantWorkspaceMessageFeedback? showMessage;

  void applyBriefingAction(RestaurantBriefingAction action) {
    _run(() => dispatcher.applyBriefingAction(action));
  }

  void completeTask(String taskId) {
    _run(() => dispatcher.completeTask(taskId));
  }

  void resolveMenuRisk(String menuSignalId) {
    _run(() => dispatcher.resolveMenuRisk(menuSignalId));
  }

  void reviewCatalogItem(String menuItemId) {
    _run(() => dispatcher.reviewCatalogItem(menuItemId));
  }

  void reviewRecipeProduction(String recipeId) {
    _run(() => dispatcher.reviewRecipeProduction(recipeId));
  }

  void updateStationStatus(String stationId, RestaurantServiceStatus status) {
    _run(() => dispatcher.updateStationStatus(stationId, status));
  }

  void updateZoneStatus(String zoneId, RestaurantServiceStatus status) {
    _run(() => dispatcher.updateZoneStatus(zoneId, status));
  }

  void updateReservationStatus(
    String reservationId,
    RestaurantReservationStatus status,
  ) {
    _run(() => dispatcher.updateReservationStatus(reservationId, status));
  }

  void showPreferenceResetConfirmation() {
    showMessage?.call(preferenceResetMessage);
  }

  void _run(RestaurantWorkspaceActionResult Function() command) {
    final result = command();
    if (!result.changed) return;
    showUndoMessage?.call(result.message, _undoLastAction);
  }

  void _undoLastAction() {
    if (!dispatcher.undoLastAction()) return;
    showMessage?.call(undoConfirmationMessage);
  }
}
