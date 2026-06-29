// lib/src/batik.dart
//
// Batik Framework - Internal Barrel Export
// ============================================================
// This file exports all internal modules for use by the public API.
// Import this file from lib/batik.dart to expose the framework.
// ============================================================

// Schema - UI Node definitions and validation
export 'schema/ui_schema.dart';
export 'schema/schema_validator.dart' hide UIDiffEngine;

// Core - Fundamental interfaces and utilities
export 'core/registry.dart';
export 'core/action_dispatcher.dart';
export 'core/style_utils.dart';

// Adapters - Agent communication layer
export 'adapters/agent_adapter.dart';
export 'adapters/system_prompt_builder.dart';
export 'adapters/wayang_assistant_adapter.dart' hide ConversationTurn;
export 'adapters/wayang_assistant_websocket_adapter.dart';

// Renderer - UI rendering engine
export 'renderer/ui_renderer.dart' hide ActionDispatcher;
export 'renderer/virtual_list_renderer.dart';

// State - Riverpod state management
export 'state/agent_providers.dart'
    hide AgentMessage, DiffResult, UISchemaValidator, UIDiffEngine;

// Streaming - Real-time streaming support
export 'streaming/streaming_parser.dart';
export 'streaming/websocket_client.dart';
export 'streaming/websocket_agent_adapter.dart';

// Diff - Diff/patch engine for efficient updates
export 'diff/ui_diff_engine.dart';

// Animation - Animation system
export 'animation/animated_node_renderer.dart' hide SkeletonLoader;

// Widgets - High-level widgets
export 'widgets/agent_ui_chat.dart';
export 'widgets/multi_agent_orchestrator.dart';
export 'widgets/agent_tool_runner.dart';
export 'widgets/agent_localizations.dart';
export 'widgets/agent_inspector.dart';
export 'widgets/session_persistence.dart';
export 'widgets/agent_ui_theme.dart';
export 'widgets/skeleton_loader.dart';

// Components - Component builders
export 'components/builtin_components.dart';
export 'components/batik_components.dart';

// Theme - Theming system
export 'theme/batik_theme.dart';
export 'theme/batik_colors.dart';

// Plugin - Plugin system
export 'plugin/plugin_registry.dart';

// Utils - Utility classes and helpers
export 'utils/response_cache.dart';
export 'utils/semantics_builder.dart';
export 'utils/typed_actions.dart';
