import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../states/provider.dart';
import 'collaboration_dialog.dart';
import 'document_info_dialog.dart';
import 'footnotes_dialog.dart';
import 'keyboard_shortcut_dialog.dart';
import 'move_to_folder_dialog.dart';
import 'page_setting_dialog.dart';
import 'spell_check_dialog.dart';
import 'tags_dialog.dart';
import 'theme_dialog.dart';
import 'version_history_dialog.dart';

class MoreOptions extends ConsumerWidget {
  const MoreOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('Duplicate Document'),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(documentProvider.notifier).duplicateDocument();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document duplicated successfully'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Page Settings'),
            subtitle: const Text('Headers, footers, page size'),
            onTap: () {
              Navigator.pop(context);
              _showPageSettingsDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Document Theme'),
            subtitle: Text(ref.read(documentProvider).currentTheme!.name),
            onTap: () {
              Navigator.pop(context);
              _showThemeDialog(context);
            },
          ),
          ListTile(
            leading: Icon(
              ref.read(documentProvider).isCollaborationEnabled
                  ? Icons.people
                  : Icons.people_outline,
            ),
            title: const Text('Collaboration'),
            subtitle: Text(
              ref.read(documentProvider).isCollaborationEnabled
                  ? '${ref.read(documentProvider).collaborators.length} active'
                  : 'Enable sharing',
            ),
            onTap: () {
              Navigator.pop(context);
              _showCollaborationDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.spellcheck),
            title: const Text('Spell Check'),
            subtitle: Text(
              '${ref.read(documentProvider).spellErrors.length} issues found',
            ),
            onTap: () {
              Navigator.pop(context);
              if (ref.read(documentProvider).spellCheckEnabled) {
                _showSpellCheckDialog(context);
              } else {
                ref.read(documentProvider.notifier).toggleSpellCheck();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Spell check enabled')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.notes),
            title: const Text('Footnotes'),
            subtitle: Text(
              '${ref.read(documentProvider).footnotes.length} notes',
            ),
            onTap: () {
              Navigator.pop(context);
              _showFootnotesDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Insert Image'),
            subtitle: const Text('Add image to document'),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(documentProvider.notifier).insertImage();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image insertion is a placeholder feature'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.send),
            title: const Text('Export All Formats'),
            subtitle: const Text('DOCX, PDF, and TXT'),
            onTap: () async {
              Navigator.pop(context);
              final paths =
                  await ref
                      .read(documentProvider.notifier)
                      .exportToMultipleFormats();
              if (context.mounted && paths.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Exported to ${paths.length} formats'),
                    action: SnackBarAction(
                      label: 'Share',
                      onPressed: () {
                        Share.shareXFiles(paths.map((p) => XFile(p)).toList());
                      },
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_move),
            title: const Text('Move to Folder'),
            onTap: () {
              Navigator.pop(context);
              _showMoveToFolderDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: const Text('Manage Tags'),
            onTap: () {
              Navigator.pop(context);
              _showTagsDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Version History'),
            subtitle: Text(
              '${ref.read(documentProvider).versions.length} versions',
            ),
            onTap: () {
              Navigator.pop(context);
              _showVersionHistory(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.print),
            title: const Text('Print'),
            onTap: () async {
              Navigator.pop(context);
              try {
                final docState = ref.read(documentProvider);
                final text = docState.controller.document.toPlainText();
                await Printing.layoutPdf(
                  onLayout: (format) async {
                    final pdf = pw.Document();
                    final font = await PdfGoogleFonts.robotoRegular();
                    pdf.addPage(
                      pw.Page(
                        build:
                            (context) =>
                                pw.Text(text, style: pw.TextStyle(font: font)),
                      ),
                    );
                    return pdf.save();
                  },
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Print error: $e')));
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Document Info'),
            onTap: () {
              Navigator.pop(context);
              _showDocumentInfo(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.keyboard),
            title: const Text('Keyboard Shortcuts'),
            onTap: () {
              Navigator.pop(context);
              _showKeyboardShortcuts(context);
            },
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => ThemeDialog());
  }

  void _showDocumentInfo(BuildContext context) {
    showDialog(context: context, builder: (context) => DocumentInfoDialog());
  }

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => KeyboardShortcutDialog(),
    );
  }

  void _showCollaborationDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => CollaborationDialog());
  }

  void _showSpellCheckDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => SpellCheckDialog());
  }

  void _showPageSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return PageSettingDialog();
            },
          ),
    );
  }

  void _showFootnotesDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => FootnotesDialog());
  }

  void _showMoveToFolderDialog(BuildContext context, WidgetRef ref) {
    final foldersAsync = ref.read(foldersProvider);
    foldersAsync.whenData((folders) {
      showDialog(
        context: context,
        builder: (context) => MoveToFolderDialog(folders: folders),
      );
    });
  }

  void _showTagsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => TagsDialog());
  }

  void _showVersionHistory(BuildContext context) {
    showDialog(context: context, builder: (context) => VersionHistoryDialog());
  }
}
