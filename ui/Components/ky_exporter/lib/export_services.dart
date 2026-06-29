import 'package:xlsx/xlsx.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class AdvancedExportService {
  Future<void> exportToInteractiveHTML(
    List<SurveyResponse> responses,
    StatisticalAnalysis analysis,
  ) async {
    final template = await _loadHTMLTemplate();
    final chartData = _prepareChartData(responses);
    final stats = _prepareStatistics(analysis);
    
    final html = template
        .replaceAll('{{chartData}}', json.encode(chartData))
        .replaceAll('{{stats}}', json.encode(stats));
    
    // Save HTML file with embedded JavaScript visualization
    await _saveFile('survey_results.html', html);
  }

  Future<void> exportToTableau(List<SurveyResponse> responses) async {
    final hyper = await _createTableauHyperFile(responses);
    await _saveFile('survey_data.hyper', hyper);
  }

  Future<void> exportToR(
    List<SurveyResponse> responses,
    StatisticalAnalysis analysis,
  ) async {
    final rScript = _generateRScript(responses, analysis);
    await _saveFile('analysis.R', rScript);
  }

  Future<void> exportToPython(
    List<SurveyResponse> responses,
    StatisticalAnalysis analysis,
  ) async {
    final pythonScript = _generatePythonScript(responses, analysis);
    await _saveFile('analysis.py', pythonScript);
  }

  String _generateRScript(
    List<SurveyResponse> responses,
    StatisticalAnalysis analysis,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('library(tidyverse)');
    buffer.writeln('library(ggplot2)');
    buffer.writeln();
    
    // Generate R code for data import and analysis
    buffer.writeln('# Import data');
    buffer.writeln('data <- read.csv("survey_data.csv")');
    
    // Add visualization code
    buffer.writeln('\n# Create visualizations');
    buffer.writeln('ggplot(data, aes(x = response)) +');
    buffer.writeln('  geom_histogram() +');
    buffer.writeln('  theme_minimal()');
    
    return buffer.toString();
  }

  String _generatePythonScript(
    List<SurveyResponse> responses,
    StatisticalAnalysis analysis,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('import pandas as pd');
    buffer.writeln('import seaborn as sns');
    buffer.writeln('import matplotlib.pyplot as plt');
    buffer.writeln();
    
    // Generate Python code for data import and analysis
    buffer.writeln('# Import data');
    buffer.writeln('data = pd.read_csv("survey_data.csv")');
    
    // Add visualization code
    buffer.writeln('\n# Create visualizations');
    buffer.writeln('sns.set_theme(style="whitegrid")');
    buffer.writeln('plt.figure(figsize=(10, 6))');
    buffer.writeln('sns.histplot(data=data, x="response")');
    
    return buffer.toString();
  }
}
