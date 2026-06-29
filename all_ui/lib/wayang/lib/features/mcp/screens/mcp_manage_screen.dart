import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/mcp_provider.dart';
import '../widget/api_documentation_panel.dart';
import '../widget/docker_deployment_panel.dart';
import '../widget/oauth2_config_panel.dart';
import '../widget/pipelines_panel.dart';
import '../widget/prompt_template_panel.dart';
import '../widget/resource_panel.dart';
import '../widget/security_audit_panel.dart';
import '../widget/testing_panel.dart';
import 'dashboard_overview.dart';
import 'monitoring_dashboard.dart';

class MCPManagementScreen extends ConsumerWidget {
  const MCPManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.dashboard),
            SizedBox(width: 12),
            Text('MCP  Management Hub'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(context, ref, selectedTab),
          // Main Content
          Expanded(child: _buildMainContent(selectedTab)),
        ],
      ),
    );
  }

  Widget _buildMainContent(String tab) {
    switch (tab) {
      case 'monitoring':
        return const MonitoringDashboard();
      case 'security':
        return const SecurityAuditPanel();
      case 'prompts':
        return const PromptTemplatesPanel();
      case 'docker':
        return const DockerDeploymentPanel();
      case 'testing':
        return const TestingPanel();
      case 'pipelines':
        return const PipelinesPanel();
      case 'oauth':
        return const OAuth2ConfigPanel();
      case 'api-docs':
        return const APIDocumentationPanel();
      case 'resources':
        return const ResourcesPanel();
      default:
        return const DashboardOverview();
    }
  }

  Widget _buildSidebar(
    BuildContext context,
    WidgetRef ref,
    String selectedTab,
  ) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Error Analytics (24h)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildErrorRow('500 Server Error', 12, Colors.red),
            _buildErrorRow('401 Unauthorized', 45, Colors.orange),
            _buildErrorRow('404 Not Found', 23, Colors.yellow),
            _buildErrorRow('429 Rate Limited', 8, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
