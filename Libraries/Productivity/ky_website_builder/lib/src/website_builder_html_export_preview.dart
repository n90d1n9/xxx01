import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_html_exporter.dart';

class WebsiteBuilderHtmlExportPreview extends StatelessWidget {
  final String html;
  final WebsiteBuilderHtmlExportReadiness readiness;

  const WebsiteBuilderHtmlExportPreview({
    super.key,
    required this.html,
    required this.readiness,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warningCount =
        readiness.issues
            .where(
              (issue) =>
                  issue.severity ==
                  WebsiteBuilderHtmlExportIssueSeverity.warning,
            )
            .length;
    final lineCount = '\n'.allMatches(html).length + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KyBuilderMetricStrip(
          metrics: [
            KyBuilderMetricItem(
              icon: Icons.code,
              value: '${readiness.exportedComponentCount}',
              label: 'export',
            ),
            KyBuilderMetricItem(
              icon: Icons.warning_amber_outlined,
              value: '$warningCount',
              label: 'warnings',
            ),
            KyBuilderMetricItem(
              icon: Icons.format_list_numbered,
              value: '$lineCount',
              label: 'lines',
            ),
            KyBuilderMetricItem(
              icon: Icons.data_object,
              value: '${html.length}',
              label: 'chars',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: KyBuilderPanel(
            backgroundAlpha: 0.38,
            clipContent: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SelectableText(
                    html,
                    key: const ValueKey(
                      'website-builder-html-export-preview-source',
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
