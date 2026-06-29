import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MLOpsPage extends ConsumerStatefulWidget {
  const MLOpsPage({super.key});

  @override
  ConsumerState<MLOpsPage> createState() => _MLOpsPageState();
}

class _MLOpsPageState extends ConsumerState<MLOpsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MLOps Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Monitoring', icon: Icon(Icons.monitor_heart)),
            Tab(text: 'Drift Detection', icon: Icon(Icons.warning)),
            Tab(text: 'CI/CD', icon: Icon(Icons.sync)),
            Tab(text: 'Governance', icon: Icon(Icons.policy)),
            Tab(text: 'Cost Analysis', icon: Icon(Icons.attach_money)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MonitoringTab(),
          _DriftDetectionTab(),
          _CICDTab(),
          _GovernanceTab(),
          _CostAnalysisTab(),
        ],
      ),
    );
  }
}

// Monitoring Tab
class _MonitoringTab extends StatelessWidget {
  const _MonitoringTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Real-time Model Monitoring',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Key Metrics
          Row(
            children: [
              Expanded(
                child: _MonitoringMetricCard(
                  title: 'Requests/min',
                  value: '1,234',
                  trend: '+12%',
                  isGood: true,
                  icon: Icons.speed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MonitoringMetricCard(
                  title: 'Avg Latency',
                  value: '45ms',
                  trend: '-8%',
                  isGood: true,
                  icon: Icons.timer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MonitoringMetricCard(
                  title: 'Error Rate',
                  value: '0.02%',
                  trend: '+0.01%',
                  isGood: false,
                  icon: Icons.error_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MonitoringMetricCard(
                  title: 'Availability',
                  value: '99.98%',
                  trend: '0%',
                  isGood: true,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Performance Graphs
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latency Distribution',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Text('P50: 38ms | P95: 82ms | P99: 125ms'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alerts',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _AlertItem(
                          severity: 'Warning',
                          message: 'High latency detected',
                          time: '5 min ago',
                        ),
                        _AlertItem(
                          severity: 'Info',
                          message: 'Model reloaded',
                          time: '1 hour ago',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Log Aggregation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Logs',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          FilterChip(
                            label: Text('Error'),
                            selected: true,
                            onSelected: (_) {},
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text('Warning'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text('Info'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SelectableText(
                      '[2024-11-04 10:23:45] ERROR: Request timeout after 5000ms\n'
                      '[2024-11-04 10:23:12] INFO: Model inference completed in 42ms\n'
                      '[2024-11-04 10:22:58] INFO: Request received from 192.168.1.1\n'
                      '[2024-11-04 10:22:45] ERROR: Invalid input format detected',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitoringMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isGood;
  final IconData icon;

  const _MonitoringMetricCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isGood,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.grey),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isGood
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 11,
                      color: isGood ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String severity;
  final String message;
  final String time;

  const _AlertItem({
    required this.severity,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final color = severity == 'Warning' ? Colors.orange : Colors.blue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(time, style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Drift Detection Tab
class _DriftDetectionTab extends StatelessWidget {
  const _DriftDetectionTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data & Model Drift Detection',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Drift Status
          Row(
            children: [
              Expanded(
                child: _DriftCard(
                  title: 'Data Drift',
                  status: 'Detected',
                  severity: 'Warning',
                  description: 'Input distribution has shifted',
                  metric: 'KL Divergence: 0.23',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DriftCard(
                  title: 'Concept Drift',
                  status: 'Stable',
                  severity: 'Good',
                  description: 'Model performance is consistent',
                  metric: 'Accuracy: 94% (±1%)',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DriftCard(
                  title: 'Prediction Drift',
                  status: 'Monitoring',
                  severity: 'Info',
                  description: 'Output patterns being tracked',
                  metric: 'Entropy: 1.45',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Drift Analysis
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feature Drift Analysis',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _DriftFeatureRow(
                    feature: 'Patient Age',
                    drift: 0.05,
                    threshold: 0.1,
                    status: 'OK',
                  ),
                  _DriftFeatureRow(
                    feature: 'Symptom Keywords',
                    drift: 0.23,
                    threshold: 0.1,
                    status: 'Drifted',
                  ),
                  _DriftFeatureRow(
                    feature: 'Medical History',
                    drift: 0.08,
                    threshold: 0.1,
                    status: 'OK',
                  ),
                  _DriftFeatureRow(
                    feature: 'Lab Results',
                    drift: 0.15,
                    threshold: 0.1,
                    status: 'Drifted',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Remediation Actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Actions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _ActionItem(
                    icon: Icons.refresh,
                    title: 'Retrain Model',
                    description:
                        'Incorporate recent data to adapt to distribution shift',
                  ),
                  _ActionItem(
                    icon: Icons.notifications_active,
                    title: 'Set Alert Threshold',
                    description: 'Configure alerts for drift exceeding 0.20',
                  ),
                  _ActionItem(
                    icon: Icons.analytics,
                    title: 'Analyze Root Cause',
                    description:
                        'Investigate why symptom keywords have drifted',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriftCard extends StatelessWidget {
  final String title;
  final String status;
  final String severity;
  final String description;
  final String metric;

  const _DriftCard({
    required this.title,
    required this.status,
    required this.severity,
    required this.description,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (severity) {
      case 'Warning':
        color = Colors.orange;
        break;
      case 'Good':
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              metric,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriftFeatureRow extends StatelessWidget {
  final String feature;
  final double drift;
  final double threshold;
  final String status;

  const _DriftFeatureRow({
    required this.feature,
    required this.drift,
    required this.threshold,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isDrifted = drift > threshold;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(feature)),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: drift / 0.3,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                isDrifted ? Colors.red : Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              drift.toStringAsFixed(3),
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isDrifted
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                color: isDrifted ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(description, style: TextStyle(fontSize: 12)),
      trailing: TextButton(child: Text('Execute'), onPressed: () {}),
    );
  }
}

// CI/CD Tab
class _CICDTab extends StatelessWidget {
  const _CICDTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Continuous Integration & Deployment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Pipeline Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pipeline Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Trigger Pipeline'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _PipelineStage(
                    name: 'Data Validation',
                    status: 'Success',
                    duration: '2m 15s',
                  ),
                  _PipelineStage(
                    name: 'Model Training',
                    status: 'Success',
                    duration: '1h 23m',
                  ),
                  _PipelineStage(
                    name: 'Model Evaluation',
                    status: 'Success',
                    duration: '8m 42s',
                  ),
                  _PipelineStage(
                    name: 'Integration Tests',
                    status: 'Running',
                    duration: '3m 11s',
                  ),
                  _PipelineStage(
                    name: 'Deploy to Staging',
                    status: 'Pending',
                    duration: '-',
                  ),
                  _PipelineStage(
                    name: 'Deploy to Production',
                    status: 'Pending',
                    duration: '-',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Deployment Strategy
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deployment Strategy',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Strategy',
                            border: OutlineInputBorder(),
                          ),
                          value: 'Canary',
                          items:
                              ['Blue-Green', 'Canary', 'Rolling', 'A/B Testing']
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Canary Configuration:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Start with 5% traffic',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Monitor for 30 minutes',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Increment by 25% if metrics OK',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '• Auto-rollback on error rate > 1%',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automated Tests',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _TestResultRow(
                          name: 'Unit Tests',
                          passed: 234,
                          failed: 0,
                        ),
                        _TestResultRow(
                          name: 'Integration Tests',
                          passed: 45,
                          failed: 0,
                        ),
                        _TestResultRow(
                          name: 'Performance Tests',
                          passed: 12,
                          failed: 1,
                        ),
                        _TestResultRow(
                          name: 'Security Scan',
                          passed: 8,
                          failed: 0,
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Coverage',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '87.5%',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PipelineStage extends StatelessWidget {
  final String name;
  final String status;
  final String duration;

  const _PipelineStage({
    required this.name,
    required this.status,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (status) {
      case 'Success':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'Running':
        icon = Icons.pending;
        color = Colors.blue;
        break;
      case 'Failed':
        icon = Icons.error;
        color = Colors.red;
        break;
      default:
        icon = Icons.radio_button_unchecked;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(name)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, style: TextStyle(fontSize: 11, color: color)),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              duration,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestResultRow extends StatelessWidget {
  final String name;
  final int passed;
  final int failed;

  const _TestResultRow({
    required this.name,
    required this.passed,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 13)),
          Row(
            children: [
              Text(
                '$passed',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(' / ', style: TextStyle(color: Colors.grey)),
              Text(
                '$failed',
                style: TextStyle(
                  color: failed > 0 ? Colors.red : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Governance Tab
class _GovernanceTab extends StatelessWidget {
  const _GovernanceTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Model Governance & Compliance',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Audit Trail
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Audit Trail',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _AuditEntry(
                    action: 'Model Deployed',
                    user: 'john.doe@example.com',
                    timestamp: '2024-11-04 10:23:45',
                    details: 'Medical QA v2.0 deployed to production',
                  ),
                  _AuditEntry(
                    action: 'Model Approved',
                    user: 'jane.smith@example.com',
                    timestamp: '2024-11-04 09:15:22',
                    details: 'Approved after reviewing evaluation metrics',
                  ),
                  _AuditEntry(
                    action: 'Training Completed',
                    user: 'system',
                    timestamp: '2024-11-04 08:42:10',
                    details: 'Training job completed successfully',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Compliance Checks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compliance Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _ComplianceItem(
                          name: 'GDPR',
                          status: 'Compliant',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        _ComplianceItem(
                          name: 'HIPAA',
                          status: 'Compliant',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        _ComplianceItem(
                          name: 'SOC 2',
                          status: 'In Progress',
                          icon: Icons.pending,
                          color: Colors.orange,
                        ),
                        _ComplianceItem(
                          name: 'ISO 27001',
                          status: 'Compliant',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Lineage',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _LineageNode(label: 'Raw Data', icon: Icons.source),
                        _LineageConnector(),
                        _LineageNode(
                          label: 'Cleaned Data',
                          icon: Icons.cleaning_services,
                        ),
                        _LineageConnector(),
                        _LineageNode(
                          label: 'Training Dataset',
                          icon: Icons.dataset,
                        ),
                        _LineageConnector(),
                        _LineageNode(
                          label: 'Trained Model',
                          icon: Icons.model_training,
                        ),
                        _LineageConnector(),
                        _LineageNode(
                          label: 'Deployed Model',
                          icon: Icons.rocket_launch,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditEntry extends StatelessWidget {
  final String action;
  final String user;
  final String timestamp;
  final String details;

  const _AuditEntry({
    required this.action,
    required this.user,
    required this.timestamp,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action, style: TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  details,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      user,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      timestamp,
                      style: TextStyle(fontSize: 11, color: Colors.grey),
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
}

class _ComplianceItem extends StatelessWidget {
  final String name;
  final String status;
  final IconData icon;
  final Color color;

  const _ComplianceItem({
    required this.name,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(status, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _LineageNode extends StatelessWidget {
  final String label;
  final IconData icon;

  const _LineageNode({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _LineageConnector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Container(
            width: 2,
            height: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

// Cost Analysis Tab
class _CostAnalysisTab extends StatelessWidget {
  const _CostAnalysisTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cost Analysis & Optimization',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Cost Overview
          Row(
            children: [
              Expanded(
                child: _CostCard(
                  title: 'This Month',
                  amount: '\$2,847',
                  change: '+12%',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CostCard(
                  title: 'Training',
                  amount: '\$1,234',
                  change: '+8%',
                  icon: Icons.model_training,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CostCard(
                  title: 'Inference',
                  amount: '\$1,456',
                  change: '+15%',
                  icon: Icons.rocket_launch,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CostCard(
                  title: 'Storage',
                  amount: '\$157',
                  change: '+3%',
                  icon: Icons.storage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Cost Breakdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cost by Model',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _CostBreakdownRow(
                          name: 'Medical QA v2.0',
                          amount: '\$842',
                          percentage: 29.6,
                        ),
                        _CostBreakdownRow(
                          name: 'Legal Assistant v1.5',
                          amount: '\$645',
                          percentage: 22.7,
                        ),
                        _CostBreakdownRow(
                          name: 'Code Generator v3.0',
                          amount: '\$534',
                          percentage: 18.8,
                        ),
                        _CostBreakdownRow(
                          name: 'Customer Support v2.5',
                          amount: '\$456',
                          percentage: 16.0,
                        ),
                        _CostBreakdownRow(
                          name: 'Others',
                          amount: '\$370',
                          percentage: 13.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Optimization Tips',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _OptimizationTip(
                          icon: Icons.speed,
                          title: 'Use Model Quantization',
                          saving: 'Save ~40%',
                        ),
                        _OptimizationTip(
                          icon: Icons.compress,
                          title: 'Enable Request Batching',
                          saving: 'Save ~25%',
                        ),
                        _OptimizationTip(
                          icon: Icons.schedule,
                          title: 'Use Spot Instances',
                          saving: 'Save ~60%',
                        ),
                        _OptimizationTip(
                          icon: Icons.cached,
                          title: 'Implement Caching',
                          saving: 'Save ~15%',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Cost Projection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cost Projection',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      DropdownButton<String>(
                        value: 'Next 3 Months',
                        items:
                            [
                                  'Next Month',
                                  'Next 3 Months',
                                  'Next 6 Months',
                                  'Next Year',
                                ]
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s),
                                  ),
                                )
                                .toList(),
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    color: Colors.grey.shade100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Projected Cost: \$9,200',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Based on current usage trends',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CostCard extends StatelessWidget {
  final String title;
  final String amount;
  final String change;
  final IconData icon;

  const _CostCard({
    required this.title,
    required this.amount,
    required this.change,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.grey),
                Text(
                  change,
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostBreakdownRow extends StatelessWidget {
  final String name;
  final String amount;
  final double percentage;

  const _CostBreakdownRow({
    required this.name,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 13)),
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}

class _OptimizationTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String saving;

  const _OptimizationTip({
    required this.icon,
    required this.title,
    required this.saving,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green.shade100,
            child: Icon(icon, size: 16, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  saving,
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
