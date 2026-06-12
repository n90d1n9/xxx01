import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/billing_invoice_filter.dart';
import '../models/billing_invoice_status.dart';
import '../states/billing_dashboard_provider.dart';

class BillingInvoiceFilterBar extends ConsumerStatefulWidget {
  final String tenantId;

  const BillingInvoiceFilterBar({super.key, required this.tenantId});

  @override
  ConsumerState<BillingInvoiceFilterBar> createState() =>
      _BillingInvoiceFilterBarState();
}

class _BillingInvoiceFilterBarState
    extends ConsumerState<BillingInvoiceFilterBar> {
  late final TextEditingController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(
      text: ref.read(billingInvoiceFilterProvider(widget.tenantId)).query,
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BillingInvoiceFilter>(
      billingInvoiceFilterProvider(widget.tenantId),
      (previous, next) {
        if (_queryController.text == next.query) return;
        _queryController.value = TextEditingValue(
          text: next.query,
          selection: TextSelection.collapsed(offset: next.query.length),
        );
      },
    );

    final filter = ref.watch(billingInvoiceFilterProvider(widget.tenantId));
    final totalAsync = ref.watch(billingInvoicesProvider(widget.tenantId));
    final filteredAsync = ref.watch(
      filteredBillingInvoicesProvider(widget.tenantId),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 700;
            final isMedium = constraints.maxWidth < 900;
            final countLabel = _countLabel(totalAsync, filteredAsync);
            final controls = [
              SizedBox(
                width: isCompact ? double.infinity : 260,
                child: TextField(
                  controller: _queryController,
                  onChanged:
                      (value) => _updateFilter(
                        ref,
                        (filter) => filter.withQuery(value),
                      ),
                  decoration: _inputDecoration(
                    hintText: 'Search invoice',
                    prefixIcon: Icons.search,
                    suffixIcon:
                        filter.query.trim().isEmpty
                            ? null
                            : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _updateFilter(
                                  ref,
                                  (filter) => filter.withQuery(''),
                                );
                              },
                            ),
                  ),
                ),
              ),
              SizedBox(
                width: isCompact ? double.infinity : 180,
                child: _StatusDropdown(
                  tenantId: widget.tenantId,
                  selectedStatus: filter.status,
                ),
              ),
              SizedBox(
                width: isCompact ? double.infinity : 210,
                child: _SortDropdown(
                  tenantId: widget.tenantId,
                  selectedSort: filter.sort,
                ),
              ),
            ];
            final footer = _FilterFooter(
              tenantId: widget.tenantId,
              countLabel: countLabel,
              hasActiveFilters: filter.hasActiveFilters,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._spacedControls(controls, axis: Axis.vertical),
                  const SizedBox(height: 12),
                  footer,
                ],
              );
            }

            if (isMedium) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: _spacedControls(controls, axis: Axis.horizontal),
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: footer),
                ],
              );
            }

            return Row(
              children: [
                ..._spacedControls(controls, axis: Axis.horizontal),
                const Spacer(),
                footer,
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _spacedControls(List<Widget> controls, {required Axis axis}) {
    final spaced = <Widget>[];
    for (final control in controls) {
      if (spaced.isNotEmpty) {
        spaced.add(
          axis == Axis.vertical
              ? const SizedBox(height: 10)
              : const SizedBox(width: 10),
        );
      }
      spaced.add(control);
    }
    return spaced;
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6366F1)),
      ),
    );
  }

  String _countLabel<T, U>(
    AsyncValue<List<T>> totalAsync,
    AsyncValue<List<U>> filteredAsync,
  ) {
    return filteredAsync.maybeWhen(
      data:
          (filtered) => totalAsync.maybeWhen(
            data: (total) => '${filtered.length}/${total.length}',
            orElse: () => '${filtered.length}',
          ),
      orElse: () => '',
    );
  }

  void _updateFilter(
    WidgetRef ref,
    BillingInvoiceFilter Function(BillingInvoiceFilter filter) update,
  ) {
    final notifier = ref.read(
      billingInvoiceFilterProvider(widget.tenantId).notifier,
    );
    notifier.state = update(notifier.state);
  }
}

class _StatusDropdown extends ConsumerWidget {
  final String tenantId;
  final BillingInvoiceStatus? selectedStatus;

  const _StatusDropdown({required this.tenantId, required this.selectedStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MenuShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BillingInvoiceStatus?>(
          value: selectedStatus,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: [
            const DropdownMenuItem<BillingInvoiceStatus?>(
              value: null,
              child: Text('All statuses'),
            ),
            ...BillingInvoiceStatus.values.map(
              (status) => DropdownMenuItem<BillingInvoiceStatus?>(
                value: status,
                child: Text(status.label),
              ),
            ),
          ],
          onChanged: (status) {
            final notifier = ref.read(
              billingInvoiceFilterProvider(tenantId).notifier,
            );
            notifier.state = notifier.state.withStatus(status);
          },
        ),
      ),
    );
  }
}

class _SortDropdown extends ConsumerWidget {
  final String tenantId;
  final BillingInvoiceSortOption selectedSort;

  const _SortDropdown({required this.tenantId, required this.selectedSort});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _MenuShell(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BillingInvoiceSortOption>(
          value: selectedSort,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items:
              BillingInvoiceSortOption.values
                  .map(
                    (sort) => DropdownMenuItem<BillingInvoiceSortOption>(
                      value: sort,
                      child: Text(sort.label),
                    ),
                  )
                  .toList(),
          onChanged: (sort) {
            if (sort == null) return;
            final notifier = ref.read(
              billingInvoiceFilterProvider(tenantId).notifier,
            );
            notifier.state = notifier.state.withSort(sort);
          },
        ),
      ),
    );
  }
}

class _MenuShell extends StatelessWidget {
  final Widget child;

  const _MenuShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _FilterFooter extends ConsumerWidget {
  final String tenantId;
  final String countLabel;
  final bool hasActiveFilters;

  const _FilterFooter({
    required this.tenantId,
    required this.countLabel,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (countLabel.isNotEmpty)
          Text(
            '$countLabel invoices',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        if (hasActiveFilters)
          TextButton.icon(
            onPressed: () {
              final notifier = ref.read(
                billingInvoiceFilterProvider(tenantId).notifier,
              );
              notifier.state = notifier.state.reset();
            },
            icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
            label: const Text('Reset'),
          ),
      ],
    );
  }
}
