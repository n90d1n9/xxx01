import 'package:flutter/material.dart';

import '../models/waraq_shell_models.dart';

/// Compact information pane used by Waraq shell diagnostics destinations.
class WaraqInfoScreen extends StatelessWidget {
  /// Creates a reusable information pane from immutable display data.
  const WaraqInfoScreen({super.key, required this.spec});

  /// Content rendered by this information pane.
  final WaraqInfoScreenSpec spec;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282A36),
      appBar: AppBar(
        backgroundColor: const Color(0xFF21222C),
        title: Text(
          spec.title,
          style: const TextStyle(color: Color(0xFFF8F8F2), fontSize: 14),
        ),
      ),
      body: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(spec.icon, color: const Color(0xFF8BE9FD), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        spec.subtitle,
                        style: const TextStyle(
                          color: Color(0xFFF8F8F2),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                for (final item in spec.items) ...[
                  WaraqInfoRow(item: item),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One stable label/value row in a Waraq information screen.
class WaraqInfoRow extends StatelessWidget {
  /// Creates a label/value information row.
  const WaraqInfoRow({super.key, required this.item});

  /// Display data for this row.
  final WaraqInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: const Color(0xFF21222C),
        border: Border(left: BorderSide(color: item.accent, width: 3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              item.label,
              style: const TextStyle(color: Color(0xFF9AA6C3), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              item.value,
              style: const TextStyle(
                color: Color(0xFFF8F8F2),
                fontSize: 13,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
