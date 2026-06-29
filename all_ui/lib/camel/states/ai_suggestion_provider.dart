import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_suggestion.dart';
import 'select_route_provider.dart';

final aiSuggestionsProvider = Provider<List<AISuggestion>>((ref) {
  final route = ref.watch(selectedRouteProvider);
  if (route == null || route.nodes.isEmpty) return [];

  final suggestions = <AISuggestion>[];

  // Check for missing error handling
  final hasErrorHandler = route.nodes.any(
    (n) =>
        n.type.contains('log') &&
        n.config.toString().toLowerCase().contains('error'),
  );

  if (!hasErrorHandler && route.nodes.length > 3) {
    suggestions.add(
      AISuggestion(
        id: 'error-handler',
        title: 'Add Error Handling',
        description:
            'Your route could benefit from explicit error handling to improve reliability',
        category: 'reliability',
        action: () {},
        icon: Icons.error_outline,
        priority: 5,
      ),
    );
  }

  // Check for logging
  final hasLogging = route.nodes.any((n) => n.type == 'log');
  if (!hasLogging) {
    suggestions.add(
      AISuggestion(
        id: 'add-logging',
        title: 'Add Logging',
        description: 'Add log nodes for better observability and debugging',
        category: 'best-practice',
        action: () {},
        icon: Icons.article,
        priority: 3,
      ),
    );
  }

  // Check for performance optimization
  if (route.nodes.length > 10) {
    suggestions.add(
      AISuggestion(
        id: 'parallel-processing',
        title: 'Consider Parallel Processing',
        description:
            'Large route detected. Consider adding parallel processing for better performance',
        category: 'performance',
        action: () {},
        icon: Icons.speed,
        priority: 4,
      ),
    );
  }

  // Check for data transformation
  final hasTransform = route.nodes.any(
    (n) => n.type == 'transform' || n.type == 'marshal',
  );
  if (!hasTransform && route.nodes.length > 2) {
    suggestions.add(
      AISuggestion(
        id: 'data-transform',
        title: 'Data Transformation',
        description:
            'Consider adding data transformation for better integration',
        category: 'best-practice',
        action: () {},
        icon: Icons.transform,
        priority: 2,
      ),
    );
  }

  // Check for rate limiting
  final hasRateLimit = route.nodes.any((n) => n.type == 'throttle');
  if (!hasRateLimit &&
      route.nodes.any((n) => n.type == 'rest' || n.type == 'kafka')) {
    suggestions.add(
      AISuggestion(
        id: 'rate-limiting',
        title: 'Add Rate Limiting',
        description:
            'Protect your endpoints with rate limiting to prevent overload',
        category: 'reliability',
        action: () {},
        icon: Icons.shield,
        priority: 4,
      ),
    );
  }

  // Sort by priority
  suggestions.sort((a, b) => b.priority.compareTo(a.priority));

  return suggestions;
});
