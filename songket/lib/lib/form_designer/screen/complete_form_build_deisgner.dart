import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/dropoff_point.dart';
import '../model/form_analytics.dart';
import '../model/form_template.dart';
import '../model/form_theme.dart';
import '../model/test_caset.dart';
import '../service/theme_manager.dart';
import '../states/form_field_provider.dart';
import '../utils/export_manager.dart';
import '../utils/template_library.dart';
import '../widget/complete_component_palette.dart';
import '../widget/complete_properties_panel.dart';
import '../widget/form_canvas_widget.dart';
import '../widget/form_tester.dart';

class CompleteFormBuilderDesigner extends ConsumerStatefulWidget {
  const CompleteFormBuilderDesigner({super.key});

  @override
  ConsumerState<CompleteFormBuilderDesigner> createState() =>
      _CompleteFormBuilderDesignerState();
}

class _CompleteFormBuilderDesignerState
    extends ConsumerState<CompleteFormBuilderDesigner> {
  int _selectedPhase = 0;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeManagerProvider);

    return Scaffold(
      backgroundColor: theme.colors.background,
      appBar: AppBar(
        title: const Text('🚀 Form Builder - Complete (Phases 1-4)'),
        backgroundColor: theme.colors.surface,
        foregroundColor: theme.colors.text,
        actions: [
          // Phase selector
          PopupMenuButton<int>(
            icon: Icon(Icons.layers, color: theme.colors.primary),
            tooltip: 'Select Phase',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('Phase 1: Core Features'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('Phase 2: Visual & Layout'),
              ),
              const PopupMenuItem(
                value: 2,
                child: Text('Phase 3: Advanced Features'),
              ),
              const PopupMenuItem(
                value: 3,
                child: Text('Phase 4: Integration'),
              ),
            ],
            onSelected: (value) => setState(() => _selectedPhase = value),
          ),

          // Export menu
          PopupMenuButton<ExportFormat>(
            icon: Icon(Icons.download, color: theme.colors.text),
            tooltip: 'Export',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ExportFormat.json,
                child: Text('📄 JSON'),
              ),
              const PopupMenuItem(
                value: ExportFormat.yaml,
                child: Text('📋 YAML'),
              ),
              const PopupMenuItem(
                value: ExportFormat.xml,
                child: Text('🔖 XML'),
              ),
              const PopupMenuItem(
                value: ExportFormat.flutterCode,
                child: Text('📱 Flutter Code'),
              ),
              const PopupMenuItem(
                value: ExportFormat.reactCode,
                child: Text('⚛️ React Code'),
              ),
              const PopupMenuItem(
                value: ExportFormat.html,
                child: Text('🌐 HTML'),
              ),
              const PopupMenuItem(
                value: ExportFormat.markdown,
                child: Text('📝 Markdown'),
              ),
            ],
            onSelected: (format) => _handleExport(format),
          ),

          // Templates
          IconButton(
            icon: Icon(Icons.library_books, color: theme.colors.text),
            tooltip: 'Templates',
            onPressed: () => _showTemplateLibrary(),
          ),

          // Testing
          IconButton(
            icon: Icon(Icons.bug_report, color: theme.colors.text),
            tooltip: 'Test Form',
            onPressed: () => _showTestRunner(),
          ),

          // Analytics
          IconButton(
            icon: Icon(Icons.analytics, color: theme.colors.text),
            tooltip: 'Analytics',
            onPressed: () => _showAnalytics(),
          ),

          // Versioning
          IconButton(
            icon: Icon(Icons.history, color: theme.colors.text),
            tooltip: 'Version History',
            onPressed: () => _showVersionHistory(),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Component Palette
          CompleteComponentPalette(theme: theme, phase: _selectedPhase),

          // Main canvas
          Expanded(
            child: Column(
              children: [
                // Phase toolbar
                _buildPhaseToolbar(theme),

                // Canvas area
                Expanded(child: FormCanvasWidget(theme: theme)),
              ],
            ),
          ),

          // Right sidebar - Properties & Tools
          CompletePropertiesPanel(theme: theme, phase: _selectedPhase),
        ],
      ),
      floatingActionButton: _buildFloatingActions(theme),
    );
  }

  Widget _buildPhaseToolbar(FormTheme theme) {
    final phaseInfo = [
      {'name': 'Core', 'icon': Icons.build, 'color': Colors.blue},
      {'name': 'Visual', 'icon': Icons.palette, 'color': Colors.purple},
      {'name': 'Advanced', 'icon': Icons.settings, 'color': Colors.orange},
      {
        'name': 'Integration',
        'icon': Icons.integration_instructions,
        'color': Colors.green,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Row(
        children: [
          ...phaseInfo.asMap().entries.map((entry) {
            final index = entry.key;
            final info = entry.value;
            final isActive = _selectedPhase == index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPhase = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (info['color'] as Color).withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isActive
                          ? (info['color'] as Color)
                          : theme.colors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        info['icon'] as IconData,
                        color: isActive
                            ? (info['color'] as Color)
                            : theme.colors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Phase ${index + 1}: ${info['name']}',
                        style: TextStyle(
                          color: isActive
                              ? (info['color'] as Color)
                              : theme.colors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          // Quick stats
          _buildQuickStat(
            theme,
            Icons.layers,
            '${ref.watch(formFieldsProvider).length} Fields',
          ),
          const SizedBox(width: 16),
          _buildQuickStat(theme, Icons.check_circle, 'Ready'),
        ],
      ),
    );
  }

  Widget _buildQuickStat(FormTheme theme, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: theme.colors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: theme.colors.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActions(FormTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'preview',
          mini: true,
          backgroundColor: theme.colors.primary,
          onPressed: () => _showPreview(),
          child: const Icon(Icons.visibility, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'save',
          mini: true,
          backgroundColor: Colors.green,
          onPressed: () => _saveForm(),
          child: const Icon(Icons.save, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'deploy',
          backgroundColor: theme.colors.primary,
          onPressed: () => _deployForm(),
          child: const Icon(Icons.rocket_launch),
        ),
      ],
    );
  }

  void _handleExport(ExportFormat format) {
    final fields = ref.read(formFieldsProvider);
    final theme = ref.read(themeManagerProvider);
    final exported = ExportManager.export(fields, format, theme);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.download, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text(
              'Export as ${format.toString().split('.').last.toUpperCase()}',
              style: TextStyle(color: theme.colors.text),
            ),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Generated ${format.toString().split('.').last} export',
                      style: TextStyle(
                        color: theme.colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: theme.colors.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: exported));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('✅ Copied to clipboard!'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colors.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      exported,
                      style: const TextStyle(
                        color: Color(0xFF4EC9B0),
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colors.primary,
            ),
            onPressed: () {
              // In a real app, trigger file download
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📥 Download started')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showTemplateLibrary() {
    final theme = ref.read(themeManagerProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.library_books, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text(
              'Template Library',
              style: TextStyle(color: theme.colors.text),
            ),
          ],
        ),
        content: SizedBox(
          width: 800,
          height: 600,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: TemplateLibrary.predefined.length,
            itemBuilder: (context, index) {
              final template = TemplateLibrary.predefined[index];
              return _buildTemplateCard(template, theme);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(FormTemplate template, FormTheme theme) {
    return InkWell(
      onTap: () {
        // Load template
        ref.read(formFieldsProvider.notifier).clear();
        for (final field in template.fields) {
          ref.read(formFieldsProvider.notifier).addField(field);
        }
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Loaded template: ${template.name}')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(template.thumbnail, style: const TextStyle(fontSize: 32)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    template.category,
                    style: TextStyle(color: theme.colors.primary, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              template.name,
              style: TextStyle(
                color: theme.colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: TextStyle(color: theme.colors.textSecondary, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  template.rating.toString(),
                  style: TextStyle(color: theme.colors.text, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.download,
                  color: theme.colors.textSecondary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${template.usageCount}',
                  style: TextStyle(
                    color: theme.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTestRunner() {
    final theme = ref.read(themeManagerProvider);
    final fields = ref.read(formFieldsProvider);
    final testCases = FormTester.generateTestCases(fields);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.bug_report, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Test Runner', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Generated ${testCases.length} test cases for ${fields.length} fields',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: testCases.length,
                  itemBuilder: (context, index) {
                    final test = testCases[index];
                    return _buildTestCaseItem(test, theme);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run All Tests'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🧪 Running tests...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestCaseItem(TestCase test, FormTheme theme) {
    final resultColor = test.expectedResult == TestResult.success
        ? Colors.green
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colors.border),
      ),
      child: Row(
        children: [
          Icon(
            test.expectedResult == TestResult.success
                ? Icons.check_circle
                : Icons.error,
            color: resultColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.name,
                  style: TextStyle(
                    color: theme.colors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Input: "${test.input}"',
                  style: TextStyle(
                    color: theme.colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    final theme = ref.read(themeManagerProvider);

    // Mock analytics data
    final analytics = FormAnalytics(
      totalSubmissions: 1523,
      successfulSubmissions: 1401,
      failedSubmissions: 122,
      averageCompletionTime: 45.3,
      fieldErrors: {'email': 67, 'phone': 34, 'password': 21},
      fieldCompletionRate: {
        'name': 0.98,
        'email': 0.95,
        'phone': 0.87,
        'message': 0.92,
      },
      dropOffPoints: [
        DropOffPoint(
          fieldId: 'phone',
          fieldLabel: 'Phone Number',
          dropOffCount: 87,
          dropOffRate: 0.057,
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.analytics, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Form Analytics', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: SizedBox(
          width: 700,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        theme,
                        'Total Submissions',
                        '${analytics.totalSubmissions}',
                        Icons.send,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        theme,
                        'Success Rate',
                        '${((analytics.successfulSubmissions / analytics.totalSubmissions) * 100).toStringAsFixed(1)}%',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        theme,
                        'Avg. Time',
                        '${analytics.averageCompletionTime.toStringAsFixed(1)}s',
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        theme,
                        'Failed',
                        '${analytics.failedSubmissions}',
                        Icons.error,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Field errors
                Text(
                  'Field Errors',
                  style: TextStyle(
                    color: theme.colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...analytics.fieldErrors.entries.map((entry) {
                  return _buildErrorBar(
                    theme,
                    entry.key,
                    entry.value,
                    analytics.totalSubmissions,
                  );
                }),

                const SizedBox(height: 24),

                // Completion rates
                Text(
                  'Field Completion Rates',
                  style: TextStyle(
                    color: theme.colors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ...analytics.fieldCompletionRate.entries.map((entry) {
                  return _buildCompletionBar(theme, entry.key, entry.value);
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Export Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colors.primary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📊 Exporting analytics report...'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    FormTheme theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: theme.colors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: theme.colors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBar(
    FormTheme theme,
    String fieldName,
    int errors,
    int total,
  ) {
    final percentage = (errors / total) * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fieldName,
                  style: TextStyle(color: theme.colors.text, fontSize: 13),
                ),
              ),
              Text(
                '$errors errors (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: theme.colors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionBar(FormTheme theme, String fieldName, double rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  fieldName,
                  style: TextStyle(color: theme.colors.text, fontSize: 13),
                ),
              ),
              Text(
                '${(rate * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: rate,
            backgroundColor: theme.colors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  void _showVersionHistory() {
    final theme = ref.read(themeManagerProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.history, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Version History', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: const SizedBox(
          width: 500,
          height: 400,
          child: Center(
            child: Text('Version history feature - Manage form versions here'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create Version'),
            onPressed: () {
              // Create new version
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showPreview() {
    final theme = ref.read(themeManagerProvider);
    final fields = ref.read(formFieldsProvider);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.colors.surface,
        child: Container(
          width: 600,
          height: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility, color: theme.colors.primary),
                  const SizedBox(width: 12),
                  Text(
                    'Form Preview',
                    style: TextStyle(
                      color: theme.colors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colors.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colors.border),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: fields.map((field) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (field.label != null) ...[
                                Text(
                                  field.label!,
                                  style: TextStyle(
                                    color: theme.colors.text,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              TextField(
                                style: TextStyle(color: theme.colors.text),
                                decoration: InputDecoration(
                                  hintText: field.hint,
                                  hintStyle: TextStyle(
                                    color: theme.colors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: theme.colors.inputBackground,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: theme.colors.border,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💾 Form saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deployForm() {
    final theme = ref.read(themeManagerProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colors.surface,
        title: Row(
          children: [
            Icon(Icons.rocket_launch, color: theme.colors.primary),
            const SizedBox(width: 12),
            Text('Deploy Form', style: TextStyle(color: theme.colors.text)),
          ],
        ),
        content: const Text('Choose deployment option:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Deploy to Cloud'),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🚀 Deploying to cloud...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
