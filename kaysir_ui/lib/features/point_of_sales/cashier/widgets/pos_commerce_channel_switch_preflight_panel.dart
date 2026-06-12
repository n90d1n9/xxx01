import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../experiences/pos_commerce_channel_switch_plan.dart';
import '../experiences/pos_commerce_channel_switch_preflight.dart';
import '../experiences/pos_order_fulfillment.dart';
import '../experiences/pos_order_fulfillment_provider.dart';
import 'pos_ui.dart';

class POSCommerceChannelSwitchPreflightPanel extends ConsumerStatefulWidget {
  final POSCommerceChannelSwitchPlan plan;
  final ValueNotifier<bool>? canConfirmNotifier;

  const POSCommerceChannelSwitchPreflightPanel({
    super.key,
    required this.plan,
    this.canConfirmNotifier,
  });

  @override
  ConsumerState<POSCommerceChannelSwitchPreflightPanel> createState() {
    return _POSCommerceChannelSwitchPreflightPanelState();
  }
}

class _POSCommerceChannelSwitchPreflightPanelState
    extends ConsumerState<POSCommerceChannelSwitchPreflightPanel> {
  late final POSCommerceChannelSwitchPreflight _preflight;
  late POSOrderFulfillmentContext _context;
  late final Map<POSCommerceChannelSwitchPreflightField, TextEditingController>
  _controllers;

  @override
  void initState() {
    super.initState();
    _preflight = POSCommerceChannelSwitchPreflight.fromPlan(widget.plan);
    _context = _preflight.context;
    _controllers = {
      for (final requirement in _preflight.requirements)
        requirement.field: TextEditingController(
          text: requirement.initialValue,
        ),
    };
    _publishCanConfirm();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = _preflight.order;
    if (order == null || !_preflight.hasRequirements) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return POSSurface(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.12),
      border: Border.all(
        color: theme.colorScheme.primary.withValues(alpha: 0.16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: POSUiTokens.gap),
              Expanded(
                child: Text(
                  '${_preflight.targetChannel.label} fulfillment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gap),
          for (final requirement in _preflight.requirements) ...[
            _PreflightField(
              requirement: requirement,
              controller: _controllers[requirement.field]!,
              onChanged: (value) {
                _updateRequirement(requirement: requirement, value: value);
              },
            ),
            if (requirement != _preflight.requirements.last)
              const SizedBox(height: POSUiTokens.gap),
          ],
        ],
      ),
    );
  }

  void _updateRequirement({
    required POSCommerceChannelSwitchPreflightRequirement requirement,
    required String value,
  }) {
    final nextContext = requirement.applyTo(_context, value);
    setState(() => _context = nextContext);
    _publishCanConfirm();

    ref
        .read(posOrderFulfillmentControllerProvider)
        .saveDraftFor(
          order: _preflight.order!,
          channel: _preflight.targetChannel,
          context: nextContext,
        );
  }

  void _publishCanConfirm() {
    widget.canConfirmNotifier?.value = _preflight.isSatisfiedBy(_context);
  }
}

class _PreflightField extends StatelessWidget {
  final POSCommerceChannelSwitchPreflightRequirement requirement;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PreflightField({
    required this.requirement,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: ValueKey('pos_channel_preflight_${requirement.field.name}'),
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        labelText: requirement.label,
        hintText: requirement.hintText,
        prefixIcon: Icon(_icon(requirement.field)),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  IconData _icon(POSCommerceChannelSwitchPreflightField field) {
    switch (field) {
      case POSCommerceChannelSwitchPreflightField.contact:
        return Icons.person_outline;
      case POSCommerceChannelSwitchPreflightField.destination:
        return Icons.place_outlined;
      case POSCommerceChannelSwitchPreflightField.table:
        return Icons.table_restaurant_outlined;
      case POSCommerceChannelSwitchPreflightField.schedule:
        return Icons.event_outlined;
    }
  }
}
