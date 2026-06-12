import 'package:flutter/material.dart' hide Action;

import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../models/action.dart';
import 'action_button.dart';
import 'panel_header.dart';
import 'panel_surface.dart';
import 'tone.dart';

class QuickActions extends StatelessWidget {
  final List<Action> actions;
  final ValueChanged<String> onActionSelected;
  final ValueChanged<Action>? onActionInvoked;

  const QuickActions({
    super.key,
    required this.actions,
    required this.onActionSelected,
    this.onActionInvoked,
  });

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeader(
            icon: Icons.bolt_outlined,
            title: 'Priority actions',
            subtitle: _actionHint,
            tone: VisualTone.primary,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          ..._actionButtons,
        ],
      ),
    );
  }

  List<Widget> get _actionButtons {
    if (actions.isEmpty) {
      return const [SizedBox.shrink()];
    }

    final buttons = <Widget>[];
    for (var index = 0; index < actions.length; index += 1) {
      final action = actions[index];
      if (index > 0) {
        buttons.add(const SizedBox(height: POSUiTokens.gap));
      }
      buttons.add(
        _WorkspaceActionButton(
          action: action,
          prominent: index == 0,
          onPressed: () {
            final actionHandler = onActionInvoked;
            if (actionHandler != null) {
              actionHandler(action);
              return;
            }
            onActionSelected(action.routePath);
          },
        ),
      );
    }
    return buttons;
  }

  String get _actionHint {
    if (actions.isEmpty) return 'No priority action is queued.';
    return actions.first.description;
  }
}

class _WorkspaceActionButton extends StatelessWidget {
  final Action action;
  final bool prominent;
  final VoidCallback onPressed;

  const _WorkspaceActionButton({
    required this.action,
    required this.prominent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: action.icon,
      label: action.actionLabel,
      onPressed: onPressed,
      variant: _variant,
      tooltip: action.title,
    );
  }

  ActionButtonVariant get _variant {
    if (prominent) return ActionButtonVariant.primary;
    return switch (action.tone) {
      ActionTone.primary || ActionTone.secondary => ActionButtonVariant.tonal,
      ActionTone.warning || ActionTone.danger => ActionButtonVariant.outlined,
    };
  }
}
