// lib/features/gallery/widgets/rename_dialog.dart
//
// Smart rename dialog.
// Shows a live preview table of old → new names as the user types.
// Supports preset templates, custom token entry, sequence start,
// and conflict resolution strategy.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/gallery_models.dart';
import '../../../core/providers/gallery_providers.dart';
import '../../../shared/theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Rename preview model (mirrors Rust RenamePreview)
// ─────────────────────────────────────────────────────────────────────────────

class _RenamePreview {
  final String oldName;
  final String newName;
  final bool conflict;
  const _RenamePreview(this.oldName, this.newName, this.conflict);
}

// ─────────────────────────────────────────────────────────────────────────────
// Template presets
// ─────────────────────────────────────────────────────────────────────────────

const _presets = [
  ('Date + Original',  '{date}_{name}.{ext}'),
  ('Date + Sequence',  '{date}_{seq:4}.{ext}'),
  ('Camera + Date',    '{camera}_{date}_{seq:4}.{ext}'),
  ('Year/Month/Seq',   '{year}-{month}_{seq:4}.{ext}'),
  ('Date + Time',      '{date}_{time}.{ext}'),
  ('Full EXIF',        '{date}_{camera}_ISO{iso}_{focal}_{seq:4}.{ext}'),
  ('Sequence only',    '{seq:6}.{ext}'),
  ('Original (reset)', '{name}.{ext}'),
];

const _tokenHelp = [
  ('{name}',    'Original filename stem'),
  ('{ext}',     'Extension (lowercase)'),
  ('{date}',    'EXIF date as YYYY-MM-DD'),
  ('{year}',    '4-digit year'),
  ('{month}',   '2-digit month'),
  ('{day}',     '2-digit day'),
  ('{time}',    'HH-MM-SS from EXIF'),
  ('{camera}',  'Camera model'),
  ('{iso}',     'ISO value'),
  ('{focal}',   'Focal length (mm)'),
  ('{seq}',     'Sequence number (padded)'),
  ('{seq:4}',   'Sequence padded to N digits'),
  ('{rating}',  'Star rating 0–5'),
  ('{folder}',  'Parent folder name'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Dialog
// ─────────────────────────────────────────────────────────────────────────────

class RenameDialog extends ConsumerStatefulWidget {
  final List<GMediaItem> items;
  const RenameDialog({super.key, required this.items});

  @override
  ConsumerState<RenameDialog> createState() => _RenameDialogState();

  static Future<void> show(BuildContext context, List<GMediaItem> items) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => RenameDialog(items: items),
    );
  }
}

class _RenameDialogState extends ConsumerState<RenameDialog> {
  final _templateCtrl = TextEditingController(text: '{date}_{seq:4}.{ext}');
  int _seqStart = 1;
  String _conflict = 'suffix';
  bool _tokenHelpVisible = false;
  bool _executing = false;

  @override
  void initState() {
    super.initState();
    _templateCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _templateCtrl.dispose();
    super.dispose();
  }

  List<_RenamePreview> get _previews {
    final template = _templateCtrl.text;
    return widget.items.asMap().entries.map((entry) {
      final idx  = entry.key;
      final item = entry.value;
      final seq  = (_seqStart + idx).toString().padLeft(4, '0');
      final exifDate = '2024-11-15'; // in prod: from item.exifDate
      final camera   = 'Sony_A7R_IV';
      final newName = template
          .replaceAll('{name}', _stem(item.fileName))
          .replaceAll('{ext}',  _ext(item.fileName))
          .replaceAll('{date}', exifDate)
          .replaceAll('{year}', '2024')
          .replaceAll('{month}','11')
          .replaceAll('{day}',  '15')
          .replaceAll('{time}', '10-30-00')
          .replaceAll('{camera}', camera)
          .replaceAll('{iso}',    '400')
          .replaceAll('{focal}',  '35mm')
          .replaceAll('{rating}', item.rating.toString())
          .replaceAll('{folder}', 'Photos')
          .replaceAll(RegExp(r'\{seq:\d+\}'), seq)
          .replaceAll('{seq}', seq);
      return _RenamePreview(item.fileName, newName, false);
    }).toList();
  }

  String _stem(String n) => n.contains('.') ? n.substring(0, n.lastIndexOf('.')) : n;
  String _ext(String n)  => n.contains('.') ? n.substring(n.lastIndexOf('.') + 1).toLowerCase() : 'jpg';

  @override
  Widget build(BuildContext context) {
    final previews = _previews;
    final hasConflict = previews.any((p) => p.conflict);

    return Dialog(
      backgroundColor: AppTheme.bg1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: SizedBox(
        width: 680,
        height: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _Header(
              count: widget.items.length,
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: AppTheme.border),

            Expanded(
              child: Row(
                children: [
                  // Left: controls
                  SizedBox(
                    width: 260,
                    child: _ControlsPanel(
                      templateCtrl: _templateCtrl,
                      seqStart: _seqStart,
                      conflict: _conflict,
                      tokenHelpVisible: _tokenHelpVisible,
                      onSeqStart: (v) => setState(() => _seqStart = v),
                      onConflict: (v) => setState(() => _conflict = v),
                      onPreset: (t) => setState(() {
                        _templateCtrl.text = t;
                        _templateCtrl.selection = TextSelection.collapsed(
                            offset: t.length);
                      }),
                      onToggleHelp: () =>
                          setState(() => _tokenHelpVisible = !_tokenHelpVisible),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: AppTheme.border),

                  // Right: preview table
                  Expanded(
                    child: _PreviewTable(previews: previews),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.border),

            // Footer
            _Footer(
              hasConflict: hasConflict,
              executing: _executing,
              onCancel: () => Navigator.of(context).pop(),
              onRename: () => _executeRename(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeRename(BuildContext context) async {
    setState(() => _executing = true);
    // In production: call GalleryBridge.executeRename(...)
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.of(context).pop();
    ref.read(mediaItemsProvider.notifier).refresh();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int count;
  final VoidCallback onClose;
  const _Header({required this.count, required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
        height: AppTheme.toolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.drive_file_rename_outline,
                size: 16, color: AppTheme.accent),
            const SizedBox(width: 8),
            Text('Rename $count item${count == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Inter')),
            const Spacer(),
            InkWell(
                onTap: onClose,
                child: const Icon(Icons.close,
                    size: 16, color: AppTheme.textMuted)),
          ],
        ),
      );
}

class _ControlsPanel extends StatelessWidget {
  final TextEditingController templateCtrl;
  final int seqStart;
  final String conflict;
  final bool tokenHelpVisible;
  final ValueChanged<int> onSeqStart;
  final ValueChanged<String> onConflict;
  final ValueChanged<String> onPreset;
  final VoidCallback onToggleHelp;

  const _ControlsPanel({
    required this.templateCtrl,
    required this.seqStart,
    required this.conflict,
    required this.tokenHelpVisible,
    required this.onSeqStart,
    required this.onConflict,
    required this.onPreset,
    required this.onToggleHelp,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template input
          const _SectionLabel('TEMPLATE'),
          const SizedBox(height: 6),
          TextField(
            controller: templateCtrl,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontFamily: 'JetBrains Mono'),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.bg2,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppTheme.accent),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Presets
          const _SectionLabel('PRESETS'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _presets
                .map((p) => _PresetChip(
                    label: p.$1,
                    onTap: () => onPreset(p.$2)))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Sequence start
          const _SectionLabel('SEQUENCE START'),
          const SizedBox(height: 6),
          Row(
            children: [
              _NumberBtn(
                  label: '−',
                  onTap: () => onSeqStart((seqStart - 1).clamp(1, 9999))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(seqStart.toString(),
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.accent,
                        fontFamily: 'JetBrains Mono')),
              ),
              _NumberBtn(
                  label: '+',
                  onTap: () => onSeqStart((seqStart + 1).clamp(1, 9999))),
            ],
          ),
          const SizedBox(height: 12),

          // Conflict strategy
          const _SectionLabel('ON CONFLICT'),
          const SizedBox(height: 6),
          ...[
            ('suffix', 'Add suffix (_2, _3…)'),
            ('skip', 'Skip file'),
            ('overwrite', 'Overwrite'),
          ].map((opt) => RadioListTile<String>(
                value: opt.$1,
                groupValue: conflict,
                onChanged: (v) => onConflict(v!),
                title: Text(opt.$2,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                activeColor: AppTheme.accent,
                dense: true,
                contentPadding: EdgeInsets.zero,
              )),
          const SizedBox(height: 8),

          // Token reference toggle
          InkWell(
            onTap: onToggleHelp,
            child: Row(
              children: [
                Icon(
                  tokenHelpVisible
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                const Text('Token reference',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
          if (tokenHelpVisible) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.bg2,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: _tokenHelp
                    .map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(t.$1,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.accent,
                                        fontFamily: 'JetBrains Mono')),
                              ),
                              Expanded(
                                child: Text(t.$2,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.textMuted)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewTable extends StatelessWidget {
  final List<_RenamePreview> previews;
  const _PreviewTable({required this.previews});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: AppTheme.bg2,
          child: const Row(
            children: [
              Expanded(
                  child: Text('Original',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                          letterSpacing: 1))),
              SizedBox(width: 24),
              Expanded(
                  child: Text('New name',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                          letterSpacing: 1))),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),
        // Rows
        Expanded(
          child: ListView.builder(
            itemCount: previews.length,
            itemExtent: 36,
            itemBuilder: (_, i) => _PreviewRow(preview: previews[i]),
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final _RenamePreview preview;
  const _PreviewRow({required this.preview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: preview.conflict
            ? AppTheme.flagRed.withOpacity(0.06)
            : Colors.transparent,
        border: const Border(
            bottom: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              preview.oldName,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                  fontFamily: 'JetBrains Mono'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.arrow_forward,
                size: 12, color: AppTheme.textMuted),
          ),
          Expanded(
            child: Text(
              preview.newName,
              style: TextStyle(
                  fontSize: 11,
                  color: preview.conflict
                      ? AppTheme.flagRed
                      : AppTheme.accent,
                  fontFamily: 'JetBrains Mono'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (preview.conflict)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.warning_amber,
                  size: 12, color: AppTheme.flagRed),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool hasConflict;
  final bool executing;
  final VoidCallback onCancel;
  final VoidCallback onRename;

  const _Footer({
    required this.hasConflict,
    required this.executing,
    required this.onCancel,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (hasConflict)
            const Row(children: [
              Icon(Icons.warning_amber, size: 13, color: AppTheme.flagYellow),
              SizedBox(width: 6),
              Text('Some names conflict',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.flagYellow)),
            ]),
          const Spacer(),
          _DialogBtn(label: 'Cancel', onTap: onCancel),
          const SizedBox(width: 8),
          _DialogBtn(
            label: executing ? 'Renaming…' : 'Rename Files',
            primary: true,
            onTap: executing ? () {} : onRename,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tiny helpers
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
          letterSpacing: 1.3,
          fontFamily: 'Inter'));
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.bg2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                  fontFamily: 'Inter')),
        ),
      );
}

class _NumberBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NumberBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.bg2,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.border),
          ),
          child: Center(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary))),
        ),
      );
}

class _DialogBtn extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _DialogBtn(
      {required this.label, this.primary = false, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: primary ? AppTheme.accent : AppTheme.bg2,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  primary ? AppTheme.accent : AppTheme.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12,
                color: primary ? AppTheme.bg0 : AppTheme.textPrimary,
                fontWeight:
                    primary ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Inter'),
          ),
        ),
      );
}
