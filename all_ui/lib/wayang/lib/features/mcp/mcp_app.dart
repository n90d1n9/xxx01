// Main App
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/mcp_manage_screen.dart';
import 'widget/mcp_manage_hub.dart';

void main() {
  runApp(const ProviderScope(child: MCPServerManagementApp()));
}

class MCPServerManagementApp extends StatelessWidget {
  const MCPServerManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP  Management ',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MCPManagementHub(),
    );
  }
}


/* 
void main() {
  runApp(
    const ProviderScope(
      child: MCPServerManagementApp(),
    ),
  );
}

class MCPServerManagementApp extends StatelessWidget {
  const MCPServerManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP Server & Tools Registry',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const MCPManagementHub(),
    );
  }
}
 */