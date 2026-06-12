import 'package:flutter/material.dart';

import '../../cashier/experiences/pos_commerce_channel.dart';
import '../../cashier/experiences/pos_order_fulfillment.dart';
import '../../cashier/experiences/pos_order_fulfillment_behavior_policy.dart';
import '../../cashier/widgets/pos_switch_preview_pill.dart';
import '../../cashier/widgets/pos_ui.dart';

class OrderFulfillmentPanel extends StatelessWidget {
  final POSCommerceChannel channel;
  final POSOrderFulfillmentContext context;
  final POSOrderFulfillmentReadiness readiness;
  final ValueChanged<POSFulfillmentMode> onModeChanged;
  final ValueChanged<String> onContactChanged;
  final ValueChanged<String> onDestinationChanged;
  final ValueChanged<String> onTableChanged;
  final ValueChanged<String> onScheduleChanged;
  final List<POSOrderFulfillmentBehaviorHint> behaviorHints;
  final bool compact;

  const OrderFulfillmentPanel({
    super.key,
    required this.channel,
    required this.context,
    required this.readiness,
    required this.onModeChanged,
    required this.onContactChanged,
    required this.onDestinationChanged,
    required this.onTableChanged,
    required this.onScheduleChanged,
    this.behaviorHints = const [],
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        readiness.canComplete
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onErrorContainer;
    final background =
        readiness.canComplete
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.44)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.44);

    return POSSurface(
      color: theme.colorScheme.surface,
      border: Border(bottom: BorderSide(color: theme.dividerColor)),
      borderRadius: BorderRadius.zero,
      padding: EdgeInsets.fromLTRB(
        16,
        compact ? 10 : 12,
        16,
        compact ? 10 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              POSIconBadge(
                icon:
                    readiness.canComplete
                        ? Icons.local_shipping_outlined
                        : Icons.rule_outlined,
                backgroundColor: background,
                foregroundColor: foreground,
              ),
              const SizedBox(width: POSUiTokens.gapLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${channel.label} fulfillment',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      readiness.statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            readiness.canComplete
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.error,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: POSUiTokens.gap),
          if (channel.fulfillmentModes.length > 1)
            Wrap(
              spacing: POSUiTokens.gap,
              runSpacing: POSUiTokens.gap,
              children:
                  channel.fulfillmentModes.map((mode) {
                    return POSChoicePill(
                      label: mode.label,
                      selected: mode == this.context.mode,
                      onSelected: (_) => onModeChanged(mode),
                    );
                  }).toList(),
            )
          else
            Text(
              readiness.summaryLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (behaviorHints.isNotEmpty) ...[
            const SizedBox(height: POSUiTokens.gap),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final hint in behaviorHints.take(3))
                  Tooltip(
                    message: hint.message,
                    child: POSSwitchPreviewPill(
                      icon: _hintIcon(hint),
                      label: hint.label,
                      tone: _hintTone(hint.tone),
                    ),
                  ),
                if (behaviorHints.length > 3)
                  POSSwitchPreviewPill(
                    icon: Icons.more_horiz,
                    label: '+${behaviorHints.length - 3} more',
                  ),
              ],
            ),
          ],
          ..._fields(theme),
        ],
      ),
    );
  }

  IconData _hintIcon(POSOrderFulfillmentBehaviorHint hint) {
    switch (hint.id) {
      case 'schedule_required':
        return Icons.event_outlined;
      case 'courier_handoff':
        return Icons.delivery_dining_outlined;
      case 'platform_policy':
        return Icons.policy_outlined;
      case 'stock_reserved':
        return Icons.inventory_2_outlined;
      case 'offline_ready':
        return Icons.sync_outlined;
      case 'account_terms':
        return Icons.sell_outlined;
      case 'table_lifecycle':
        return Icons.table_restaurant_outlined;
      default:
        return Icons.info_outline;
    }
  }

  POSSwitchPreviewTone _hintTone(POSOrderFulfillmentBehaviorHintTone tone) {
    switch (tone) {
      case POSOrderFulfillmentBehaviorHintTone.neutral:
        return POSSwitchPreviewTone.neutral;
      case POSOrderFulfillmentBehaviorHintTone.positive:
        return POSSwitchPreviewTone.positive;
      case POSOrderFulfillmentBehaviorHintTone.warning:
        return POSSwitchPreviewTone.warning;
    }
  }

  List<Widget> _fields(ThemeData theme) {
    final fields = <Widget>[];
    final needsScheduleField = _needsScheduleField;

    switch (context.mode) {
      case POSFulfillmentMode.immediateHandoff:
        break;
      case POSFulfillmentMode.pickup:
        fields.add(
          _FulfillmentTextField(
            label: 'Pickup name',
            hint: 'Customer or pickup contact',
            initialValue: context.contactName,
            icon: Icons.person_outline,
            onChanged: onContactChanged,
          ),
        );
        if (needsScheduleField) {
          fields.add(_scheduleField);
        }
        break;
      case POSFulfillmentMode.delivery:
      case POSFulfillmentMode.shipment:
      case POSFulfillmentMode.fieldDelivery:
        fields.add(
          _FulfillmentTextField(
            label:
                context.mode == POSFulfillmentMode.shipment
                    ? 'Shipping destination'
                    : 'Delivery destination',
            hint: 'Address, route stop, or delivery note',
            initialValue: context.destination,
            icon: Icons.place_outlined,
            onChanged: onDestinationChanged,
          ),
        );
        if (needsScheduleField) {
          fields.add(_scheduleField);
        }
        break;
      case POSFulfillmentMode.tableService:
        fields.add(
          _FulfillmentTextField(
            label: 'Table',
            hint: 'Table, room, or seat',
            initialValue: context.tableName,
            icon: Icons.table_restaurant_outlined,
            onChanged: onTableChanged,
          ),
        );
        break;
      case POSFulfillmentMode.preorder:
        fields
          ..add(
            _FulfillmentTextField(
              label: 'Contact',
              hint: 'Customer or order contact',
              initialValue: context.contactName,
              icon: Icons.person_outline,
              onChanged: onContactChanged,
            ),
          )
          ..add(_scheduleField);
        break;
    }

    return [
      for (final field in fields) ...[
        const SizedBox(height: POSUiTokens.gap),
        field,
      ],
    ];
  }

  bool get _needsScheduleField {
    if (context.mode == POSFulfillmentMode.preorder) return false;

    return readiness.issues.any(
          (issue) => issue.type == POSOrderFulfillmentIssueType.missingSchedule,
        ) ||
        behaviorHints.any((hint) => hint.id == 'schedule_required');
  }

  _FulfillmentTextField get _scheduleField {
    return _FulfillmentTextField(
      label: 'Schedule',
      hint: 'Pickup, delivery, or service time',
      initialValue: context.scheduleLabel,
      icon: Icons.event_outlined,
      onChanged: onScheduleChanged,
    );
  }
}

class _FulfillmentTextField extends StatelessWidget {
  final String label;
  final String hint;
  final String initialValue;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const _FulfillmentTextField({
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
