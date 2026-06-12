import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/domain_pack_contract_domain_filter.dart';
import '../utils/billing_business_domain_packs.dart';
import '../utils/domain_pack_contract.dart';

/// Popup filter for scoping billing domain-pack contracts by business domain.
class DomainPackContractDomainFilter extends StatelessWidget {
  final DomainPackContractDomainFilterSummary summary;
  final DomainPackContractDomainFilterSelection selectedSelection;
  final ValueChanged<DomainPackContractDomainFilterSelection>
  onSelectionSelected;

  const DomainPackContractDomainFilter({
    super.key,
    required this.summary,
    required this.selectedSelection,
    required this.onSelectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.isEmpty) return const SizedBox.shrink();

    final options = domainPackContractDomainFilterOptions(summary);
    final selected = selectedSelection.resolveFor(summary);
    final selectedOption = _optionForSelection(options, selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business domain',
          style: TextStyle(
            color: Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        PopupMenuButton<String>(
          key: const ValueKey('domain-pack-contract-domain-filter'),
          tooltip: 'Filter domain-pack contracts by business domain',
          initialValue: selectedOption.menuValue,
          onSelected: (value) {
            onSelectionSelected(
              domainPackContractDomainFilterSelectionForMenuValue(value),
            );
          },
          itemBuilder:
              (context) => [
                for (final option in options)
                  PopupMenuItem(
                    value: option.menuValue,
                    child: Text(
                      option.menuLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
          child: Container(
            height: 40,
            constraints: const BoxConstraints(minWidth: 188, maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.domain_outlined,
                  size: 17,
                  color: Color(0xFF0F766E),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    selectedOption.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${selectedOption.contractCount}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'Domain pack contract domain filter')
Widget domainPackContractDomainFilterPreview() {
  final summary = DomainPackContractDomainFilterSummary.fromRegistryReport(
    DomainPackContractRegistryReport.forRegistry(
      standardBillingDomainPackRegistry(),
    ),
  );

  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: DomainPackContractDomainFilter(
          summary: summary,
          selectedSelection: DomainPackContractDomainFilterSelection.domain(
            'construction',
          ),
          onSelectionSelected: (_) {},
        ),
      ),
    ),
  );
}

DomainPackContractDomainFilterOption _optionForSelection(
  List<DomainPackContractDomainFilterOption> options,
  DomainPackContractDomainFilterSelection selection,
) {
  for (final option in options) {
    if (option.domainKey == selection.domainKey) return option;
  }

  return options.first;
}
