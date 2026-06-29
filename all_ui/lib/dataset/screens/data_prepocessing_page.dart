import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/provider.dart';

class DataPreparationPage extends ConsumerStatefulWidget {
  const DataPreparationPage({super.key});

  @override
  ConsumerState<DataPreparationPage> createState() =>
      _DataPreparationPageState();
}

class _DataPreparationPageState extends ConsumerState<DataPreparationPage> {
  bool enableCleaning = true;
  bool deduplication = true;
  bool shuffle = true;
  double trainTestSplit = 0.9;
  bool enableAugmentation = false;

  // Advanced Cleaning Options
  bool removeHtml = true;
  bool removeUrls = true;
  bool removeEmails = true;
  bool removeSpecialChars = false;
  bool normalizeWhitespace = true;
  bool removeEmptyLines = true;
  bool toLowerCase = false;
  bool removeNumbers = false;
  bool removePunctuation = false;
  bool fixEncoding = true;
  bool removeEmojis = false;
  bool expandContractions = false;

  // Text Normalization
  String unicodeNormalization = 'NFC';
  int minTextLength = 10;
  int maxTextLength = 10000;

  // Language Detection
  bool enableLanguageFilter = false;
  List<String> allowedLanguages = ['en'];

  // PII Removal
  bool removePII = false;
  bool maskEmails = false;
  bool maskPhoneNumbers = false;
  bool maskSSN = false;
  bool maskCreditCards = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Preparation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prepare and transform your dataset for training',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),

            // Data Source
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Source',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Dataset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Dataset: customer_support_v3.jsonl',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '15,432 samples • 45.2 MB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _previewRawData(context),
                            child: const Text('Preview'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Text Cleaning Options
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Text Cleaning & Normalization',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Switch(
                          value: enableCleaning,
                          onChanged: (v) => setState(() => enableCleaning = v),
                        ),
                      ],
                    ),
                    if (enableCleaning) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Basic Cleaning
                      Text(
                        'Basic Cleaning',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _CleaningOption(
                            label: 'Remove HTML Tags',
                            value: removeHtml,
                            onChanged: (v) => setState(() => removeHtml = v),
                            icon: Icons.code_off,
                          ),
                          _CleaningOption(
                            label: 'Remove URLs',
                            value: removeUrls,
                            onChanged: (v) => setState(() => removeUrls = v),
                            icon: Icons.link_off,
                          ),
                          _CleaningOption(
                            label: 'Remove Emails',
                            value: removeEmails,
                            onChanged: (v) => setState(() => removeEmails = v),
                            icon: Icons.email_outlined,
                          ),
                          _CleaningOption(
                            label: 'Normalize Whitespace',
                            value: normalizeWhitespace,
                            onChanged:
                                (v) => setState(() => normalizeWhitespace = v),
                            icon: Icons.space_bar,
                          ),
                          _CleaningOption(
                            label: 'Remove Empty Lines',
                            value: removeEmptyLines,
                            onChanged:
                                (v) => setState(() => removeEmptyLines = v),
                            icon: Icons.clear_all,
                          ),
                          _CleaningOption(
                            label: 'Fix Encoding Issues',
                            value: fixEncoding,
                            onChanged: (v) => setState(() => fixEncoding = v),
                            icon: Icons.text_fields,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Advanced Cleaning
                      Text(
                        'Advanced Options',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _CleaningOption(
                            label: 'Remove Special Characters',
                            value: removeSpecialChars,
                            onChanged:
                                (v) => setState(() => removeSpecialChars = v),
                            icon: Icons.highlight_remove,
                          ),
                          _CleaningOption(
                            label: 'Convert to Lowercase',
                            value: toLowerCase,
                            onChanged: (v) => setState(() => toLowerCase = v),
                            icon: Icons.text_format,
                          ),
                          _CleaningOption(
                            label: 'Remove Numbers',
                            value: removeNumbers,
                            onChanged: (v) => setState(() => removeNumbers = v),
                            icon: Icons.numbers,
                          ),
                          _CleaningOption(
                            label: 'Remove Punctuation',
                            value: removePunctuation,
                            onChanged:
                                (v) => setState(() => removePunctuation = v),
                            icon: Icons.question_mark,
                          ),
                          _CleaningOption(
                            label: 'Remove Emojis',
                            value: removeEmojis,
                            onChanged: (v) => setState(() => removeEmojis = v),
                            icon: Icons.emoji_emotions_outlined,
                          ),
                          _CleaningOption(
                            label: 'Expand Contractions',
                            value: expandContractions,
                            onChanged:
                                (v) => setState(() => expandContractions = v),
                            icon: Icons.expand,
                            tooltip: "can't → cannot, won't → will not",
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Text Length Filters
                      Text(
                        'Text Length Filters',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Minimum Length: $minTextLength characters',
                                ),
                                Slider(
                                  value: minTextLength.toDouble(),
                                  min: 0,
                                  max: 500,
                                  divisions: 50,
                                  onChanged:
                                      (v) => setState(
                                        () => minTextLength = v.toInt(),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Maximum Length: $maxTextLength characters',
                                ),
                                Slider(
                                  value: maxTextLength.toDouble(),
                                  min: 100,
                                  max: 50000,
                                  divisions: 100,
                                  onChanged:
                                      (v) => setState(
                                        () => maxTextLength = v.toInt(),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Unicode Normalization
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Unicode Normalization',
                                border: OutlineInputBorder(),
                                helperText: 'Normalize unicode characters',
                              ),
                              value: unicodeNormalization,
                              items:
                                  ['NFC', 'NFD', 'NFKC', 'NFKD', 'None']
                                      .map(
                                        (n) => DropdownMenuItem(
                                          value: n,
                                          child: Text(n),
                                        ),
                                      )
                                      .toList(),
                              onChanged:
                                  (v) =>
                                      setState(() => unicodeNormalization = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Privacy & PII Removal
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Privacy & PII Protection',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Remove or mask personally identifiable information',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: removePII,
                          onChanged: (v) => setState(() => removePII = v),
                        ),
                      ],
                    ),
                    if (removePII) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _CleaningOption(
                            label: 'Mask Email Addresses',
                            value: maskEmails,
                            onChanged: (v) => setState(() => maskEmails = v),
                            icon: Icons.email,
                            tooltip: 'user@email.com → [EMAIL]',
                          ),
                          _CleaningOption(
                            label: 'Mask Phone Numbers',
                            value: maskPhoneNumbers,
                            onChanged:
                                (v) => setState(() => maskPhoneNumbers = v),
                            icon: Icons.phone,
                            tooltip: '555-123-4567 → [PHONE]',
                          ),
                          _CleaningOption(
                            label: 'Mask SSN',
                            value: maskSSN,
                            onChanged: (v) => setState(() => maskSSN = v),
                            icon: Icons.badge,
                            tooltip: '123-45-6789 → [SSN]',
                          ),
                          _CleaningOption(
                            label: 'Mask Credit Cards',
                            value: maskCreditCards,
                            onChanged:
                                (v) => setState(() => maskCreditCards = v),
                            icon: Icons.credit_card,
                            tooltip: '4532-****-****-1234 → [CARD]',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language Detection & Filtering
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Language Detection & Filtering',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'Filter data by language',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: enableLanguageFilter,
                          onChanged:
                              (v) => setState(() => enableLanguageFilter = v),
                        ),
                      ],
                    ),
                    if (enableLanguageFilter) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Allowed Languages:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                              'en',
                              'es',
                              'fr',
                              'de',
                              'it',
                              'pt',
                              'zh',
                              'ja',
                              'ko',
                              'ar',
                              'hi',
                              'ru',
                            ].map((lang) {
                              final isSelected = allowedLanguages.contains(
                                lang,
                              );
                              return FilterChip(
                                label: Text(_getLanguageName(lang)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      allowedLanguages.add(lang);
                                    } else {
                                      allowedLanguages.remove(lang);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Deduplication & Preprocessing
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deduplication & Preprocessing',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Remove Duplicates'),
                      subtitle: const Text(
                        'Identify and remove exact duplicate entries',
                      ),
                      value: deduplication,
                      onChanged: (v) => setState(() => deduplication = v),
                    ),
                    SwitchListTile(
                      title: const Text('Shuffle Data'),
                      subtitle: const Text(
                        'Randomize sample order for better training',
                      ),
                      value: shuffle,
                      onChanged: (v) => setState(() => shuffle = v),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Train/Test Split',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Training: ${(trainTestSplit * 100).toInt()}%',
                              ),
                              Text(
                                'Testing: ${((1 - trainTestSplit) * 100).toInt()}%',
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(trainTestSplit * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: trainTestSplit,
                      min: 0.5,
                      max: 0.95,
                      divisions: 45,
                      onChanged: (v) => setState(() => trainTestSplit = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data Augmentation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Data Augmentation',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Switch(
                          value: enableAugmentation,
                          onChanged:
                              (v) => setState(() => enableAugmentation = v),
                        ),
                      ],
                    ),
                    if (enableAugmentation) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text('Back Translation'),
                            selected: true,
                            onSelected: (_) {},
                          ),
                          ChoiceChip(
                            label: Text('Paraphrasing'),
                            selected: true,
                            onSelected: (_) {},
                          ),
                          ChoiceChip(
                            label: Text('Synonym Replacement'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                          ChoiceChip(
                            label: Text('Random Insertion'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                          ChoiceChip(
                            label: Text('Random Deletion'),
                            selected: false,
                            onSelected: (_) {},
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _previewChanges(context),
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview Cleaned'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportDataConfig(context),
                    icon: const Icon(Icons.download),
                    label: const Text('Export Config'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _runDataPreparation(context),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Cleaning'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    const names = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'ru': 'Russian',
    };
    return names[code] ?? code.toUpperCase();
  }

  void _previewRawData(BuildContext context) {
    final rawSample = '''
<html>Check this URL: https://example.com
Contact: user@email.com or call 555-123-4567
SSN: 123-45-6789   Credit Card: 4532-1234-5678-9012

This    has   extra    spaces!!!

¿Cómo estás? 😊 #hashtag @mention</html>''';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Raw Data Preview'),
            content: SizedBox(
              width: 600,
              height: 300,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    rawSample,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
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

  void _previewChanges(BuildContext context) {
    String cleanedSample = '''Check this URL: [URL]
Contact: [EMAIL] or call [PHONE]
SSN: [SSN] Credit Card: [CARD]

This has extra spaces

como estas #hashtag @mention''';

    // Apply selected cleaning options
    if (!removeUrls)
      cleanedSample = cleanedSample.replaceAll('[URL]', 'https://example.com');
    if (!maskEmails)
      cleanedSample = cleanedSample.replaceAll('[EMAIL]', 'user@email.com');
    if (!maskPhoneNumbers)
      cleanedSample = cleanedSample.replaceAll('[PHONE]', '555-123-4567');
    if (!maskSSN)
      cleanedSample = cleanedSample.replaceAll('[SSN]', '123-45-6789');
    if (!maskCreditCards)
      cleanedSample = cleanedSample.replaceAll('[CARD]', '4532-1234-5678-9012');
    if (removeEmojis) cleanedSample = cleanedSample.replaceAll('😊', '');
    if (toLowerCase) cleanedSample = cleanedSample.toLowerCase();

    final stats = {
      'Original Length': '245 characters',
      'Cleaned Length': '${cleanedSample.length} characters',
      'URLs Removed': removeUrls ? '1' : '0',
      'Emails Masked': maskEmails ? '1' : '0',
      'PII Items Masked':
          (maskPhoneNumbers ? 1 : 0) +
          (maskSSN ? 1 : 0) +
          (maskCreditCards ? 1 : 0),
    };

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cleaned Data Preview'),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Applied Cleaning Operations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _getAppliedOperations()
                            .map(
                              (op) => Chip(
                                label: Text(op, style: TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Statistics',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...stats.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: TextStyle(fontSize: 12)),
                          Text(
                            '${e.value}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Cleaned Text',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          cleanedSample,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

  List<String> _getAppliedOperations() {
    final ops = <String>[];
    if (removeHtml) ops.add('Remove HTML');
    if (removeUrls) ops.add('Remove URLs');
    if (removeEmails) ops.add('Remove Emails');
    if (normalizeWhitespace) ops.add('Normalize Whitespace');
    if (removeEmptyLines) ops.add('Remove Empty Lines');
    if (toLowerCase) ops.add('Lowercase');
    if (removePunctuation) ops.add('Remove Punctuation');
    if (removeEmojis) ops.add('Remove Emojis');
    if (maskEmails) ops.add('Mask Emails');
    if (maskPhoneNumbers) ops.add('Mask Phones');
    if (maskSSN) ops.add('Mask SSN');
    if (maskCreditCards) ops.add('Mask Cards');
    if (deduplication) ops.add('Deduplication');
    if (enableLanguageFilter) ops.add('Language Filter');
    return ops;
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Data Preparation Help'),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Cleaning:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Removes HTML tags, URLs, and special characters\n'
                    '• Normalizes whitespace and line breaks\n'
                    '• Converts to lowercase (optional)\n',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Deduplication:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Identifies and removes exact duplicates\n'
                    '• Uses hash-based comparison for efficiency\n',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Data Augmentation:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '• Increases dataset diversity\n'
                    '• Back translation uses multiple languages\n'
                    '• Paraphrasing maintains semantic meaning\n',
                  ),
                ],
              ),
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

  void _exportDataConfig(BuildContext context) {
    final config = {
      'dataPreparation': {
        'basicCleaning': {
          'removeHtml': removeHtml,
          'removeUrls': removeUrls,
          'removeEmails': removeEmails,
          'normalizeWhitespace': normalizeWhitespace,
          'removeEmptyLines': removeEmptyLines,
          'fixEncoding': fixEncoding,
        },
        'advancedCleaning': {
          'removeSpecialChars': removeSpecialChars,
          'toLowerCase': toLowerCase,
          'removeNumbers': removeNumbers,
          'removePunctuation': removePunctuation,
          'removeEmojis': removeEmojis,
          'expandContractions': expandContractions,
        },
        'textFilters': {
          'minTextLength': minTextLength,
          'maxTextLength': maxTextLength,
          'unicodeNormalization': unicodeNormalization,
        },
        'privacyProtection': {
          'enabled': removePII,
          'maskEmails': maskEmails,
          'maskPhoneNumbers': maskPhoneNumbers,
          'maskSSN': maskSSN,
          'maskCreditCards': maskCreditCards,
        },
        'languageFiltering': {
          'enabled': enableLanguageFilter,
          'allowedLanguages': allowedLanguages,
        },
        'preprocessing': {
          'deduplication': deduplication,
          'shuffle': shuffle,
          'trainTestSplit': trainTestSplit,
        },
        'augmentation': {
          'enabled': enableAugmentation,
          'methods':
              enableAugmentation ? ['back_translation', 'paraphrasing'] : [],
        },
      },
      'timestamp': DateTime.now().toIso8601String(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(config);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Export Data Cleaning Configuration'),
            content: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Complete data cleaning and preparation config',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_getAppliedOperations().length} cleaning operations configured',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          jsonStr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Export as Python script
                  _exportAsPythonScript(context);
                },
                icon: const Icon(Icons.code),
                label: const Text('Export as Python'),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✓ Config saved as data_cleaning_config.json',
                      ),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save JSON'),
              ),
            ],
          ),
    );
  }

  void _exportAsPythonScript(BuildContext context) {
    final pythonScript = '''
import re
import json
from typing import List, Dict

class DataCleaner:
    """Advanced data cleaning pipeline for LLM training"""
    
    def __init__(self, config: Dict):
        self.config = config
    
    def clean_text(self, text: str) -> str:
        """Apply all cleaning operations"""
        
        # Basic cleaning
        ${removeHtml ? "text = re.sub(r'<[^>]+>', '', text)  # Remove HTML" : "# HTML removal disabled"}
        ${removeUrls ? "text = re.sub(r'http\\S+|www\\S+', '[URL]', text)  # Remove URLs" : "# URL removal disabled"}
        ${removeEmails ? "text = re.sub(r'\\S+@\\S+', '[EMAIL]', text)  # Remove emails" : "# Email removal disabled"}
        ${normalizeWhitespace ? "text = ' '.join(text.split())  # Normalize whitespace" : "# Whitespace normalization disabled"}
        
        # Advanced cleaning
        ${removeSpecialChars ? "text = re.sub(r'[^a-zA-Z0-9\\s]', '', text)  # Remove special chars" : "# Special char removal disabled"}
        ${toLowerCase ? "text = text.lower()  # Convert to lowercase" : "# Lowercase conversion disabled"}
        ${removeNumbers ? "text = re.sub(r'\\d+', '', text)  # Remove numbers" : "# Number removal disabled"}
        ${removePunctuation ? "text = re.sub(r'[^\\w\\s]', '', text)  # Remove punctuation" : "# Punctuation removal disabled"}
        ${removeEmojis ? "text = text.encode('ascii', 'ignore').decode('ascii')  # Remove emojis" : "# Emoji removal disabled"}
        
        # PII masking
        ${maskPhoneNumbers ? "text = re.sub(r'\\d{3}-\\d{3}-\\d{4}', '[PHONE]', text)  # Mask phones" : "# Phone masking disabled"}
        ${maskSSN ? "text = re.sub(r'\\d{3}-\\d{2}-\\d{4}', '[SSN]', text)  # Mask SSN" : "# SSN masking disabled"}
        ${maskCreditCards ? "text = re.sub(r'\\d{4}[- ]?\\d{4}[- ]?\\d{4}[- ]?\\d{4}', '[CARD]', text)  # Mask cards" : "# Card masking disabled"}
        
        # Length filtering
        if len(text) < $minTextLength or len(text) > $maxTextLength:
            return None
        
        return text.strip()
    
    def process_dataset(self, data: List[str]) -> List[str]:
        """Process entire dataset"""
        cleaned = [self.clean_text(text) for text in data]
        cleaned = [t for t in cleaned if t is not None]
        
        # Deduplication
        ${deduplication ? "cleaned = list(set(cleaned))" : "# Deduplication disabled"}
        
        # Shuffle
        ${shuffle ? '''import random
        random.shuffle(cleaned)''' : "# Shuffle disabled"}
        
        return cleaned

# Usage example
if __name__ == "__main__":
    config = {
        "minLength": $minTextLength,
        "maxLength": $maxTextLength,
    }
    
    cleaner = DataCleaner(config)
    
    # Load your data
    with open("input.jsonl", "r") as f:
        data = [json.loads(line)["text"] for line in f]
    
    # Clean data
    cleaned_data = cleaner.process_dataset(data)
    
    # Save cleaned data
    with open("cleaned_output.jsonl", "w") as f:
        for text in cleaned_data:
            f.write(json.dumps({"text": text}) + "\\n")
    
    print(f"Cleaned {len(cleaned_data)} samples")
''';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Python Data Cleaning Script'),
            content: SizedBox(
              width: 700,
              height: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.code, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Ready-to-use Python script with your configuration',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          pythonScript,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Python script saved as data_cleaner.py'),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Script'),
              ),
            ],
          ),
    );
  }

  void _runDataPreparation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Running Data Cleaning Pipeline'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Processing dataset...'),
                const SizedBox(height: 16),
                Text(
                  'Applying ${_getAppliedOperations().length} cleaning operations',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);

      // Show results
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  const Text('Cleaning Completed'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data cleaning pipeline completed successfully!'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatRow('Original Samples', '15,432'),
                        _StatRow('After Cleaning', '14,856'),
                        _StatRow('Removed (duplicates)', '576'),
                        _StatRow('PII Items Masked', '1,234'),
                        _StatRow('Average Length', '342 chars'),
                        const Divider(),
                        _StatRow(
                          'Training Set',
                          '${(14856 * trainTestSplit).toInt()} (${(trainTestSplit * 100).toInt()}%)',
                        ),
                        _StatRow(
                          'Test Set',
                          '${(14856 * (1 - trainTestSplit)).toInt()} (${((1 - trainTestSplit) * 100).toInt()}%)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Cleaned dataset ready for training!'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(selectedTabProvider.notifier).state = 3;
                  },
                  child: const Text('Proceed to Training'),
                ),
              ],
            ),
      );
    });
  }
}

class _CleaningOption extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final IconData icon;
  final String? tooltip;

  const _CleaningOption({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.icon,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final widget = FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
      selected: value,
      onSelected: onChanged,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: widget);
    }
    return widget;
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12)),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
