import 'package:flutter/material.dart';

import '../response/response_vosualization.dart';

class AnalysisScreen extends ConsumerWidget {
  final String surveyId;

  const AnalysisScreen({super.key, required this.surveyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsesAsync = ref.watch(surveyResponsesProvider(surveyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportData(context, ref),
          ),
        ],
      ),
      body: responsesAsync.when(
        data: (responses) => _buildAnalysis(context, responses),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildAnalysis(BuildContext context, List<SurveyResponse> responses) {
    return ListView.builder(
      itemCount: responses.first.answers.length,
      itemBuilder: (context, index) {
        final questionId = responses.first.answers.keys.elementAt(index);
        return Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${index + 1}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ResponseVisualization(
                  responses: responses,
                  questionId: questionId,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final format = await showDialog<ExportFormat>(
      context: context,
      builder: (context) => const ExportFormatDialog(),
    );

    if (format != null) {
      final exporter = ref.read(dataExporterProvider);
      await exporter.exportSurveyData(surveyId, format);
    }
  }
}
