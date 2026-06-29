import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentationTab extends ConsumerWidget {
  const DocumentationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = ref.watch(docCategoryProvider);
    final docData = ref.watch(documentationProvider);

    return docData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (error, stack) =>
              Center(child: Text('Error loading documentation: $error')),
      data:
          (docs) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left navigation sidebar
              Container(
                width: 240,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: isDarkMode ? Colors.white10 : Colors.black12,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search documentation...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:
                              isDarkMode
                                  ? const Color(0xFF2D2D42)
                                  : const Color(0xFFF5F5F5),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildCategoryHeader('Getting Started', isDarkMode),
                          _buildDocLink(
                            'Introduction',
                            'introduction',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Quick Start Guide',
                            'quick-start',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Authentication',
                            'authentication',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),

                          _buildCategoryHeader('API Reference', isDarkMode),
                          _buildDocLink(
                            'Authentication API',
                            'auth-api',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Data Processing API',
                            'data-api',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Storage API',
                            'storage-api',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Analytics API',
                            'analytics-api',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),

                          _buildCategoryHeader('Guides', isDarkMode),
                          _buildDocLink(
                            'API Rate Limiting',
                            'rate-limiting',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Error Handling',
                            'error-handling',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Webhooks',
                            'webhooks',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Security Best Practices',
                            'security',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),

                          _buildCategoryHeader('SDK', isDarkMode),
                          _buildDocLink(
                            'JavaScript SDK',
                            'js-sdk',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Python SDK',
                            'python-sdk',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'Android SDK',
                            'android-sdk',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                          _buildDocLink(
                            'iOS SDK',
                            'ios-sdk',
                            selectedCategory,
                            isDarkMode,
                            ref,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main content area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  docs.currentDoc.title,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  docs.currentDoc.description,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // API version selector for API reference pages
                          if (docs.currentDoc.id.contains('-api'))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      isDarkMode
                                          ? Colors.white24
                                          : Colors.black12,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'API Version:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  DropdownButton<String>(
                                    value: 'v1',
                                    isDense: true,
                                    underline: const SizedBox(),
                                    items:
                                        ['v1', 'v2-beta'].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {},
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Document content
                      ...docs.currentDoc.sections.map(
                        (section) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              section.content,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),

                            // Code sample if available
                            if (section.codeSample != null)
                              _buildCodeSample(
                                section.codeSample!,
                                isDarkMode,
                                context,
                              ),

                            // Request/Response examples for API reference
                            if (section.requestExample != null &&
                                section.responseExample != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildExampleBlock(
                                          'Request',
                                          section.requestExample!,
                                          isDarkMode,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: _buildExampleBlock(
                                          'Response',
                                          section.responseExample!,
                                          isDarkMode,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                            // Parameters table for API endpoints
                            if (section.parameters != null &&
                                section.parameters!.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  Text(
                                    'Parameters',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildParametersTable(
                                    section.parameters!,
                                    isDarkMode,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 64),

                      // Document footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (docs.prevDocId != null)
                            TextButton.icon(
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Previous'),
                              onPressed:
                                  () =>
                                      ref
                                          .read(docCategoryProvider.notifier)
                                          .state = docs.prevDocId!,
                            )
                          else
                            const SizedBox(),

                          if (docs.nextDocId != null)
                            TextButton.icon(
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Next'),
                              onPressed:
                                  () =>
                                      ref
                                          .read(docCategoryProvider.notifier)
                                          .state = docs.nextDocId!,
                              style: TextButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const SizedBox(),
                        ],
                      ),

                      const SizedBox(height: 32),
                      Divider(
                        color: isDarkMode ? Colors.white12 : Colors.black12,
                      ),
                      const SizedBox(height: 32),

                      // Feedback section
                      Text(
                        'Was this helpful?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.thumb_up),
                            label: const Text('Yes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.thumb_down),
                            label: const Text('No'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildCategoryHeader(String title, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black45,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDocLink(
    String title,
    String id,
    String selectedId,
    bool isDarkMode,
    WidgetRef ref,
  ) {
    final isSelected = id == selectedId;
    return InkWell(
      onTap: () => ref.read(docCategoryProvider.notifier).state = id,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (isDarkMode
                      ? const Color(0xFF3A3A5A)
                      : const Color(0xFFE0E7FF))
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color:
                isSelected
                    ? (isDarkMode ? Colors.white : Colors.black87)
                    : (isDarkMode ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeSample(String code, bool isDarkMode, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF1E1E2D) : const Color(0xFFF0F0F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Example',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_copy, size: 18),
                      tooltip: 'Copy to clipboard',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? const Color(0xFF121218)
                          : const Color(0xFFE8E8F0),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: SelectableText(
                  code,
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExampleBlock(String title, String content, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode ? const Color(0xFF1E1E2D) : const Color(0xFFF0F0F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParametersTable(
    List<ParameterData> parameters,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? const Color(0xFF2D2D42)
                      : const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Parameter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Required',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Parameter rows
          ...parameters.map(
            (param) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDarkMode ? Colors.white10 : Colors.black12,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      param.name,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? const Color(0xFF272738)
                                : const Color(0xFFEDEDF5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        param.type,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child:
                        param.isRequired
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            )
                            : const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                              size: 18,
                            ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      param.description,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
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

// Models for Documentation
class DocumentationData {
  final DocumentModel currentDoc;
  final String? prevDocId;
  final String? nextDocId;

  DocumentationData({required this.currentDoc, this.prevDocId, this.nextDocId});
}

class DocumentModel {
  final String id;
  final String title;
  final String description;
  final List<DocumentSection> sections;

  DocumentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sections,
  });
}

class DocumentSection {
  final String title;
  final String content;
  final String? codeSample;
  final String? requestExample;
  final String? responseExample;
  final List<ParameterData>? parameters;

  DocumentSection({
    required this.title,
    required this.content,
    this.codeSample,
    this.requestExample,
    this.responseExample,
    this.parameters,
  });
}

class ParameterData {
  final String name;
  final String type;
  final bool isRequired;
  final String description;

  ParameterData({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.description,
  });
}

// Providers
final docCategoryProvider = StateProvider<String>((ref) => 'introduction');

final documentationProvider = FutureProvider<DocumentationData>((ref) {
  final selectedCategory = ref.watch(docCategoryProvider);

  // In a real app, this would fetch data from an API or local storage
  // Here we're simulating a network request
  return Future.delayed(const Duration(milliseconds: 500), () {
    return _getMockDocumentationData(selectedCategory, '');
  });
});

// Mock data generator for documentation
DocumentationData _getMockDocumentationData(String docId, dynamic job) {
  // Find previous and next document IDs for navigation
  final allDocIds = [
    'introduction',
    'quick-start',
    'authentication',
    'auth-api',
    'data-api',
    'storage-api',
    'analytics-api',
    'rate-limiting',
    'error-handling',
    'webhooks',
    'security',
    'js-sdk',
    'python-sdk',
    'android-sdk',
    'ios-sdk',
  ];

  final currentIndex = allDocIds.indexOf(docId);
  final prevDocId = currentIndex > 0 ? allDocIds[currentIndex - 1] : null;
  final nextDocId =
      currentIndex < allDocIds.length - 1 ? allDocIds[currentIndex + 1] : null;

  // Return mock data based on the selected document ID
  switch (docId) {
    case 'introduction':
      return DocumentationData(
        currentDoc: DocumentModel(
          id: 'introduction',
          title: 'Introduction',
          description:
              'Welcome to our API documentation. Learn how to integrate our services into your application.',
          sections: [
            DocumentSection(
              title: 'Overview',
              content:
                  'Our platform provides a comprehensive suite of APIs to help you build powerful applications. These APIs enable you to authenticate users, process data, store files, and analyze usage patterns with ease.',
            ),
            DocumentSection(
              title: 'Core Concepts',
              content:
                  'Before diving into the technical details, it\'s important to understand a few core concepts that apply across our platform.',
              codeSample: '''
// All API requests require authentication
const client = new ApiClient({
  apiKey: 'YOUR_API_KEY',
  environment: 'production'
});

// Resources are identified by unique IDs
const response = await client.resource.get('resource_id');
              ''',
            ),
          ],
        ),
        prevDocId: prevDocId,
        nextDocId: nextDocId,
      );

    case 'data-api':
      return DocumentationData(
        currentDoc: DocumentModel(
          id: 'data-api',
          title: 'Data Processing API',
          description:
              'Process, transform, and analyze your data using our powerful data processing API.',
          sections: [
            DocumentSection(
              title: 'Creating a Processing Job',
              content:
                  'To start processing data, create a processing job by sending a POST request to the /data/jobs endpoint.',
              requestExample: '''
POST /api/v1/data/jobs HTTP/1.1
Host: api.example.com
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "name": "Daily Analytics",
  "source": "s3://mybucket/data.csv",
  "destination": "s3://mybucket/processed/",
  "transformations": ["normalize", "aggregate"]
}''',
              responseExample: '''
HTTP/1.1 201 Created
Content-Type: application/json

{
  "job_id": "job_123abc",
  "status": "queued",
  "created_at": "2023-09-21T14:32:10Z",
  "estimated_completion": "2023-09-21T14:35:10Z"
}''',
              parameters: [
                ParameterData(
                  name: 'name',
                  type: 'string',
                  isRequired: true,
                  description: 'A descriptive name for the processing job',
                ),
                ParameterData(
                  name: 'source',
                  type: 'string',
                  isRequired: true,
                  description: 'URI pointing to the source data',
                ),
                ParameterData(
                  name: 'destination',
                  type: 'string',
                  isRequired: true,
                  description: 'URI where processed data should be stored',
                ),
                ParameterData(
                  name: 'transformations',
                  type: 'array',
                  isRequired: false,
                  description: 'List of transformations to apply to the data',
                ),
              ],
            ),
            DocumentSection(
              title: 'Checking Job Status',
              content:
                  'Monitor the status of your processing jobs by sending a GET request to the /data/jobs/{job_id} endpoint.',
              codeSample: '''
// Using our JavaScript SDK
const job = await client.data.getJob('job_123abc');
console.log(`Job status: ${job.status}`);

// Poll until job is complete
while (job.status !== 'completed') {
  await new Promise(resolve => setTimeout(resolve, 5000));
  await job.refresh();
}
              ''',
            ),
          ],
        ),
        prevDocId: prevDocId,
        nextDocId: nextDocId,
      );

    // Add more document cases here...

    default:
      // Return a placeholder for other document IDs
      return DocumentationData(
        currentDoc: DocumentModel(
          id: docId,
          title: docId
              .split('-')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' '),
          description:
              'Documentation for ${docId.split('-').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ')}',
          sections: [
            DocumentSection(
              title: 'Coming Soon',
              content:
                  'This documentation section is currently being developed. Please check back soon for updates.',
            ),
          ],
        ),
        prevDocId: prevDocId,
        nextDocId: nextDocId,
      );
  }
}
