import 'package:flutter/material.dart';
import 'package:tenun/tenun_core.dart' show TenunChartFromJson;

import 'chart_sample_source_helpers.dart';
import 'chart_samples_registry.dart';
import 'showcase_source_panel.dart';

export 'chart_sample_source_helpers.dart';

class ChartSampleGallery extends StatelessWidget {
  const ChartSampleGallery({
    super.key,
    required this.samples,
    this.options = const ChartSampleShowcaseOptions(),
    this.padding = const EdgeInsets.all(12),
  });

  final List<ChartShowcaseSample> samples;
  final ChartSampleShowcaseOptions options;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: padding,
      child: ChartSampleList(samples: samples, options: options),
    );
  }
}

class ChartSampleList extends StatelessWidget {
  const ChartSampleList({
    super.key,
    required this.samples,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final List<ChartShowcaseSample> samples;
  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final sample in samples)
          ChartSamplePanel(sample: sample, options: options),
      ],
    );
  }
}

class ChartSamplePanel extends StatelessWidget {
  const ChartSamplePanel({
    super.key,
    required this.sample,
    this.options = const ChartSampleShowcaseOptions(),
  });

  final ChartShowcaseSample sample;
  final ChartSampleShowcaseOptions options;

  @override
  Widget build(BuildContext context) {
    final json = chartSampleJsonWithOptions(sample.json, options);
    final jsonText = chartSampleJsonText(json);
    final codeText =
        sample.code ??
        chartSampleCodeText(json, chartPadding: options.chartPadding);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (options.showSampleTitle) ...[
            Text(sample.title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
          ],
          if (options.showChart) ...[
            SizedBox(
              height: sample.height,
              child: TenunChartFromJson(
                jsonConfig: json,
                padding: EdgeInsets.all(options.chartPadding),
              ),
            ),
          ],
          if (options.showSampleSource) ...[
            const SizedBox(height: 8),
            ShowcaseSourceTextPanelGroup(
              panelHeight: options.sourcePanelHeight,
              minPanelWidth: options.sourcePanelMinWidth,
              items: [
                if (options.showSampleJson)
                  ShowcaseSourceTextItem(
                    title: 'Sample JSON',
                    text: jsonText,
                    copyLabel: '${sample.title} JSON',
                  ),
                if (options.showSampleCode)
                  ShowcaseSourceTextItem(
                    title: 'Dart Code',
                    text: codeText,
                    copyLabel: '${sample.title} code',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
