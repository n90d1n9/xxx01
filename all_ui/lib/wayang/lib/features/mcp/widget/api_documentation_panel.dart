import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class APIDocumentationPanel extends ConsumerWidget {
  const APIDocumentationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'API Documentation',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export OpenAPI'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new),
                label: const Text('Swagger UI'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEndpointsCard(context),
          const SizedBox(height: 24),
          _buildExamplesCard(context),
        ],
      ),
    );
  }

  Widget _buildEndpointsCard(BuildContext context) {
    final endpoints = [
      ('GET', '/api/tools', 'List all available tools'),
      ('POST', '/api/tools/execute', 'Execute a tool'),
      ('GET', '/api/resources', 'List resources'),
      ('GET', '/api/prompts', 'List prompt templates'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Endpoints',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...endpoints.map((endpoint) {
              final (method, path, description) = endpoint;
              return _buildEndpointRow(context, method, path, description);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointRow(
    BuildContext context,
    String method,
    String path,
    String description,
  ) {
    final methodColor = method == 'GET'
        ? Colors.blue
        : method == 'POST'
        ? Colors.green
        : method == 'PUT'
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: methodColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildExamplesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code Examples',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildExampleTab(context, 'cURL'),
            const SizedBox(height: 12),
            _buildExampleTab(context, 'Python'),
            const SizedBox(height: 12),
            _buildExampleTab(context, 'JavaScript'),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleTab(BuildContext context, String language) {
    final examples = {
      'cURL': '''curl -X GET https://api.example.com/api/tools \\
  -H "Authorization: Bearer YOUR_TOKEN" \\
  -H "Content-Type: application/json"''',
      'Python': '''import requests

headers = {"Authorization": "Bearer YOUR_TOKEN"}
response = requests.get("https://api.example.com/api/tools", headers=headers)
print(response.json())''',
      'JavaScript':
          '''const response = await fetch("https://api.example.com/api/tools", {
  method: "GET",
  headers: {
    "Authorization": "Bearer YOUR_TOKEN",
    "Content-Type": "application/json"
  }
});
const data = await response.json();''',
    };

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Text(
                  language,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade900,
            child: SelectableText(
              examples[language] ?? '',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
