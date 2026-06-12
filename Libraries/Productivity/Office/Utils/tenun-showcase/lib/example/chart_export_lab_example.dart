import 'package:flutter/material.dart';
import 'package:tenun_pro/tenun_pro.dart' hide FontWeight;

class ChartExportLabExample extends StatefulWidget {
  const ChartExportLabExample({super.key});

  @override
  State<ChartExportLabExample> createState() => _ChartExportLabExampleState();
}

class _ChartExportLabExampleState extends State<ChartExportLabExample> {
  static const _categoryLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

  final ExportableChartController _exportController =
      ExportableChartController();
  late final BaseChartConfig _config;

  ChartExportResult? _lastResult;
  String? _clipboardNote;

  @override
  void initState() {
    super.initState();
    _config = BaseChartConfig.fromJson(_chartPayload);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 780;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chart Export Lab',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Export the same chart as CSV, XLSX, PNG, or JPEG through ChartExporter.export().',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 10),
              _buildExportButtons(),
              const SizedBox(height: 10),
              _buildStatusStrip(),
              const SizedBox(height: 10),
              Expanded(
                child: compact
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 300, child: _buildChartCard()),
                            const SizedBox(height: 10),
                            _buildResultPanel(),
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: _buildChartCard()),
                          const SizedBox(width: 12),
                          Expanded(flex: 2, child: _buildResultPanel()),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExportButtons() {
    return ChartExportControls(
      config: _config,
      controller: _exportController,
      categoryLabels: _categoryLabels,
      filename: 'tenun_export_lab',
      sheetName: 'Monthly Metrics',
      jpegQuality: 88,
      showStatus: false,
      onStarted: (_) {
        setState(() {
          _clipboardNote = null;
        });
      },
      onResult: (result) {
        setState(() {
          _lastResult = result;
          _clipboardNote = result.text != null ? 'Text export copied' : null;
        });
      },
    );
  }

  Widget _buildStatusStrip() {
    final result = _lastResult;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _metric('Formats', 'CSV / XLSX / PNG / JPEG'),
        _metric('Last Status', result == null ? 'idle' : _statusLabel(result)),
        _metric(
          'Last Size',
          result == null ? '-' : _formatBytes(result.sizeBytes),
        ),
        _metric('Last MIME', result?.mimeType ?? '-'),
      ],
    );
  }

  Widget _buildChartCard() {
    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ExportableTenunChart(
              config: _config,
              exportController: _exportController,
              showExportControls: false,
              chartPadding: const EdgeInsets.all(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultPanel() {
    final result = _lastResult;
    return DecoratedBox(
      decoration: _cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Result',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _kv('Filename', result?.filename ?? '-'),
            _kv('MIME', result?.mimeType ?? '-'),
            _kv('Size', result == null ? '-' : _formatBytes(result.sizeBytes)),
            _kv('Type', result == null ? '-' : result.format.name),
            _kv('State', result == null ? 'waiting' : _statusLabel(result)),
            if (_clipboardNote != null) _kv('Clipboard', _clipboardNote!),
            const SizedBox(height: 10),
            const Text(
              'Preview',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    result == null
                        ? 'Run an export to inspect the payload.'
                        : _preview(result),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Container(
      width: 156,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(ChartExportResult result) =>
      result.success ? 'ready' : 'failed';

  String _preview(ChartExportResult result) {
    if (!result.success) return result.error ?? 'Export failed.';
    final text = result.text;
    if (text != null) {
      return text.split(RegExp(r'\r?\n')).take(4).join('\n');
    }
    return result.preview(maxBytes: 12).replaceFirst('; ', '\n');
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x140F172A),
        blurRadius: 18,
        offset: Offset(0, 10),
      ),
    ],
  );

  static Map<String, dynamic> get _chartPayload => {
    'type': 'line',
    'title': {'text': 'Exportable Revenue Signal'},
    'tooltip': {'show': true},
    'legend': {'show': true},
    'xAxis': {'data': _categoryLabels},
    'yAxis': {'name': 'Value'},
    'showDots': true,
    'showBelowArea': true,
    'series': [
      {
        'name': 'Revenue',
        'data': [18, 24, 31, 29, 38, 44],
      },
      {
        'name': 'Cost',
        'data': [11, 15, 18, 19, 23, 25],
      },
    ],
  };
}
