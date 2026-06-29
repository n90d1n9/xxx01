// Sample data generators
import 'model/audit_action.dart';
import 'model/deployment_pipeline.dart';
import 'model/deployment_status.dart';
import 'model/health_check.dart';
import 'model/health_status.dart';
import 'model/mc_resource_indicator.dart';
import 'model/mcp_environment.dart';
import 'model/mcp_security_audit.dart';
import 'model/pipeline_stage.dart';
import 'model/prompt_category.dart';
import 'model/prompt_template.dart';
import 'model/test_case.dart';
import 'model/test_result.dart';

List<MCPSecurityAudit> generateSampleAuditLogs() {
  return [
    MCPSecurityAudit(
      id: 'audit-1',
      serverId: '1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      action: MCPAuditAction.toolExecuted,
      userId: 'user@example.com',
      details: 'Tool: JSON Transformer executed successfully',
      success: true,
    ),
    MCPSecurityAudit(
      id: 'audit-2',
      serverId: '1',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      action: MCPAuditAction.authorizationDenied,
      userId: 'user2@example.com',
      details: 'Attempted access to restricted resource',
      success: false,
      errorMessage: 'Insufficient permissions',
    ),
    MCPSecurityAudit(
      id: 'audit-3',
      serverId: '1',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      action: MCPAuditAction.configurationChanged,
      userId: 'admin@example.com',
      details: 'Server configuration updated: TLS enabled',
      success: true,
    ),
  ];
}

List<MCPPromptTemplate> generateSamplePrompts() {
  return [
    MCPPromptTemplate(
      id: 'prompt-1',
      name: 'Chain of Thought Reasoning',
      description: 'Multi-step reasoning template for complex problems',
      template: 'Think step by step:\n1. {{step1}}\n2. {{step2}}\n3. {{step3}}',
      requiredVariables: ['step1', 'step2', 'step3'],
      category: MCPPromptCategory.chainOfThought,
      author: 'MCP Team',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      usageCount: 234,
      isPublic: true,
      tags: ['reasoning', 'problem-solving'],
    ),
    MCPPromptTemplate(
      id: 'prompt-2',
      name: 'Few-Shot Classification',
      description: 'Template for classification with examples',
      template: 'Examples:\n{{example1}}\n{{example2}}\nClassify: {{input}}',
      requiredVariables: ['example1', 'example2', 'input'],
      category: MCPPromptCategory.fewShot,
      author: 'ML Team',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      usageCount: 456,
      isPublic: true,
      tags: ['classification', 'examples'],
    ),
  ];
}

List<MCPHealthCheck> generateSampleHealthChecks() {
  return [
    MCPHealthCheck(
      serverId: '1',
      timestamp: DateTime.now(),
      status: MCPHealthStatus.healthy,
      responseTime: 45,
      cpuUsage: 15.5,
      memoryUsage: 256.8,
      activeConnections: 5,
    ),
    MCPHealthCheck(
      serverId: '2',
      timestamp: DateTime.now(),
      status: MCPHealthStatus.healthy,
      responseTime: 32,
      cpuUsage: 45.2,
      memoryUsage: 1024.5,
      activeConnections: 127,
    ),
  ];
}

List<MCPTestCase> generateSampleTestCases() {
  return [
    MCPTestCase(
      id: 'test-1',
      name: 'JSON Validation Test',
      description: 'Test JSON transformer with valid input',
      toolId: 'tool-1',
      inputData: {'data': '{"name": "test"}', 'validate': true},
      expectedOutput: {'valid': true, 'errors': []},
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      isAutomated: true,
      lastResult: MCPTestResult(
        testCaseId: 'test-1',
        passed: true,
        executedAt: DateTime.now().subtract(const Duration(hours: 2)),
        executionTime: 125,
      ),
    ),
    MCPTestCase(
      id: 'test-2',
      name: 'Invalid JSON Handling',
      description: 'Test JSON transformer with invalid input',
      toolId: 'tool-1',
      inputData: {'data': '{invalid json}', 'validate': true},
      expectedOutput: {
        'valid': false,
        'errors': ['Invalid JSON format'],
      },
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      isAutomated: true,
      lastResult: MCPTestResult(
        testCaseId: 'test-2',
        passed: true,
        executedAt: DateTime.now().subtract(const Duration(hours: 3)),
        executionTime: 98,
      ),
    ),
  ];
}

List<MCPDeploymentPipeline> generateSamplePipelines() {
  return [
    MCPDeploymentPipeline(
      id: 'pipeline-1',
      name: 'Production Deployment',
      stages: [
        MCPPipelineStage(
          name: 'Build',
          environment: MCPEnvironment.development,
          steps: ['npm install', 'npm test', 'docker build'],
          autoExecute: true,
        ),
        MCPPipelineStage(
          name: 'Deploy to Staging',
          environment: MCPEnvironment.staging,
          steps: ['helm upgrade staging', 'run-smoke-tests'],
          requiresApproval: false,
          autoExecute: true,
        ),
        MCPPipelineStage(
          name: 'Deploy to Production',
          environment: MCPEnvironment.production,
          steps: ['helm upgrade prod', 'run-integration-tests'],
          requiresApproval: true,
          autoExecute: false,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      status: MCPDeploymentStatus.idle,
      gitRepository: 'https://github.com/org/mcp-server',
      cicdProvider: 'github-actions',
      lastDeployedVersion: 'v2.1.0',
    ),
  ];
}

List<MCPResourceIndicator> generateSampleResources() {
  return [
    MCPResourceIndicator(
      uri: 'file://data/users.json',
      scope: 'read',
      mimeType: 'application/json',
      size: 2048,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MCPResourceIndicator(
      uri: 'database://prod/users_table',
      scope: 'read,write',
      mimeType: 'application/sql',
      createdAt: DateTime.now(),
    ),
  ];
}
