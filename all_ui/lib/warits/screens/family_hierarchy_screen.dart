import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/family_provider.dart';
import '../widgets/add_member_dialog.dart';
import '../widgets/family_tree_view.dart';
import '../widgets/member_detail_panel.dart';

class FamilyHierarchyScreen extends ConsumerStatefulWidget {
  const FamilyHierarchyScreen({super.key});

  @override
  ConsumerState<FamilyHierarchyScreen> createState() =>
      _FamilyHierarchyScreenState();
}

class _FamilyHierarchyScreenState extends ConsumerState<FamilyHierarchyScreen> {
  final GlobalKey _treeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyProvider);

    if (familyState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (familyState.currentTreeId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Family Tree Manager')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_tree, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'No family tree selected',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showCreateTreeDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create New Tree'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          familyState.trees
              .firstWhere((t) => t.id == familyState.currentTreeId)
              .name,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => _showAddMemberDialog(context),
          ),
          if (familyState.selectedMemberId != null)
            IconButton(
              icon: const Icon(Icons.calculate),
              tooltip: 'Calculate Inheritance',
              onPressed: () => _showInheritanceDialog(context),
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'screenshot',
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8),
                        Text('Screenshot Tree'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export_pdf',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf),
                        SizedBox(width: 8),
                        Text('Export to PDF'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export_json',
                    child: Row(
                      children: [
                        Icon(Icons.code),
                        SizedBox(width: 8),
                        Text('Export to JSON'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          familyState.members.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.family_restroom,
                      size: 100,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No family members added yet',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => _showAddMemberDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add First Member'),
                    ),
                  ],
                ),
              )
              : RepaintBoundary(
                key: _treeKey,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FamilyTreeView(familyState: familyState),
                    ),
                    if (familyState.selectedMemberId != null)
                      Expanded(
                        flex: 2,
                        child: MemberDetailsPanel(
                          memberId: familyState.selectedMemberId!,
                        ),
                      ),
                  ],
                ),
              ),
      floatingActionButton:
          familyState.members.isNotEmpty
              ? FloatingActionButton(
                onPressed: () => _showAddMemberDialog(context),
                child: const Icon(Icons.person_add),
              )
              : null,
    );
  }

  void _showCreateTreeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Create New Family Tree'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Tree Name',
                hintText: 'e.g., Smith Family',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    ref
                        .read(familyProvider.notifier)
                        .createNewTree(controller.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddMemberDialog());
  }

  void _showInheritanceDialog(BuildContext context) {
    final estateController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Calculate Inheritance'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: estateController,
                  decoration: const InputDecoration(
                    labelText: 'Estate Value (optional)',
                    prefixText: '\$ ',
                    hintText: '100000',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Complete Islamic inheritance calculation based on Quran and Sunnah',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final familyState = ref.read(familyProvider);
                  if (familyState.selectedMemberId != null) {
                    final estateValue =
                        double.tryParse(estateController.text) ?? 0;
                    ref
                        .read(familyProvider.notifier)
                        .calculateInheritance(
                          familyState.selectedMemberId!,
                          estateValue: estateValue,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Calculate'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'screenshot':
        await _captureAndSaveScreenshot();
        break;
      case 'export_pdf':
        await _exportToPDF();
        break;
      case 'export_json':
        _exportToJSON();
        break;
      case 'share':
        await _shareTree();
        break;
    }
  }

  Future<void> _captureAndSaveScreenshot() async {
    try {
      final boundary =
          _treeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // In production, use image_gallery_saver package
      // await ImageGallerySaver.saveImage(pngBytes, name: "family_tree_${DateTime.now().millisecondsSinceEpoch}");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Screenshot captured! Use image_gallery_saver package to save.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    try {
      // In production, use pdf and printing packages to generate PDF
      // This would create a professional PDF with:
      // - Family tree diagram
      // - Member details table
      // - Mahram relationship matrix
      // - Inheritance calculations

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'PDF export - use pdf & printing packages for full implementation',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _exportToJSON() {
    final data = ref.read(familyProvider.notifier).exportToJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    // In production, use share_plus or file_picker
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'JSON exported! Use share_plus or file_picker to save.',
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _shareTree() async {
    try {
      // In production, use share_plus to share the screenshot or PDF
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Share feature - use share_plus package'),
            backgroundColor: Colors.purple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
