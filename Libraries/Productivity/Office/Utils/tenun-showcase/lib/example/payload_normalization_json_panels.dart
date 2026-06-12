import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PayloadNormalizationJsonPanels extends StatelessWidget {
  const PayloadNormalizationJsonPanels({
    super.key,
    required this.raw,
    required this.normalized,
    required this.diagnostics,
  });

  final Map<String, dynamic> raw;
  final Map<String, dynamic> normalized;
  final Map<String, dynamic> diagnostics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PayloadNormalizationJsonPanel(
            title: 'Raw JSON',
            jsonText: const JsonEncoder.withIndent('  ').convert(raw),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PayloadNormalizationJsonPanel(
            title: 'Normalized JSON',
            jsonText: const JsonEncoder.withIndent('  ').convert(normalized),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: PayloadNormalizationJsonPanel(
            title: 'Diagnostics JSON',
            jsonText: const JsonEncoder.withIndent('  ').convert(diagnostics),
          ),
        ),
      ],
    );
  }
}

class PayloadNormalizationJsonPanel extends StatelessWidget {
  const PayloadNormalizationJsonPanel({
    super.key,
    required this.title,
    required this.jsonText,
  });

  final String title;
  final String jsonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: SelectableText(
                jsonText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PayloadNormalizationCopyButton extends StatelessWidget {
  const PayloadNormalizationCopyButton({
    super.key,
    required this.label,
    required this.payload,
  });

  final String label;
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        final text = const JsonEncoder.withIndent('  ').convert(payload);
        await Clipboard.setData(ClipboardData(text: text));
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$label copied')));
        }
      },
      child: Text(label),
    );
  }
}
