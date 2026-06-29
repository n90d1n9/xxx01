import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/agent/agent_type.dart';
import '../models/agent/ai_agent.dart';
import '../models/agent/analytics_agent.dart';
import '../models/agent/guardrail_agent.dart';
import '../models/agent/orchestrator_agent.dart';
import '../models/agent/planning_agent.dart';
import '../models/mcp/mcp_parameter.dart';
import '../models/mcp/mcp_tool.dart';
import '../services/mcp_tool_library.dart';

class AIAgentBuilderDialog extends ConsumerStatefulWidget {
  final AIAgent? existingAgent;

  const AIAgentBuilderDialog({super.key, this.existingAgent});

  @override
  ConsumerState<AIAgentBuilderDialog> createState() =>
      _AIAgentBuilderDialogState();
}

class _AIAgentBuilderDialogState extends ConsumerState<AIAgentBuilderDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AgentType _selectedType;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  List<AgentCapability> _selectedCapabilities = [];
  List<MCPTool> _selectedTools = [];
  Map<String, dynamic> _config = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedType = widget.existingAgent?.type ?? AgentType.custom;
    _nameController = TextEditingController(
      text: widget.existingAgent?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingAgent?.description ?? '',
    );

    if (widget.existingAgent != null) {
      _selectedCapabilities = widget.existingAgent!.capabilities;
      _selectedTools = widget.existingAgent!.tools;
      _config = Map.from(widget.existingAgent!.config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildTabView()),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Icon(_getAgentIcon(_selectedType)),
          const SizedBox(width: 12),
          const Text(
            'AI Agent Builder',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Basic', icon: Icon(Icons.info_outline, size: 16)),
        Tab(text: 'Capabilities', icon: Icon(Icons.star_outline, size: 16)),
        Tab(text: 'Tools', icon: Icon(Icons.build_outlined, size: 16)),
        Tab(
          text: 'Configuration',
          icon: Icon(Icons.settings_outlined, size: 16),
        ),
      ],
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildBasicTab(),
        _buildCapabilitiesTab(),
        _buildToolsTab(),
        _buildConfigurationTab(),
      ],
    );
  }

  Widget _buildBasicTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Agent Type', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildAgentTypeSelector(),
        const SizedBox(height: 24),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Agent Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.label),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.description),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        if (_selectedType != AgentType.custom) _buildAgentTypeDescription(),
      ],
    );
  }

  Widget _buildAgentTypeSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          AgentType.values.map((type) {
            final isSelected = _selectedType == type;
            return FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getAgentIcon(type), size: 16),
                  const SizedBox(width: 8),
                  Text(type.name),
                ],
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedType = type);
                  _applyAgentTypeDefaults(type);
                }
              },
            );
          }).toList(),
    );
  }

  Widget _buildAgentTypeDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getAgentIcon(_selectedType)),
                const SizedBox(width: 8),
                Text(
                  '${_selectedType.name} Agent',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_getAgentTypeDescription(_selectedType)),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilitiesTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Select Capabilities',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...AgentCapability.values.map((capability) {
          return CheckboxListTile(
            title: Text(capability.name),
            subtitle: Text(_getCapabilityDescription(capability)),
            value: _selectedCapabilities.contains(capability),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedCapabilities.add(capability);
                } else {
                  _selectedCapabilities.remove(capability);
                }
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildToolsTab() {
    final availableTools = MCPToolsLibrary.getBuiltInTools();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Select Tools',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${_selectedTools.length} selected',
                style: TextStyle(color: Theme.of(context).disabledColor),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: availableTools.length,
            itemBuilder: (context, index) {
              final tool = availableTools[index];
              final isSelected = _selectedTools.any((t) => t.id == tool.id);

              return Card(
                child: CheckboxListTile(
                  title: Text(tool.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tool.description),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: [
                          Chip(
                            label: Text(
                              tool.type.name,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: _getToolTypeColor(
                              tool.type,
                            ).withOpacity(0.2),
                          ),
                          if (tool.parameters.isNotEmpty)
                            Chip(
                              label: Text(
                                '${tool.parameters.length} params',
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedTools.add(tool);
                      } else {
                        _selectedTools.removeWhere((t) => t.id == tool.id);
                      }
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'Agent Configuration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),

        // Type-specific configuration
        if (_selectedType == AgentType.orchestrator)
          _buildOrchestratorConfig()
        else if (_selectedType == AgentType.planner)
          _buildPlannerConfig()
        else if (_selectedType == AgentType.analyzer)
          _buildAnalyzerConfig()
        else if (_selectedType == AgentType.guardrail)
          _buildGuardrailConfig()
        else
          _buildGenericConfig(),
      ],
    );
  }

  Widget _buildOrchestratorConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Orchestration Type'),
        const SizedBox(height: 8),
        DropdownButtonFormField<OrchestrationType>(
          value:
              _config['orchestrationType'] as OrchestrationType? ??
              OrchestrationType.sequential,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              OrchestrationType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
          onChanged: (value) {
            setState(() => _config['orchestrationType'] = value);
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Stop on Error'),
          value: _config['stopOnError'] ?? true,
          onChanged: (value) {
            setState(() => _config['stopOnError'] = value);
          },
        ),
      ],
    );
  }

  Widget _buildPlannerConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Planning Strategy'),
        const SizedBox(height: 8),
        DropdownButtonFormField<PlanningStrategy>(
          value:
              _config['strategy'] as PlanningStrategy? ??
              PlanningStrategy.goalBased,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              PlanningStrategy.values.map((strategy) {
                return DropdownMenuItem(
                  value: strategy,
                  child: Text(strategy.name),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => _config['strategy'] = value);
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Max Steps',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final maxSteps = int.tryParse(value);
            if (maxSteps != null) {
              _config['maxSteps'] = maxSteps;
            }
          },
        ),
      ],
    );
  }

  Widget _buildAnalyzerConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analysis Type'),
        const SizedBox(height: 8),
        DropdownButtonFormField<AnalysisType>(
          value:
              _config['analysisType'] as AnalysisType? ??
              AnalysisType.descriptive,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              AnalysisType.values.map((type) {
                return DropdownMenuItem(value: type, child: Text(type.name));
              }).toList(),
          onChanged: (value) {
            setState(() => _config['analysisType'] = value);
          },
        ),
      ],
    );
  }

  Widget _buildGuardrailConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Guardrail Mode'),
        const SizedBox(height: 8),
        DropdownButtonFormField<GuardrailMode>(
          value: _config['mode'] as GuardrailMode? ?? GuardrailMode.moderate,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              GuardrailMode.values.map((mode) {
                return DropdownMenuItem(value: mode, child: Text(mode.name));
              }).toList(),
          onChanged: (value) {
            setState(() => _config['mode'] = value);
          },
        ),
        const SizedBox(height: 16),
        const Text('Action on Violation'),
        const SizedBox(height: 8),
        DropdownButtonFormField<ActionOnViolation>(
          value:
              _config['violationAction'] as ActionOnViolation? ??
              ActionOnViolation.warn,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items:
              ActionOnViolation.values.map((action) {
                return DropdownMenuItem(
                  value: action,
                  child: Text(action.name),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => _config['violationAction'] = value);
          },
        ),
      ],
    );
  }

  Widget _buildGenericConfig() {
    return const Text(
      'No specific configuration required for this agent type.',
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
            onPressed: _testAgent,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Test Agent'),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveAgent,
                child: const Text('Create Agent'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getAgentIcon(AgentType type) {
    switch (type) {
      case AgentType.orchestrator:
        return Icons.hub;
      case AgentType.planner:
        return Icons.calendar_view_day;
      case AgentType.executor:
        return Icons.play_arrow;
      case AgentType.analyzer:
        return Icons.analytics;
      case AgentType.guardrail:
        return Icons.shield;
      case AgentType.transformer:
        return Icons.transform;
      case AgentType.validator:
        return Icons.check_circle;
      case AgentType.monitor:
        return Icons.monitor_heart;
      case AgentType.custom:
        return Icons.extension;
    }
  }

  String _getAgentTypeDescription(AgentType type) {
    switch (type) {
      case AgentType.orchestrator:
        return 'Coordinates multiple agents and manages workflow execution';
      case AgentType.planner:
        return 'Decomposes complex tasks and creates execution plans';
      case AgentType.analyzer:
        return 'Analyzes data and generates insights';
      case AgentType.guardrail:
        return 'Enforces safety rules and validates outputs';
      case AgentType.transformer:
        return 'Transforms data between formats';
      case AgentType.validator:
        return 'Validates data against schemas and rules';
      case AgentType.monitor:
        return 'Monitors system performance and health';
      case AgentType.executor:
        return 'Executes tasks and actions';
      case AgentType.custom:
        return 'Custom agent with user-defined behavior';
    }
  }

  String _getCapabilityDescription(AgentCapability capability) {
    switch (capability) {
      case AgentCapability.planning:
        return 'Can create execution plans';
      case AgentCapability.reasoning:
        return 'Can reason about problems';
      case AgentCapability.execution:
        return 'Can execute actions';
      case AgentCapability.validation:
        return 'Can validate data and rules';
      case AgentCapability.transformation:
        return 'Can transform data';
      case AgentCapability.analysis:
        return 'Can analyze information';
      case AgentCapability.monitoring:
        return 'Can monitor systems';
      case AgentCapability.orchestration:
        return 'Can orchestrate workflows';
      case AgentCapability.toolUse:
        return 'Can use external tools';
      case AgentCapability.memory:
        return 'Has persistent memory';
      case AgentCapability.learning:
        return 'Can learn from experience';
    }
  }

  Color _getToolTypeColor(MCPToolType type) {
    switch (type) {
      case MCPToolType.http:
        return Colors.blue;
      case MCPToolType.database:
        return Colors.green;
      case MCPToolType.fileSystem:
        return Colors.orange;
      case MCPToolType.ai:
        return Colors.purple;
      case MCPToolType.integration:
        return Colors.teal;
      case MCPToolType.custom:
        return Colors.grey;
    }
  }

  void _applyAgentTypeDefaults(AgentType type) {
    setState(() {
      _selectedCapabilities = _getDefaultCapabilities(type);
      _config = _getDefaultConfig(type);
    });
  }

  List<AgentCapability> _getDefaultCapabilities(AgentType type) {
    switch (type) {
      case AgentType.orchestrator:
        return [
          AgentCapability.orchestration,
          AgentCapability.planning,
          AgentCapability.execution,
        ];
      case AgentType.planner:
        return [AgentCapability.planning, AgentCapability.reasoning];
      case AgentType.analyzer:
        return [AgentCapability.analysis, AgentCapability.reasoning];
      case AgentType.guardrail:
        return [AgentCapability.validation, AgentCapability.monitoring];
      default:
        return [];
    }
  }

  Map<String, dynamic> _getDefaultConfig(AgentType type) {
    switch (type) {
      case AgentType.orchestrator:
        return {
          'orchestrationType': OrchestrationType.sequential,
          'stopOnError': true,
        };
      case AgentType.planner:
        return {'strategy': PlanningStrategy.goalBased, 'maxSteps': 10};
      case AgentType.analyzer:
        return {'analysisType': AnalysisType.descriptive};
      case AgentType.guardrail:
        return {
          'mode': GuardrailMode.moderate,
          'violationAction': ActionOnViolation.warn,
        };
      default:
        return {};
    }
  }

  void _testAgent() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Test Agent'),
            content: const Text(
              'Agent testing feature coming soon.\n\n'
              'You will be able to test the agent with sample data.',
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

  void _saveAgent() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter agent name')));
      return;
    }

    // Create agent based on type
    // For now, return configuration
    Navigator.pop(context, {
      'type': _selectedType,
      'name': _nameController.text,
      'description': _descriptionController.text,
      'capabilities': _selectedCapabilities,
      'tools': _selectedTools,
      'config': _config,
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
