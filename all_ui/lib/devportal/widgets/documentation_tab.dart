import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentationTab extends ConsumerWidget {
  const DocumentationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            child: TabBar(
              tabs: const [
                Tab(text: 'Getting Started'),
                Tab(text: 'API Reference'),
                Tab(text: 'Guides'),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface,
              indicatorColor: theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildGettingStartedTab(context),
                _buildApiReferenceTab(context, ref),
                _buildGuidesTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStartedTab(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to the Developer Portal',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Follow these steps to get started with our API:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          _buildStepCard(
            context,
            number: 1,
            title: 'Create a Project',
            description:
                'Navigate to the Projects tab and create a new project to organize your API keys and usage.',
            icon: Icons.create_new_folder,
          ),

          _buildStepCard(
            context,
            number: 2,
            title: 'Generate API Keys',
            description:
                'Create API keys within your project to authenticate your API requests.',
            icon: Icons.vpn_key,
          ),

          _buildStepCard(
            context,
            number: 3,
            title: 'Make Your First Request',
            description:
                'Use the code examples below to make your first API request.',
            icon: Icons.code,
          ),

          const SizedBox(height: 32),

          Text('Code Examples', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),

          _buildCodeExample(
            context,
            language: 'curl',
            code: '''
curl -X GET "https://api.example.com/v1/data" \\
  -H "Authorization: Bearer YOUR_API_KEY" \\
  -H "Content-Type: application/json"
''',
          ),

          const SizedBox(height: 16),

          _buildCodeExample(
            context,
            language: 'Python',
            code: '''
import requests

headers = {
    "Authorization": "Bearer YOUR_API_KEY",
    "Content-Type": "application/json"
}

response = requests.get("https://api.example.com/v1/data", headers=headers)
data = response.json()
print(data)
''',
          ),

          const SizedBox(height: 16),

          _buildCodeExample(
            context,
            language: 'JavaScript',
            code: '''
fetch('https://api.example.com/v1/data', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY',
    'Content-Type': 'application/json'
  }
})
.then(response => response.json())
.then(data => console.log(data))
.catch(error => console.error('Error:', error));
''',
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: theme.colorScheme.primary, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeExample(
    BuildContext context, {
    required String language,
    required String code,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(language, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                theme.brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: SelectableText(
            code,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              // Copy code to clipboard
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Code copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
          ),
        ),
      ],
    );
  }

  Widget _buildApiReferenceTab(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Placeholder for API endpoints
    final endpoints = [
      {
        'name': 'List Resources',
        'method': 'GET',
        'path': '/v1/resources',
        'description': 'Retrieve a list of all available resources',
      },
      {
        'name': 'Get Resource',
        'method': 'GET',
        'path': '/v1/resources/{id}',
        'description': 'Retrieve a specific resource by ID',
      },
      {
        'name': 'Create Resource',
        'method': 'POST',
        'path': '/v1/resources',
        'description': 'Create a new resource',
      },
      {
        'name': 'Update Resource',
        'method': 'PUT',
        'path': '/v1/resources/{id}',
        'description': 'Update an existing resource',
      },
      {
        'name': 'Delete Resource',
        'method': 'DELETE',
        'path': '/v1/resources/{id}',
        'description': 'Delete a resource',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('API Reference', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text(
            'Explore our API endpoints and learn how to use them.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: 'Search endpoints',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),

          const SizedBox(height: 24),

          // API endpoints list
          ...endpoints.map((endpoint) => _buildEndpointCard(context, endpoint)),
        ],
      ),
    );
  }

  Widget _buildEndpointCard(
    BuildContext context,
    Map<String, String> endpoint,
  ) {
    final theme = Theme.of(context);

    // Determine color based on HTTP method
    Color methodColor;
    switch (endpoint['method']) {
      case 'GET':
        methodColor = Colors.blue;
        break;
      case 'POST':
        methodColor = Colors.green;
        break;
      case 'PUT':
        methodColor = Colors.orange;
        break;
      case 'DELETE':
        methodColor = Colors.red;
        break;
      default:
        methodColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: methodColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                endpoint['method']!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                endpoint['path']!,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(endpoint['name']!, style: theme.textTheme.bodyMedium),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  endpoint['description']!,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text('Request Parameters', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildParametersTable(context),
                const SizedBox(height: 16),
                Text('Response', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildCodeExample(
                  context,
                  language: 'JSON',
                  code: '''
{
  "id": "resource-123",
  "name": "Example Resource",
  "created_at": "2023-07-15T10:30:00Z",
  "status": "active",
  "properties": {
    "key1": "value1",
    "key2": "value2"
  }
}
''',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParametersTable(BuildContext context) {
    final theme = Theme.of(context);

    // Sample parameters
    final parameters = [
      {
        'name': 'id',
        'type': 'string',
        'required': true,
        'description': 'Unique identifier for the resource',
      },
      {
        'name': 'name',
        'type': 'string',
        'required': true,
        'description': 'Name of the resource',
      },
      {
        'name': 'status',
        'type': 'string',
        'required': false,
        'description': 'Status of the resource (active, inactive, pending)',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows:
              parameters
                  .map(
                    (param) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            param['name'].toString(),
                            style: TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                        DataCell(Text(param['type'].toString())),
                        DataCell(
                          Text(
                            param['required'] == true ? 'Yes' : 'No',
                            style: TextStyle(
                              color:
                                  param['required'] == true
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                            ),
                          ),
                        ),
                        DataCell(Text(param['description'].toString())),
                      ],
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildGuidesTab(BuildContext context) {
    final theme = Theme.of(context);

    // Sample guides
    final guides = [
      {
        'title': 'Authentication Guide',
        'description': 'Learn how to authenticate with our API using API keys',
        'icon': Icons.security,
      },
      {
        'title': 'Pagination',
        'description': 'How to work with paginated responses in our API',
        'icon': Icons.pages,
      },
      {
        'title': 'Error Handling',
        'description':
            'Best practices for handling API errors and status codes',
        'icon': Icons.error_outline,
      },
      {
        'title': 'Rate Limiting',
        'description':
            'Understanding rate limits and how to avoid exceeding them',
        'icon': Icons.speed,
      },
      {
        'title': 'Webhooks Setup',
        'description':
            'How to configure and use webhooks for real-time updates',
        'icon': Icons.webhook,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: guides.length,
      itemBuilder: (context, index) {
        final guide = guides[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // Navigate to guide details
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      guide['icon'] as IconData,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guide['title'] as String,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          guide['description'] as String,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
