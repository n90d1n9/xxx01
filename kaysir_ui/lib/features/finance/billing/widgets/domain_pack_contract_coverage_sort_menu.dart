import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../models/domain_pack_contract_coverage_sort.dart';

/// Popup sort menu for billing domain-pack contract coverage lists.
class DomainPackContractCoverageSortMenu extends StatelessWidget {
  final DomainPackContractCoverageSort value;
  final ValueChanged<DomainPackContractCoverageSort> onChanged;

  const DomainPackContractCoverageSortMenu({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DomainPackContractCoverageSort>(
      key: const ValueKey('domain-pack-contract-coverage-sort-menu'),
      tooltip: 'Sort domain-pack contracts',
      initialValue: value,
      onSelected: onChanged,
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder:
          (context) => [
            for (final option in DomainPackContractCoverageSort.values)
              PopupMenuItem<DomainPackContractCoverageSort>(
                value: option,
                child: _SortMenuItem(
                  label: option.label,
                  selected: option == value,
                ),
              ),
          ],
      child: Container(
        height: 40,
        constraints: const BoxConstraints(minWidth: 168, maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort_outlined, size: 17, color: Color(0xFF475569)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

@Preview(name: 'Domain pack contract coverage sort menu')
Widget domainPackContractCoverageSortMenuPreview() {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: DomainPackContractCoverageSortMenu(
          value: DomainPackContractCoverageSort.attention,
          onChanged: (_) {},
        ),
      ),
    ),
  );
}

class _SortMenuItem extends StatelessWidget {
  final String label;
  final bool selected;

  const _SortMenuItem({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child:
              selected
                  ? const Icon(Icons.check, size: 18, color: Color(0xFF2563EB))
                  : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF1D4ED8) : const Color(0xFF334155),
              fontSize: 13,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
