import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../order/states/current_order_provider.dart';
import '../models/customer.dart';
import '../states/customer_provider.dart';
import '../utils/pos_error_copy.dart';
import '../utils/customer_lookup.dart';
import 'customer_search_field.dart';
import 'customer_tile.dart';
import 'pos_ui.dart';

class CustomerSelectionDialog extends ConsumerStatefulWidget {
  const CustomerSelectionDialog({super.key});

  @override
  ConsumerState<CustomerSelectionDialog> createState() =>
      _CustomerSelectionDialogState();
}

class _CustomerSelectionDialogState
    extends ConsumerState<CustomerSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final currentOrder = ref.watch(currentOrderProvider);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(POSUiTokens.radius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 640,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const POSIconBadge(icon: Icons.person_search_outlined),
                  const SizedBox(width: POSUiTokens.gapLarge),
                  Expanded(
                    child: Text(
                      'Customer',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (currentOrder?.customer != null)
                    POSActionButton(
                      icon: const Icon(Icons.person_off_outlined),
                      label: 'Walk-in',
                      onPressed: () {
                        ref
                            .read(currentOrderProvider.notifier)
                            .removeCustomer();
                        Navigator.of(context).pop();
                      },
                    ),
                  const SizedBox(width: POSUiTokens.gap),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomerSearchField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _query = value);
                  ref.read(customersProvider.notifier).searchCustomers(value);
                },
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                  ref.read(customersProvider.notifier).loadCustomers();
                },
              ),
              const SizedBox(height: 16),
              Flexible(
                child: customersAsync.when(
                  data: (customers) {
                    final visibleCustomers = filterCustomersForPOS(
                      customers,
                      _query,
                    );
                    if (visibleCustomers.isEmpty) {
                      return POSEmptyState(
                        icon: Icons.person_search_outlined,
                        title: 'No customers found',
                        message:
                            _query.trim().isEmpty
                                ? 'Customers will appear here once loaded.'
                                : 'Try another name, phone, or email.',
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: visibleCustomers.length,
                      separatorBuilder:
                          (_, _) => const SizedBox(height: POSUiTokens.gap),
                      itemBuilder: (context, index) {
                        final customer = visibleCustomers[index];
                        return CustomerTile(
                          customer: customer,
                          selected: currentOrder?.customer?.id == customer.id,
                          onSelected: () => _selectCustomer(context, customer),
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error:
                      (error, stackTrace) => POSEmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: 'Customers unavailable',
                        message: friendlyPOSErrorMessage(
                          error,
                          fallbackMessage:
                              'Customers could not be loaded. Check the connection and retry.',
                        ),
                        action: POSActionButton(
                          icon: const Icon(Icons.refresh),
                          label: 'Retry',
                          onPressed:
                              () =>
                                  ref
                                      .read(customersProvider.notifier)
                                      .loadCustomers(),
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: POSActionButton(
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: 'Add new customer',
                  variant: POSActionButtonVariant.tonal,
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Add new customer feature coming soon.'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectCustomer(BuildContext context, Customer customer) {
    ref.read(currentOrderProvider.notifier).setCustomer(customer);
    Navigator.of(context).pop();
  }
}
