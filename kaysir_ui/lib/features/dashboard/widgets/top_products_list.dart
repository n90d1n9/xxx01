import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ky_admin/widgets/admin_data_list_section.dart';
import 'package:ky_admin/widgets/admin_data_list_tile.dart';

import '../../../widgets/ui/app_empty_state.dart';
import '../models/dashboard_data.dart';

class TopProductsList extends StatelessWidget {
  const TopProductsList({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return AdminDataListSection(
      title: 'Top products',
      subtitle: 'Best-selling items by revenue and unit movement.',
      leadingIcon: Icons.sell_outlined,
      emptyState: const AppEmptyState(
        title: 'No top products yet',
        message: 'Top sellers will appear once sales activity is available.',
        icon: Icons.sell_outlined,
      ),
      children: [
        for (final product in products)
          AdminDataListTile(
            leadingIcon: Icons.sell_outlined,
            title: product.name,
            subtitle: product.code,
            primaryValue: currency.format(product.price),
            secondaryValue: '${product.quantity} sold',
          ),
      ],
    );
  }
}
