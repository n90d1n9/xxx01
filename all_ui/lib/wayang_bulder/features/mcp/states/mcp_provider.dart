// State Management Providers
import 'package:flutter_riverpod/legacy.dart';

import '../dummy_mcp.dart';
import '../model/api_documentation.dart';
import '../model/deployment_pipeline.dart';
import '../model/health_check.dart';
import '../model/mc_resource_indicator.dart';
import '../model/mcp_registry_entry.dart';
import '../model/mcp_security_audit.dart';
import '../model/mcp_server.dart';
import '../model/mcp_tool.dart';
import '../model/prompt_template.dart';
import '../model/test_case.dart';

final selectedServerProvider = StateProvider<MCPServer?>((ref) => null);
final selectedToolProvider = StateProvider<MCPTool?>((ref) => null);
final selectedRegistryProvider = StateProvider<MCPRegistryEntry?>(
  (ref) => null,
);
final appTabProvider = StateProvider<int>((ref) => 0);

final auditLogsProvider = StateProvider<List<MCPSecurityAudit>>((ref) {
  return generateSampleAuditLogs();
});

final promptTemplatesProvider = StateProvider<List<MCPPromptTemplate>>((ref) {
  return generateSamplePrompts();
});

final healthChecksProvider = StateProvider<List<MCPHealthCheck>>((ref) {
  return generateSampleHealthChecks();
});

final testCasesProvider = StateProvider<List<MCPTestCase>>((ref) {
  return generateSampleTestCases();
});

final deploymentPipelinesProvider = StateProvider<List<MCPDeploymentPipeline>>((
  ref,
) {
  return generateSamplePipelines();
});

final apiDocumentationProvider = StateProvider<MCPAPIDocumentation?>(
  (ref) => null,
);

final resourcesProvider = StateProvider<List<MCPResourceIndicator>>((ref) {
  return generateSampleResources();
});

final selectedTabProvider = StateProvider<String>((ref) => 'dashboard');
