import 'package:flutter/material.dart';

import '../utils/billing_business_domain_blueprint_fit_matrix.dart';

class BillingBlueprintWideFitMatrix extends StatelessWidget {
  final BillingBusinessDomainBlueprintFitMatrix matrix;

  const BillingBlueprintWideFitMatrix({super.key, required this.matrix});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          _WideHeaderRow(columns: matrix.columns),
          ...matrix.rows.map(
            (row) => _WideDomainRow(row: row, columns: matrix.columns),
          ),
        ],
      ),
    );
  }
}

class BillingBlueprintCompactFitMatrix extends StatelessWidget {
  final BillingBusinessDomainBlueprintFitMatrix matrix;

  const BillingBlueprintCompactFitMatrix({super.key, required this.matrix});

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          matrix.rows
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CompactDomainCard(row: row, columns: matrix.columns),
                ),
              )
              .toList(),
    );
  }
}

class _WideHeaderRow extends StatelessWidget {
  final List<BillingBusinessDomainBlueprintFitColumn> columns;

  const _WideHeaderRow({required this.columns});

  @override
  Widget build(BuildContext context) {
    return _WideRowShell(
      backgroundColor: const Color(0xFFEFF6FF),
      domainChild: const Text(
        'Domain',
        style: TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
      signalChildren:
          columns
              .map(
                (column) => Text(
                  column.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _WideDomainRow extends StatelessWidget {
  final BillingBusinessDomainBlueprintFitRow row;
  final List<BillingBusinessDomainBlueprintFitColumn> columns;

  const _WideDomainRow({required this.row, required this.columns});

  @override
  Widget build(BuildContext context) {
    return _WideRowShell(
      domainChild: _DomainLabel(row: row),
      signalChildren:
          columns
              .map(
                (column) => BillingBlueprintFitCell(
                  cell: row.requireCell(column.signal),
                ),
              )
              .toList(),
    );
  }
}

class _WideRowShell extends StatelessWidget {
  final Widget domainChild;
  final List<Widget> signalChildren;
  final Color backgroundColor;

  const _WideRowShell({
    required this.domainChild,
    required this.signalChildren,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          SizedBox(width: 180, child: domainChild),
          const SizedBox(width: 8),
          ...signalChildren.map(
            (child) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactDomainCard extends StatelessWidget {
  final BillingBusinessDomainBlueprintFitRow row;
  final List<BillingBusinessDomainBlueprintFitColumn> columns;

  const _CompactDomainCard({required this.row, required this.columns});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DomainLabel(row: row),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                columns
                    .map(
                      (column) => BillingBlueprintFitCell(
                        label: column.label,
                        cell: row.requireCell(column.signal),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class _DomainLabel extends StatelessWidget {
  final BillingBusinessDomainBlueprintFitRow row;

  const _DomainLabel({required this.row});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.domainLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          row.productModeLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class BillingBlueprintFitCell extends StatelessWidget {
  final BillingBusinessDomainBlueprintFitCell cell;
  final String? label;

  const BillingBlueprintFitCell({super.key, required this.cell, this.label});

  @override
  Widget build(BuildContext context) {
    final color =
        cell.isSupported ? const Color(0xFF059669) : const Color(0xFF94A3B8);
    final background =
        cell.isSupported ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9);
    final icon =
        cell.isSupported
            ? Icons.check_circle_outline
            : Icons.remove_circle_outline;

    return Tooltip(
      message: cell.detail,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              if (label != null) ...[
                Text(
                  label!,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                cell.isSupported ? 'Fit' : 'No fit',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
