// UI Components
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_member.dart';
import '../states/family_tree_provider.dart';
import '../models/family_tree_state.dart';
import '../models/relation_type.dart';
import '../states/theme_provider.dart';
import '../widgets/asset_dialog.dart';
import '../widgets/control_panel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/empty_state.dart';
import '../widgets/fab_menu.dart';
import '../widgets/family_tree_painter.dart';
import '../widgets/member_card_list.dart';
import '../widgets/member_dialog.dart';
import '../widgets/summary_panel.dart';

class FamilyTreeScreen extends ConsumerStatefulWidget {
  const FamilyTreeScreen({super.key});

  @override
  ConsumerState<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends ConsumerState<FamilyTreeScreen>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  final GlobalKey _treeKey = GlobalKey();
  String? _draggedMemberId;
  late AnimationController _summaryAnimationController;

  @override
  void initState() {
    super.initState();
    _summaryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _summaryAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyTreeProvider);
    final hasDeceased = state.members.any(
      (m) => m.relation == RelationType.deceased,
    );
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: CustomAppBar(
        state: state,
        onToggleGrid: () => ref.read(familyTreeProvider.notifier).toggleGrid(),
        onAutoLayout: () => ref.read(familyTreeProvider.notifier).autoLayout(),
        onZoomIn: _zoomIn,
        onZoomOut: _zoomOut,
        onMenuAction: (action) => _handleMenuAction(action, context),
        onExportImage: _exportToImage,
        onShareData: _shareData,
        onToggleTheme: () => ref.read(themeProvider.notifier).toggleTheme(),
        isDarkMode: theme.brightness == Brightness.dark,
      ),
      body:
          state.members.isEmpty
              ? EmptyState(
                onAddDeceased: () => _showAddMemberDialog(context, false),
              )
              : _buildTreeView(context, state),

      drawer: CustomDrawer(
        state: state,
        onShowAssets: () => _showAssetsDialog(context),
        onShowAbout: () => _showAboutDialog(context),
      ),
    );
  }

  // In _buildTreeView method of family_tree_screen.dart
  Widget _buildTreeView(BuildContext context, FamilyTreeState state) {
    if (state.members.where((m) => m.faraidShare > 0).isNotEmpty) {
      _summaryAnimationController.forward();
    }

    final heirs =
        state.members.where((m) => m.faraidShare > 0 && !m.isDeceased).toList();
    final hasDeceased = state.members.any(
      (m) => m.relation == RelationType.deceased,
    );

    return Stack(
      children: [
        RepaintBoundary(
          key: _treeKey,
          child: InteractiveViewer(
            transformationController: _transformationController,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            minScale: 0.05, // Reduced min scale for more zoom out
            maxScale: 8.0, // Increased max scale for more zoom in
            constrained: false, // Allow unlimited panning
            child: Container(
              width: 5000, // Increased width
              height: 5000, // Increased height
              child: CustomPaint(
                painter: FamilyTreePainter(state.members, state.showGrid),
                child: Stack(
                  children: [
                    // Background pattern for better orientation
                    _buildCanvasBackground(),
                    MemberCards(
                      members: state.members,
                      selectedMemberId: state.selectedMemberId,
                      onSelectMember:
                          (String? id) => ref
                              .read(familyTreeProvider.notifier)
                              .selectMember(id),
                      onShowContextMenu: _showMemberContextMenu,
                      onDelete:
                          (FamilyMember member) =>
                              _confirmDelete(context, member),
                      onEdit:
                          (FamilyMember member) =>
                              _showEditMemberDialog(context, member),
                      onUpdatePosition: (String id, Offset delta) {
                        final member = state.members.firstWhere(
                          (m) => m.id == id,
                        );
                        final newPosition =
                            member.position + delta / state.scale;
                        ref
                            .read(familyTreeProvider.notifier)
                            .updateMemberPosition(id, newPosition);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Control Panel (Top Right)
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ControlPanel(
                state: state,
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
                onToggleGrid:
                    () => ref.read(familyTreeProvider.notifier).toggleGrid(),
                onAutoLayout:
                    () => ref.read(familyTreeProvider.notifier).autoLayout(),
              ),
              const SizedBox(height: 16),
              FABMenu(
                hasDeceased: hasDeceased,
                onAddChild:
                    () => _showQuickAddDialog(context, RelationType.son),
                onAddSpouse:
                    () => _showQuickAddDialog(context, RelationType.spouse),
                onAddMember: () => _showAddMemberDialog(context, hasDeceased),
              ),
            ],
          ),
        ),

        // Summary Panel - Separate Positioned widget
        if (heirs.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _summaryAnimationController,
                  curve: Curves.easeOut,
                ),
              ),
              child: SummaryPanel(
                heirs: heirs,
                netEstate: state.estate.netEstate,
                onShowCalculation:
                    () => _showCalculationDetails(context, heirs.first),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCanvasBackground() {
    return Positioned.fill(
      child: CustomPaint(painter: _CanvasBackgroundPainter()),
    );
  }

  void _zoomIn() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * 1.2).clamp(0.1, 4.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
  }

  void _zoomOut() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final newScale = (currentScale / 1.2).clamp(0.1, 4.0);
    _transformationController.value = Matrix4.identity()..scale(newScale);
  }

  void _showAddMemberDialog(BuildContext context, bool hasDeceased) {
    showDialog(
      context: context,
      builder:
          (ctx) => MemberDialog(
            hasDeceased: hasDeceased,
            onSave:
                (member) =>
                    ref.read(familyTreeProvider.notifier).addMember(member),
          ),
    );
  }

  void _showEditMemberDialog(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (ctx) => MemberDialog(
            hasDeceased: true,
            editMember: member,
            onSave:
                (updatedMember) => ref
                    .read(familyTreeProvider.notifier)
                    .updateMember(member.id, updatedMember),
          ),
    );
  }

  // In _FamilyTreeScreenState class
  void _showMemberContextMenu(FamilyMember member, Offset? position) {
    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    showMenu(
      context: context,
      position:
          position != null
              ? RelativeRect.fromRect(
                position & const Size(40, 40),
                Offset.zero & overlay!.size,
              )
              : const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.person_add, size: 20),
            title: const Text('Tambah Anak'),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              _showQuickAddDialog(
                context,
                RelationType.son,
                parentId: member.id,
              );
            },
          ),
        ),
        if (member.relation == RelationType.deceased)
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.favorite, size: 20),
              title: const Text('Tambah Pasangan'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _showQuickAddDialog(context, RelationType.spouse);
              },
            ),
          ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.people, size: 20),
            title: const Text('Tambah Sibling'),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              _showQuickAddDialog(context, RelationType.brother);
            },
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.edit, size: 20),
            title: const Text('Ubah'),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              _showEditMemberDialog(context, member);
            },
          ),
        ),
        if (member.faraidShare > 0)
          PopupMenuItem(
            child: ListTile(
              leading: const Icon(Icons.info, size: 20),
              title: const Text('Tampilkan Perhitungan'),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.pop(context);
                _showCalculationDetails(context, member);
              },
            ),
          ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(Icons.delete, size: 20, color: Colors.red),
            title: const Text('Hapus', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, member);
            },
          ),
        ),
      ],
    );
  }

  void _showQuickAddDialog(
    BuildContext context,
    RelationType suggestedRelation, {
    String? parentId,
  }) {
    final nameController = TextEditingController();
    Gender selectedGender =
        suggestedRelation == RelationType.son ? Gender.male : Gender.female;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  title: Text('Tambah ${_getRelationLabel(suggestedRelation)}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<Gender>(
                        segments: const [
                          ButtonSegment(
                            value: Gender.male,
                            label: Text('Laki-laki'),
                            icon: Icon(Icons.man),
                          ),
                          ButtonSegment(
                            value: Gender.female,
                            label: Text('Perempuan'),
                            icon: Icon(Icons.woman),
                          ),
                        ],
                        selected: {selectedGender},
                        onSelectionChanged: (Set<Gender> newSelection) {
                          setDialogState(
                            () => selectedGender = newSelection.first,
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          RelationType relation = suggestedRelation;
                          if (suggestedRelation == RelationType.son) {
                            relation =
                                selectedGender == Gender.male
                                    ? RelationType.son
                                    : RelationType.daughter;
                          } else if (suggestedRelation ==
                              RelationType.brother) {
                            relation =
                                selectedGender == Gender.male
                                    ? RelationType.brother
                                    : RelationType.sister;
                          }

                          final member = FamilyMember(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: nameController.text.trim(),
                            relation: relation,
                            gender: selectedGender,
                            parentId: parentId,
                          );
                          ref
                              .read(familyTreeProvider.notifier)
                              .addMember(member);
                          Navigator.pop(ctx);
                        }
                      },
                      child: const Text('Tambah'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showCalculationDetails(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Warisan untuk ${member.name}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${(member.faraidShare * 100).toStringAsFixed(2)}%',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'dari total harta warisan',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Dalil:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.calculationReason ??
                        'Tidak ada alasan atau dalil terkait ini',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Lihat referensi:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Open reference link
                    },
                    child: const Text(
                      '📖 Referensi Alquran',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Open detailed guide
                    },
                    child: const Text(
                      '📚 Referensi fiqh',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  void _showAssetsDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AssetsDialog());
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('About Faraid'),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Islamic Inheritance Law (Faraid)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Faraid is the Islamic law of inheritance that specifies how a deceased Muslim\'s estate should be distributed among heirs according to Quranic principles.',
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Key Principles:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Fixed shares for specific relatives'),
                  Text(
                    '• Male heirs typically receive twice the share of females',
                  ),
                  Text('• Debts and funeral expenses are paid first'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _exportToImage() async {
    try {
      final boundary =
          _treeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        await Clipboard.setData(ClipboardData(text: 'Image exported'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image exported to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareData() {
    final json = ref.read(familyTreeProvider.notifier).exportToJson();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data copied to clipboard for sharing'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDelete(BuildContext context, FamilyMember member) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Member'),
            content: Text('Remove ${member.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(familyTreeProvider.notifier).removeMember(member.id);
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _handleMenuAction(String action, BuildContext context) {
    switch (action) {
      case 'assets':
        _showAssetsDialog(context);
        break;
      case 'export_pdf':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF export requires pdf package'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case 'export_image':
        _exportToImage();
        break;
      case 'share':
        _shareData();
        break;
      case 'export':
        final json = ref.read(familyTreeProvider.notifier).exportToJson();
        Clipboard.setData(ClipboardData(text: json));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exported to clipboard'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'import':
        // Show import dialog
        break;
    }
  }

  String _getRelationLabel(RelationType relation) {
    const labels = {
      RelationType.deceased: 'Meninggal',
      RelationType.father: 'Ayah',
      RelationType.mother: 'Ibu',
      RelationType.spouse: 'Pasangan',
      RelationType.son: 'Anak Laki-laki',
      RelationType.daughter: 'Anak Perempuan',
      RelationType.brother: 'Brother',
      RelationType.sister: 'Sister',
      RelationType.paternalGrandfather: 'P. Grandfather',
      RelationType.paternalGrandmother: 'P. Grandmother',
      RelationType.grandson: 'Grandson',
      RelationType.granddaughter: 'Granddaughter',
    };
    return labels[relation] ?? relation.name;
  }
}

// Add this class to your family_tree_screen.dart file
class _CanvasBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Draw grid lines
    const gridSize = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw center markers
    final centerPaint =
        Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Center cross
    canvas.drawLine(
      Offset(centerX - 20, centerY),
      Offset(centerX + 20, centerY),
      centerPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - 20),
      Offset(centerX, centerY + 20),
      centerPaint,
    );

    // Corner indicators
    final cornerPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    // Top-left corner indicator
    canvas.drawCircle(const Offset(50, 50), 8, cornerPaint);
    // Top-right corner indicator
    canvas.drawCircle(Offset(size.width - 50, 50), 8, cornerPaint);
    // Bottom-left corner indicator
    canvas.drawCircle(Offset(50, size.height - 50), 8, cornerPaint);
    // Bottom-right corner indicator
    canvas.drawCircle(
      Offset(size.width - 50, size.height - 50),
      8,
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
