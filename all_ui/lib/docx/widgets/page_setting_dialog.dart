import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/page_size.dart';
import '../states/provider.dart';

class PageSettingDialog extends ConsumerStatefulWidget {
  const PageSettingDialog({super.key});

  @override
  ConsumerState<PageSettingDialog> createState() => _PageSettingDialogState();
}

class _PageSettingDialogState extends ConsumerState<PageSettingDialog> {
  @override
  Widget build(BuildContext context) {
    final currentSettings = ref.read(documentProvider).pageSettings;
    var pageSize = currentSettings.pageSize;
    var showPageNumbers = currentSettings.showPageNumbers;
    var showHeader = currentSettings.showHeader;
    var showFooter = currentSettings.showFooter;
    final headerController = TextEditingController(
      text: currentSettings.header ?? '',
    );
    final footerController = TextEditingController(
      text: currentSettings.footer ?? '',
    );
    final pageFormatController = TextEditingController(
      text: currentSettings.pageNumberFormat,
    );
    return AlertDialog(
      title: const Text('Page Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Page Size',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<PageSize>(
              segments: const [
                ButtonSegment(value: PageSize.a4, label: Text('A4')),
                ButtonSegment(value: PageSize.letter, label: Text('Letter')),
                ButtonSegment(value: PageSize.legal, label: Text('Legal')),
              ],
              selected: {pageSize},
              onSelectionChanged: (Set<PageSize> selection) {
                setState(() => pageSize = selection.first);
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            SwitchListTile(
              title: const Text('Show Page Numbers'),
              value: showPageNumbers,
              onChanged: (value) => setState(() => showPageNumbers = value),
            ),
            if (showPageNumbers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: pageFormatController,
                  decoration: const InputDecoration(
                    labelText: 'Page Number Format',
                    hintText: 'Page {n}',
                    helperText: 'Use {n} for page number',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Divider(),
            SwitchListTile(
              title: const Text('Show Header'),
              value: showHeader,
              onChanged: (value) => setState(() => showHeader = value),
            ),
            if (showHeader)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: headerController,
                  decoration: const InputDecoration(
                    labelText: 'Header Text',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Divider(),
            SwitchListTile(
              title: const Text('Show Footer'),
              value: showFooter,
              onChanged: (value) => setState(() => showFooter = value),
            ),
            if (showFooter)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: footerController,
                  decoration: const InputDecoration(
                    labelText: 'Footer Text',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final newSettings = currentSettings.copyWith(
              pageSize: pageSize,
              showPageNumbers: showPageNumbers,
              pageNumberFormat: pageFormatController.text,
              showHeader: showHeader,
              header:
                  headerController.text.isEmpty ? null : headerController.text,
              showFooter: showFooter,
              footer:
                  footerController.text.isEmpty ? null : footerController.text,
            );
            ref.read(documentProvider.notifier).updatePageSettings(newSettings);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Page settings updated')),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
