import 'package:flutter/material.dart';

import '../models/restaurant_models.dart';
import 'restaurant_card_controls.dart';
import 'restaurant_card_header.dart';
import 'restaurant_mini_stat.dart';
import 'restaurant_signal_chip.dart';
import 'restaurant_status_card_surface.dart';
import 'restaurant_status_styles.dart';

/// Displays one menu signal with demand, margin, prep, and risk actions.
class RestaurantMenuSignalCard extends StatelessWidget {
  const RestaurantMenuSignalCard({
    super.key,
    required this.signal,
    required this.onResolveMenuRisk,
    this.focused = false,
  });

  final RestaurantMenuSignal signal;
  final ValueChanged<String>? onResolveMenuRisk;
  final bool focused;

  bool get _isHighRisk => signal.soldOutRiskPercent >= 50;

  RestaurantServiceStatus get _riskStatus {
    if (signal.soldOutRiskPercent >= 65) return RestaurantServiceStatus.busy;
    if (signal.soldOutRiskPercent >= 50) return RestaurantServiceStatus.busy;
    return RestaurantServiceStatus.calm;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusStyle = restaurantStatusStyle(colors, _riskStatus);

    return Semantics(
      container: true,
      selected: focused,
      label:
          '${signal.name}, ${signal.category}, ${signal.orders} orders, '
          '${signal.soldOutRiskPercent}% sell-out risk',
      child: RestaurantStatusCardSurface(
        statusStyle: statusStyle,
        isFocused: focused,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RestaurantCardHeader(
              icon: statusStyle.icon,
              foregroundColor: statusStyle.foreground,
              backgroundColor: statusStyle.background,
              title: signal.name,
              subtitle: signal.category,
              trailing: RestaurantStatusPill(
                status: _riskStatus,
                label: '${signal.soldOutRiskPercent}% risk',
                compact: true,
              ),
            ),
            const SizedBox(height: 12),
            RestaurantCardMetricRow(
              children: [
                RestaurantMiniStat(
                  icon: Icons.receipt_long_outlined,
                  label: 'Orders',
                  value: signal.orders.toString(),
                  semanticLabel: '${signal.name} orders, ${signal.orders}',
                ),
                RestaurantMiniStat(
                  icon: Icons.trending_up_outlined,
                  label: 'Margin',
                  value: '${signal.grossMarginPercent}%',
                  semanticLabel:
                      '${signal.name} margin, ${signal.grossMarginPercent} percent',
                ),
                RestaurantMiniStat(
                  icon: Icons.timer_outlined,
                  label: 'Prep',
                  value: '${signal.prepMinutes}m',
                  semanticLabel:
                      '${signal.name} prep time, ${signal.prepMinutes} minutes',
                ),
              ],
            ),
            if (signal.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              RestaurantCardChipRow(
                children: [
                  for (final tag in signal.tags)
                    RestaurantSignalChip(
                      label: tag,
                      foregroundColor: colors.onSecondaryContainer,
                      backgroundColor: colors.secondaryContainer.withValues(
                        alpha: .42,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      fontWeight: FontWeight.w700,
                    ),
                ],
              ),
            ],
            if (onResolveMenuRisk != null && _isHighRisk) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: RestaurantCardActionButton(
                  icon: Icons.inventory_2_outlined,
                  label: 'Restocked',
                  foregroundColor: statusStyle.foreground,
                  backgroundColor: statusStyle.background,
                  onPressed: () => onResolveMenuRisk!(signal.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
