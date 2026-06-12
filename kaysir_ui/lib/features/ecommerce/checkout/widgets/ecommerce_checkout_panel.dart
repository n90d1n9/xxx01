import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../point_of_sales/cashier/experiences/pos_commerce_channel.dart';
import '../../../point_of_sales/cashier/widgets/pos_ui.dart';
import '../../channel/models/sales_channel.dart';
import '../../channel/widgets/sales_channel_selector.dart';
import '../models/checkout_session.dart';
import '../models/fulfillment.dart';
import '../models/fulfillment_requirement.dart';
import '../states/checkout_provider.dart';
import 'checkout_field.dart';
import 'checkout_readiness_banner.dart';
import 'fulfillment_mode_selector.dart';

class CheckoutPanel extends ConsumerWidget {
  final bool compact;

  const CheckoutPanel({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(ecommerceActiveCheckoutSessionProvider);
    final salesChannel = session.salesChannel;
    final fulfillment = session.fulfillment;
    final fulfillmentRequirement = FulfillmentRequirement.resolve(
      fulfillment: fulfillment,
      salesChannel: salesChannel,
    );
    final notifier = ref.read(ecommerceCheckoutSessionProvider.notifier);
    final theme = Theme.of(context);
    final readyForPayment = session.canSelectPayment;

    return POSSurface(
      padding: EdgeInsets.all(compact ? 12 : 16),
      color: theme.colorScheme.surface,
      border: Border.all(color: theme.dividerColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CheckoutHeader(
            salesChannel: salesChannel,
            fulfillment: fulfillment,
            readyForPayment: readyForPayment,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          SalesChannelSelector(
            selectedChannel: salesChannel,
            channels: SalesChannels.all,
            compact: compact,
            onChannelSelected: notifier.selectSalesChannel,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          FulfillmentModeSelector(
            selectedMode: fulfillment.mode,
            options: SalesChannels.fulfillmentOptionsFor(salesChannel),
            onModeSelected: notifier.selectFulfillmentMode,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          _FulfillmentFields(
            fulfillment: fulfillment,
            requirement: fulfillmentRequirement,
            compact: compact,
            onChanged: notifier.updateFulfillmentDetails,
          ),
          const SizedBox(height: POSUiTokens.gapLarge),
          CheckoutReadinessBanner(
            ready: readyForPayment,
            title:
                readyForPayment
                    ? 'Ready for payment'
                    : 'Needs checkout details',
            message: _readinessMessage(session),
          ),
        ],
      ),
    );
  }

  String _readinessMessage(CheckoutSession session) {
    final blockingIssues = session.paymentBlockingIssues;
    if (blockingIssues.isNotEmpty) return blockingIssues.first.message;
    return session.fulfillment.summaryLabel;
  }
}

class _CheckoutHeader extends StatelessWidget {
  final POSCommerceChannel salesChannel;
  final FulfillmentSelection fulfillment;
  final bool readyForPayment;

  const _CheckoutHeader({
    required this.salesChannel,
    required this.fulfillment,
    required this.readyForPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        POSIconBadge(
          icon: _fulfillmentIcon(fulfillment.mode),
          backgroundColor:
              readyForPayment
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.64)
                  : theme.colorScheme.errorContainer.withValues(alpha: 0.52),
          foregroundColor:
              readyForPayment
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onErrorContainer,
        ),
        const SizedBox(width: POSUiTokens.gapLarge),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${salesChannel.label} fulfillment',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fulfillment.summaryLabel,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _fulfillmentIcon(POSFulfillmentMode mode) {
    return switch (mode) {
      POSFulfillmentMode.pickup => Icons.storefront_outlined,
      POSFulfillmentMode.delivery => Icons.delivery_dining_outlined,
      POSFulfillmentMode.shipment => Icons.local_shipping_outlined,
      POSFulfillmentMode.preorder => Icons.event_available_outlined,
      POSFulfillmentMode.tableService => Icons.table_restaurant_outlined,
      POSFulfillmentMode.fieldDelivery => Icons.route_outlined,
      POSFulfillmentMode.immediateHandoff => Icons.shopping_bag_outlined,
    };
  }
}

class _FulfillmentFields extends StatelessWidget {
  final FulfillmentSelection fulfillment;
  final FulfillmentRequirement requirement;
  final bool compact;
  final void Function({
    String? contactName,
    String? destination,
    String? scheduleLabel,
    String? note,
  })
  onChanged;

  const _FulfillmentFields({
    required this.fulfillment,
    required this.requirement,
    required this.compact,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveFieldGrid(children: _fieldWidgets());
  }

  List<Widget> _fieldWidgets() {
    final widgets = <Widget>[
      CheckoutField(
        fieldKey: 'checkout_contact',
        label: _contactLabel,
        hint: 'Customer or recipient name',
        initialValue: fulfillment.contactName,
        icon: Icons.person_outline,
        onChanged: (value) => onChanged(contactName: value),
      ),
    ];

    if (requirement.showsDestinationField) {
      widgets.add(
        CheckoutField(
          fieldKey: 'checkout_destination',
          label: requirement.destinationLabel,
          hint: requirement.destinationHint,
          initialValue: fulfillment.destination,
          icon: Icons.place_outlined,
          onChanged: (value) => onChanged(destination: value),
        ),
      );
    }

    widgets.add(
      CheckoutField(
        fieldKey: 'checkout_schedule',
        label: 'Schedule',
        hint: 'Today, tomorrow, or a time window',
        initialValue: fulfillment.scheduleLabel,
        icon: Icons.event_outlined,
        onChanged: (value) => onChanged(scheduleLabel: value),
      ),
    );

    if (!compact) {
      widgets.add(
        CheckoutField(
          fieldKey: 'checkout_note',
          label: 'Order note',
          hint: 'Packing, courier, or customer note',
          initialValue: fulfillment.note,
          icon: Icons.sticky_note_2_outlined,
          maxLines: 2,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.multiline,
          onChanged: (value) => onChanged(note: value),
        ),
      );
    }

    return widgets;
  }

  String get _contactLabel {
    return switch (fulfillment.mode) {
      POSFulfillmentMode.pickup => 'Pickup contact',
      POSFulfillmentMode.delivery => 'Delivery contact',
      POSFulfillmentMode.shipment => 'Shipping contact',
      _ => 'Contact',
    };
  }
}

class _ResponsiveFieldGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFieldGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumns = constraints.maxWidth >= 520;
        if (!useColumns) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: POSUiTokens.gap),
                children[index],
              ],
            ],
          );
        }

        return Wrap(
          spacing: POSUiTokens.gap,
          runSpacing: POSUiTokens.gap,
          children:
              children.map((child) {
                return SizedBox(
                  width: (constraints.maxWidth - POSUiTokens.gap) / 2,
                  child: child,
                );
              }).toList(),
        );
      },
    );
  }
}
