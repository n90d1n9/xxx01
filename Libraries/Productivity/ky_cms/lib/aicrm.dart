// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/legacy.dart';
//import 'screens/lead_scoring_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: CRMAIApp()));
}

class CRMAIApp extends StatelessWidget {
  const CRMAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM AI Lead Scoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      home: const LeadScoringDashboard(),
    );
  }
}

// models/lead.dart
class Lead {
  final String id;
  final String name;
  final String company;
  final String email;
  final double score;
  final String status;
  final double conversionProbability;
  final List<String> intentSignals;
  final Map<String, dynamic> behaviorData;
  final DateTime lastActivity;
  final String source;

  Lead({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.score,
    required this.status,
    required this.conversionProbability,
    required this.intentSignals,
    required this.behaviorData,
    required this.lastActivity,
    required this.source,
  });
}

class ForecastData {
  final String period;
  final double predicted;
  final double actual;
  final double confidence;

  ForecastData({
    required this.period,
    required this.predicted,
    required this.actual,
    required this.confidence,
  });
}

// providers/lead_providers.dart
final leadsProvider = StateNotifierProvider<LeadsNotifier, List<Lead>>((ref) {
  return LeadsNotifier();
});

class LeadsNotifier extends StateNotifier<List<Lead>> {
  LeadsNotifier() : super(_mockLeads);

  void updateLeadScore(String leadId, double newScore) {
    state = state.map((lead) {
      if (lead.id == leadId) {
        return Lead(
          id: lead.id,
          name: lead.name,
          company: lead.company,
          email: lead.email,
          score: newScore,
          status: lead.status,
          conversionProbability: lead.conversionProbability,
          intentSignals: lead.intentSignals,
          behaviorData: lead.behaviorData,
          lastActivity: lead.lastActivity,
          source: lead.source,
        );
      }
      return lead;
    }).toList();
  }
}

final forecastProvider = StateProvider<List<ForecastData>>((ref) {
  return _mockForecastData;
});

final selectedTimeRangeProvider = StateProvider<String>((ref) => '30d');

// Mock data
final _mockLeads = [
  Lead(
    id: '1',
    name: 'Sarah Chen',
    company: 'TechCorp Solutions',
    email: 'sarah.chen@techcorp.com',
    score: 94.5,
    status: 'Hot',
    conversionProbability: 0.87,
    intentSignals: ['Pricing Page Views', 'Demo Request', 'Feature Comparison'],
    behaviorData: {'pageViews': 45, 'emailOpens': 12, 'downloads': 3},
    lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
    source: 'LinkedIn Campaign',
  ),
  Lead(
    id: '2',
    name: 'Marcus Rodriguez',
    company: 'InnovateLabs',
    email: 'marcus@innovatelabs.io',
    score: 78.2,
    status: 'Warm',
    conversionProbability: 0.64,
    intentSignals: ['Product Tours', 'Blog Engagement'],
    behaviorData: {'pageViews': 23, 'emailOpens': 8, 'downloads': 1},
    lastActivity: DateTime.now().subtract(const Duration(hours: 6)),
    source: 'Organic Search',
  ),
  Lead(
    id: '3',
    name: 'Emma Thompson',
    company: 'DataFlow Inc',
    email: 'emma.t@dataflow.com',
    score: 56.8,
    status: 'Cold',
    conversionProbability: 0.34,
    intentSignals: ['Newsletter Signup'],
    behaviorData: {'pageViews': 8, 'emailOpens': 3, 'downloads': 0},
    lastActivity: DateTime.now().subtract(const Duration(days: 2)),
    source: 'Content Marketing',
  ),
];

final _mockForecastData = [
  ForecastData(
    period: 'Week 1',
    predicted: 125000,
    actual: 120000,
    confidence: 0.92,
  ),
  ForecastData(
    period: 'Week 2',
    predicted: 138000,
    actual: 142000,
    confidence: 0.89,
  ),
  ForecastData(
    period: 'Week 3',
    predicted: 156000,
    actual: 151000,
    confidence: 0.94,
  ),
  ForecastData(
    period: 'Week 4',
    predicted: 172000,
    actual: 0,
    confidence: 0.87,
  ),
  ForecastData(
    period: 'Week 5',
    predicted: 189000,
    actual: 0,
    confidence: 0.82,
  ),
];

// screens/lead_scoring_dashboard.dart
class LeadScoringDashboard extends ConsumerWidget {
  const LeadScoringDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leads = ref.watch(leadsProvider);
    final forecastData = ref.watch(forecastProvider);
    final selectedRange = ref.watch(selectedTimeRangeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMetricsRow(context, leads),
                const SizedBox(height: 24),
                _buildForecastCard(context, ref, forecastData, selectedRange),
                const SizedBox(height: 24),
                _buildLeadScoringCard(context, leads),
                const SizedBox(height: 24),
                _buildAIInsightsCard(context),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLeadDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Lead'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'AI Lead Scoring & Forecasting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMetricsRow(BuildContext context, List<Lead> leads) {
    final hotLeads = leads.where((l) => l.status == 'Hot').length;
    final avgScore = leads.fold(0.0, (sum, l) => sum + l.score) / leads.length;
    final totalValue = leads.fold(
      0.0,
      (sum, l) => sum + (l.conversionProbability * 50000),
    );

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Hot Leads',
            hotLeads.toString(),
            Icons.local_fire_department,
            Colors.orange,
            '+12%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Avg Score',
            avgScore.toStringAsFixed(1),
            Icons.trending_up,
            Colors.green,
            '+5.2%',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            context,
            'Pipeline Value',
            '\$${(totalValue / 1000).toStringAsFixed(0)}K',
            Icons.account_balance_wallet,
            Colors.blue,
            '+8.7%',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastCard(
    BuildContext context,
    WidgetRef ref,
    List<ForecastData> data,
    String selectedRange,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Forecast',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI-powered pipeline predictions',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '7d', label: Text('7D')),
                  ButtonSegment(value: '30d', label: Text('30D')),
                  ButtonSegment(value: '90d', label: Text('90D')),
                ],
                selected: {selectedRange},
                onSelectionChanged: (Set<String> selection) {
                  ref.read(selectedTimeRangeProvider.notifier).state =
                      selection.first;
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: _buildForecastChart(context, data)),
          const SizedBox(height: 16),
          _buildForecastLegend(context),
        ],
      ),
    );
  }

  Widget _buildForecastChart(BuildContext context, List<ForecastData> data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: CustomPaint(
        painter: ForecastChartPainter(data, Theme.of(context).colorScheme),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildForecastLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          context,
          'Predicted',
          Theme.of(context).colorScheme.primary,
        ),
        _buildLegendItem(context, 'Actual', Colors.green),
        _buildLegendItem(context, 'Confidence', Colors.orange),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildLeadScoringCard(BuildContext context, List<Lead> leads) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lead Scoring',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.analytics_outlined),
                label: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...leads.take(3).map((lead) => _buildLeadScoreItem(context, lead)),
        ],
      ),
    );
  }

  Widget _buildLeadScoreItem(BuildContext context, Lead lead) {
    Color statusColor = lead.status == 'Hot'
        ? Colors.red
        : lead.status == 'Warm'
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Text(
              lead.name.split(' ').map((n) => n[0]).join(''),
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lead.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  lead.company,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score: ${lead.score.toStringAsFixed(1)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: lead.score / 100,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(lead.conversionProbability * 100).toInt()}%',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                        ),
                        Text(
                          'Conversion',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.psychology,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInsightItem(
            context,
            'High-Intent Leads',
            '3 leads showing strong buying signals this week',
            Icons.trending_up,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            context,
            'Pipeline Risk',
            '2 deals at risk of churning - immediate action needed',
            Icons.warning,
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            context,
            'Forecast Accuracy',
            'Model confidence increased to 94% this month',
            Icons.verified,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddLeadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lead'),
        content: const Text(
          'Lead addition functionality would be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for forecast chart
class ForecastChartPainter extends CustomPainter {
  final List<ForecastData> data;
  final ColorScheme colorScheme;

  ForecastChartPainter(this.data, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final predictedPath = Path();
    final actualPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final predictedY =
          size.height - (data[i].predicted / 200000) * size.height;
      final actualY = data[i].actual > 0
          ? size.height - (data[i].actual / 200000) * size.height
          : predictedY;

      if (i == 0) {
        predictedPath.moveTo(x, predictedY);
        if (data[i].actual > 0) actualPath.moveTo(x, actualY);
      } else {
        predictedPath.lineTo(x, predictedY);
        if (data[i].actual > 0) actualPath.lineTo(x, actualY);
      }
    }

    // Draw predicted line
    paint.color = colorScheme.primary;
    canvas.drawPath(predictedPath, paint);

    // Draw actual line
    paint.color = Colors.green;
    canvas.drawPath(actualPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
