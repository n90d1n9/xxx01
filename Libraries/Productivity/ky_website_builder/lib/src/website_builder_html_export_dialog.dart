import 'package:flutter/material.dart';
import 'package:ky_builder_shared/ky_builder_shared.dart';

import 'website_builder_html_exporter.dart';
import 'website_builder_html_export_preview.dart';

class WebsiteBuilderHtmlExportDialog extends StatefulWidget {
  final String projectName;
  final BuilderCanvasConfig canvasConfig;
  final List<BuilderComponentGeometry> components;
  final WebsiteBuilderHtmlExporter exporter;

  const WebsiteBuilderHtmlExportDialog({
    super.key,
    required this.projectName,
    required this.canvasConfig,
    required this.components,
    this.exporter = const WebsiteBuilderHtmlExporter(),
  });

  @override
  State<WebsiteBuilderHtmlExportDialog> createState() =>
      _WebsiteBuilderHtmlExportDialogState();
}

class _WebsiteBuilderHtmlExportDialogState
    extends State<WebsiteBuilderHtmlExportDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _languageController;
  bool _includeHiddenComponents = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.projectName);
    _languageController = TextEditingController(text: 'en');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = _currentOptions();
    final readiness = widget.exporter.inspect(
      components: widget.components,
      options: options,
    );
    final html = widget.exporter.exportDocument(
      projectName: widget.projectName,
      canvasConfig: widget.canvasConfig,
      components: widget.components,
      options: options,
    );

    return KyBuilderDialog(
      title: const Text('Copy HTML'),
      width: 620,
      height: 520,
      content: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.tune_outlined), text: 'Options'),
                Tab(icon: Icon(Icons.preview_outlined), text: 'Preview'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: _buildOptionsTab(theme, readiness),
                  ),
                  WebsiteBuilderHtmlExportPreview(
                    html: html,
                    readiness: readiness,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _canCopy ? _copyIfValid : null,
          icon: const Icon(Icons.content_copy),
          label: const Text('Copy'),
        ),
      ],
    );
  }

  Widget _buildOptionsTab(
    ThemeData theme,
    WebsiteBuilderHtmlExportReadiness readiness,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KyBuilderMetricStrip(
          metrics: [
            KyBuilderMetricItem(
              icon: Icons.visibility_outlined,
              value: '${readiness.visibleComponentCount}',
              label: 'visible',
            ),
            KyBuilderMetricItem(
              icon: Icons.visibility_off_outlined,
              value: '${readiness.hiddenComponentCount}',
              label: 'hidden',
            ),
            KyBuilderMetricItem(
              icon: Icons.code,
              value: '${readiness.exportedComponentCount}',
              label: 'export',
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _titleController,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Document title',
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _languageController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            helperText: 'Examples: en, id, en-US',
            labelText: 'Language code',
          ),
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _copyIfValid(),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: _includeHiddenComponents,
          onChanged:
              readiness.hiddenComponentCount == 0
                  ? null
                  : (value) {
                    setState(() {
                      _includeHiddenComponents = value ?? false;
                    });
                  },
          title: const Text('Include hidden components'),
          subtitle:
              readiness.hiddenComponentCount == 0
                  ? Text(
                    'No hidden components on this canvas.',
                    style: theme.textTheme.bodySmall,
                  )
                  : null,
        ),
        if (readiness.issues.isNotEmpty) ...[
          const SizedBox(height: 8),
          KyBuilderIssueList(
            issues: [
              for (final issue in readiness.issues)
                KyBuilderIssueItem(
                  severity: _exportIssueSeverity(issue.severity),
                  message: issue.message,
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _copyIfValid() {
    if (!_canCopy) return;
    Navigator.of(context).pop(_currentOptions());
  }

  bool get _canCopy {
    return _titleController.text.trim().isNotEmpty &&
        _languageController.text.trim().isNotEmpty;
  }

  WebsiteBuilderHtmlExportOptions _currentOptions() {
    return WebsiteBuilderHtmlExportOptions(
      documentTitle: _titleController.text,
      languageCode: _languageController.text,
      includeHiddenComponents: _includeHiddenComponents,
    );
  }
}

KyBuilderIssueSeverity _exportIssueSeverity(
  WebsiteBuilderHtmlExportIssueSeverity severity,
) {
  return switch (severity) {
    WebsiteBuilderHtmlExportIssueSeverity.info => KyBuilderIssueSeverity.info,
    WebsiteBuilderHtmlExportIssueSeverity.warning =>
      KyBuilderIssueSeverity.warning,
  };
}
