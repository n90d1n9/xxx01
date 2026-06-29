import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// MODELS
enum PaperSize { receipt58mm, receipt80mm, label40x30mm, label50x25mm, custom }

enum PrinterFirmware { epson, zebra, star, bixolon, custom }

class PrinterConfig {
  final PaperSize paperSize;
  final PrinterFirmware firmware;
  final double customWidth;
  final double customHeight;
  final double dpi;

  const PrinterConfig({
    required this.paperSize,
    required this.firmware,
    this.customWidth = 0,
    this.customHeight = 0,
    this.dpi = 203, // Common default DPI
  });

  PrinterConfig copyWith({
    PaperSize? paperSize,
    PrinterFirmware? firmware,
    double? customWidth,
    double? customHeight,
    double? dpi,
  }) {
    return PrinterConfig(
      paperSize: paperSize ?? this.paperSize,
      firmware: firmware ?? this.firmware,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      dpi: dpi ?? this.dpi,
    );
  }

  double get widthMm {
    switch (paperSize) {
      case PaperSize.receipt58mm:
        return 58;
      case PaperSize.receipt80mm:
        return 80;
      case PaperSize.label40x30mm:
        return 40;
      case PaperSize.label50x25mm:
        return 50;
      case PaperSize.custom:
        return customWidth;
    }
  }

  double get heightMm {
    switch (paperSize) {
      case PaperSize.receipt58mm:
      case PaperSize.receipt80mm:
        return 297; // A4 height as default for receipts
      case PaperSize.label40x30mm:
        return 30;
      case PaperSize.label50x25mm:
        return 25;
      case PaperSize.custom:
        return customHeight;
    }
  }

  double get widthPx => (widthMm * dpi) / 25.4; // Convert mm to pixels
  double get heightPx => (heightMm * dpi) / 25.4; // Convert mm to pixels
}

enum ElementType { text, image, barcode, qrCode, line, rectangle }

class DesignElement {
  final String id;
  final ElementType type;
  final Map<String, dynamic> properties;
  final Offset position;
  final Size size;

  DesignElement({
    String? id,
    required this.type,
    required this.properties,
    required this.position,
    required this.size,
  }) : id = id ?? const Uuid().v4();

  DesignElement copyWith({
    String? id,
    ElementType? type,
    Map<String, dynamic>? properties,
    Offset? position,
    Size? size,
  }) {
    return DesignElement(
      id: id ?? this.id,
      type: type ?? this.type,
      properties: properties ?? Map.from(this.properties),
      position: position ?? this.position,
      size: size ?? this.size,
    );
  }

  // Factory methods for common elements
  static DesignElement text({
    required String text,
    required Offset position,
    double fontSize = 12,
    bool bold = false,
    bool italic = false,
    TextAlign align = TextAlign.left,
  }) {
    return DesignElement(
      type: ElementType.text,
      properties: {
        'text': text,
        'fontSize': fontSize,
        'bold': bold,
        'italic': italic,
        'align': align,
      },
      position: position,
      size: const Size(100, 20), // Default size
    );
  }

  static DesignElement barcode({
    required String data,
    required Offset position,
    double width = 120,
    double height = 50,
  }) {
    return DesignElement(
      type: ElementType.barcode,
      properties: {'data': data, 'barcodeType': 'CODE128'},
      position: position,
      size: Size(width, height),
    );
  }

  static DesignElement qrCode({
    required String data,
    required Offset position,
    double size = 80,
  }) {
    return DesignElement(
      type: ElementType.qrCode,
      properties: {'data': data, 'errorCorrection': 'M'},
      position: position,
      size: Size(size, size),
    );
  }
}

class PrinterDesign {
  final String id;
  final String name;
  final PrinterConfig printerConfig;
  final List<DesignElement> elements;

  PrinterDesign({
    String? id,
    required this.name,
    required this.printerConfig,
    required this.elements,
  }) : id = id ?? const Uuid().v4();

  PrinterDesign copyWith({
    String? id,
    String? name,
    PrinterConfig? printerConfig,
    List<DesignElement>? elements,
  }) {
    return PrinterDesign(
      id: id ?? this.id,
      name: name ?? this.name,
      printerConfig: printerConfig ?? this.printerConfig,
      elements: elements ?? List.from(this.elements),
    );
  }
}

// RIVERPOD PROVIDERS
final printerConfigProvider = StateProvider<PrinterConfig>((ref) {
  return const PrinterConfig(
    paperSize: PaperSize.receipt80mm,
    firmware: PrinterFirmware.epson,
  );
});

final activeDesignProvider = StateProvider<PrinterDesign?>((ref) => null);

final designElementsProvider =
    StateNotifierProvider<DesignElementsNotifier, List<DesignElement>>((ref) {
      return DesignElementsNotifier([]);
    });

final selectedElementIdProvider = StateProvider<String?>((ref) => null);

final zoomLevelProvider = StateProvider<double>((ref) => 1.0);

class DesignElementsNotifier extends StateNotifier<List<DesignElement>> {
  DesignElementsNotifier(List<DesignElement> elements) : super(elements);

  void addElement(DesignElement element) {
    state = [...state, element];
  }

  void updateElement(DesignElement updatedElement) {
    state =
        state.map((element) {
          if (element.id == updatedElement.id) {
            return updatedElement;
          }
          return element;
        }).toList();
  }

  void updateElementPosition(String id, Offset newPosition) {
    state =
        state.map((element) {
          if (element.id == id) {
            return element.copyWith(position: newPosition);
          }
          return element;
        }).toList();
  }

  void updateElementSize(String id, Size newSize) {
    state =
        state.map((element) {
          if (element.id == id) {
            return element.copyWith(size: newSize);
          }
          return element;
        }).toList();
  }

  void removeElement(String id) {
    state = state.where((element) => element.id != id).toList();
  }

  void reorderElements(List<DesignElement> newOrder) {
    state = newOrder;
  }
}

// WIDGETS
class ThermalPrinterLayoutBuilder extends ConsumerWidget {
  const ThermalPrinterLayoutBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(printerConfigProvider);
    final elements = ref.watch(designElementsProvider);
    final selectedElementId = ref.watch(selectedElementIdProvider);
    final zoomLevel = ref.watch(zoomLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer Layout Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveDesign(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _previewAndPrint(context, ref),
          ),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Element palette
          SizedBox(
            width: 250,
            child: ElementPalette(
              onAddElement: (ElementType type) => _addNewElement(type, ref),
            ),
          ),
          // Main canvas area
          Expanded(
            child: Center(
              child: Column(
                children: [
                  // Zoom controls
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_out),
                          onPressed:
                              () =>
                                  ref.read(zoomLevelProvider.notifier).state =
                                      (ref.read(zoomLevelProvider) - 0.1).clamp(
                                        0.5,
                                        2.0,
                                      ),
                        ),
                        Text('${(zoomLevel * 100).toInt()}%'),
                        IconButton(
                          icon: const Icon(Icons.zoom_in),
                          onPressed:
                              () =>
                                  ref.read(zoomLevelProvider.notifier).state =
                                      (ref.read(zoomLevelProvider) + 0.1).clamp(
                                        0.5,
                                        2.0,
                                      ),
                        ),
                      ],
                    ),
                  ),
                  // Canvas
                  Expanded(
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: DesignCanvas(
                            config: config,
                            elements: elements,
                            selectedElementId: selectedElementId,
                            zoomLevel: zoomLevel,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Right sidebar - Properties panel
          SizedBox(
            width: 300,
            child: PropertyPanel(selectedElementId: selectedElementId),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              DropdownButton<PaperSize>(
                value: config.paperSize,
                onChanged: (PaperSize? newSize) {
                  if (newSize != null) {
                    ref.read(printerConfigProvider.notifier).state = config
                        .copyWith(paperSize: newSize);
                  }
                },
                items:
                    PaperSize.values.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(size.toString().split('.').last),
                      );
                    }).toList(),
              ),
              const SizedBox(width: 16),
              DropdownButton<PrinterFirmware>(
                value: config.firmware,
                onChanged: (PrinterFirmware? newFirmware) {
                  if (newFirmware != null) {
                    ref.read(printerConfigProvider.notifier).state = config
                        .copyWith(firmware: newFirmware);
                  }
                },
                items:
                    PrinterFirmware.values.map((firmware) {
                      return DropdownMenuItem(
                        value: firmware,
                        child: Text(firmware.toString().split('.').last),
                      );
                    }).toList(),
              ),
              const Spacer(),
              Text('Elements: ${elements.length}'),
            ],
          ),
        ),
      ),
    );
  }

  void _addNewElement(ElementType type, WidgetRef ref) {
    final center = Offset(
      ref.read(printerConfigProvider).widthPx / 2,
      ref.read(printerConfigProvider).heightPx / 4,
    );

    DesignElement newElement;

    switch (type) {
      case ElementType.text:
        newElement = DesignElement.text(text: 'Text Element', position: center);
        break;
      case ElementType.barcode:
        newElement = DesignElement.barcode(data: '12345678', position: center);
        break;
      case ElementType.qrCode:
        newElement = DesignElement.qrCode(
          data: 'https://example.com',
          position: center,
        );
        break;
      default:
        newElement = DesignElement(
          type: type,
          properties: {},
          position: center,
          size: const Size(100, 50),
        );
    }

    ref.read(designElementsProvider.notifier).addElement(newElement);
    ref.read(selectedElementIdProvider.notifier).state = newElement.id;
  }

  void _saveDesign(BuildContext context, WidgetRef ref) {
    // Save design implementation
    final elements = ref.read(designElementsProvider);
    final config = ref.read(printerConfigProvider);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save Design'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'Design Name'),
              onSubmitted: (name) {
                final design = PrinterDesign(
                  name: name,
                  printerConfig: config,
                  elements: elements,
                );

                // Here you would save the design to storage
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Design "$name" saved')));
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Would trigger save action from form
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _previewAndPrint(BuildContext context, WidgetRef ref) {
    // Preview and print implementation
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Print Preview'),
            content: SizedBox(
              width: 400,
              height: 600,
              child: PrintPreview(
                config: ref.read(printerConfigProvider),
                elements: ref.read(designElementsProvider),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Would trigger print action
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Printing...')));
                },
                child: const Text('Print'),
              ),
            ],
          ),
    );
  }
}

class ElementPalette extends StatelessWidget {
  final Function(ElementType) onAddElement;

  const ElementPalette({required this.onAddElement, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListView(
        padding: const EdgeInsets.all(12.0),
        children: [
          const Text(
            'Elements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          _buildDraggableElement(ElementType.text, 'Text', Icons.text_fields),
          _buildDraggableElement(ElementType.image, 'Image', Icons.image),
          _buildDraggableElement(
            ElementType.barcode,
            'Barcode',
            Icons.barcode_reader,
          ),
          _buildDraggableElement(ElementType.qrCode, 'QR Code', Icons.qr_code),
          _buildDraggableElement(
            ElementType.line,
            'Line',
            Icons.horizontal_rule,
          ),
          _buildDraggableElement(
            ElementType.rectangle,
            'Rectangle',
            Icons.rectangle_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableElement(ElementType type, String label, IconData icon) {
    return Draggable<ElementType>(
      data: type,
      feedback: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white.withValues(alpha: 0.8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), const SizedBox(width: 8), Text(label)],
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(icon),
          title: Text(label),
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onAddElement(type),
          ),
        ),
      ),
    );
  }
}

class DesignCanvas extends ConsumerWidget {
  final PrinterConfig config;
  final List<DesignElement> elements;
  final String? selectedElementId;
  final double zoomLevel;

  const DesignCanvas({
    required this.config,
    required this.elements,
    required this.selectedElementId,
    required this.zoomLevel,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasWidth = config.widthPx * zoomLevel;
    final canvasHeight = config.heightPx * zoomLevel;

    return Stack(
      children: [
        // Paper background
        Container(
          width: canvasWidth,
          height: canvasHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),

        // Grid lines (for visual guidance)
        CustomPaint(
          size: Size(canvasWidth, canvasHeight),
          painter: GridPainter(gridSize: 10 * zoomLevel),
        ),

        // DragTarget for adding new elements
        SizedBox(
          width: canvasWidth,
          height: canvasHeight,
          child: DragTarget<ElementType>(
            onAccept: (type) {
              final center = Offset(canvasWidth / 2, canvasHeight / 4);
              _addNewElement(type, center, ref);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(color: Colors.transparent);
            },
          ),
        ),

        // Render all elements
        ...elements.map((element) {
          final isSelected = element.id == selectedElementId;

          return Positioned(
            left: element.position.dx * zoomLevel,
            top: element.position.dy * zoomLevel,
            child: DraggableDesignElement(
              element: element,
              isSelected: isSelected,
              zoomLevel: zoomLevel,
              onSelected: () {
                ref.read(selectedElementIdProvider.notifier).state = element.id;
              },
              onPositionChanged: (newPosition) {
                ref
                    .read(designElementsProvider.notifier)
                    .updateElementPosition(
                      element.id,
                      Offset(
                        newPosition.dx / zoomLevel,
                        newPosition.dy / zoomLevel,
                      ),
                    );
              },
              onSizeChanged: (newSize) {
                ref
                    .read(designElementsProvider.notifier)
                    .updateElementSize(
                      element.id,
                      Size(
                        newSize.width / zoomLevel,
                        newSize.height / zoomLevel,
                      ),
                    );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  void _addNewElement(ElementType type, Offset position, WidgetRef ref) {
    DesignElement newElement;

    switch (type) {
      case ElementType.text:
        newElement = DesignElement.text(
          text: 'New Text',
          position: Offset(position.dx / zoomLevel, position.dy / zoomLevel),
        );
        break;
      case ElementType.barcode:
        newElement = DesignElement.barcode(
          data: '12345678',
          position: Offset(position.dx / zoomLevel, position.dy / zoomLevel),
        );
        break;
      case ElementType.qrCode:
        newElement = DesignElement.qrCode(
          data: 'https://example.com',
          position: Offset(position.dx / zoomLevel, position.dy / zoomLevel),
        );
        break;
      default:
        newElement = DesignElement(
          type: type,
          properties: {},
          position: Offset(position.dx / zoomLevel, position.dy / zoomLevel),
          size: const Size(100, 50),
        );
    }

    ref.read(designElementsProvider.notifier).addElement(newElement);
    ref.read(selectedElementIdProvider.notifier).state = newElement.id;
  }
}

class GridPainter extends CustomPainter {
  final double gridSize;

  GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.2)
          ..strokeWidth = 1;

    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DraggableDesignElement extends StatefulWidget {
  final DesignElement element;
  final bool isSelected;
  final double zoomLevel;
  final VoidCallback onSelected;
  final Function(Offset) onPositionChanged;
  final Function(Size) onSizeChanged;

  const DraggableDesignElement({
    required this.element,
    required this.isSelected,
    required this.zoomLevel,
    required this.onSelected,
    required this.onPositionChanged,
    required this.onSizeChanged,
    super.key,
  });

  @override
  State<DraggableDesignElement> createState() => _DraggableDesignElementState();
}

class _DraggableDesignElementState extends State<DraggableDesignElement> {
  late Offset _startPosition;
  late Size _startSize;
  bool _resizing = false;

  @override
  Widget build(BuildContext context) {
    final width = widget.element.size.width * widget.zoomLevel;
    final height = widget.element.size.height * widget.zoomLevel;

    return GestureDetector(
      onTap: widget.onSelected,
      onPanStart: (details) {
        _startPosition = widget.element.position;
        _startSize = widget.element.size;
        setState(() => _resizing = false);
      },
      onPanUpdate: (details) {
        if (_resizing) {
          // Resize the element
          final newWidth =
              _startSize.width + details.delta.dx / widget.zoomLevel;
          final newHeight =
              _startSize.height + details.delta.dy / widget.zoomLevel;
          widget.onSizeChanged(
            Size(
              newWidth > 10 ? newWidth : 10,
              newHeight > 10 ? newHeight : 10,
            ),
          );
        } else {
          // Move the element
          final newPosition = Offset(
            _startPosition.dx + details.delta.dx / widget.zoomLevel,
            _startPosition.dy + details.delta.dy / widget.zoomLevel,
          );
          widget.onPositionChanged(newPosition);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border:
              widget.isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : Border.all(
                    color: Colors.grey.withValues(alpha: 0.5),
                    width: 1,
                  ),
        ),
        child: Stack(
          children: [
            // The actual element content
            SizedBox.expand(child: _buildElementWidget()),

            // Resize handle
            if (widget.isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onPanStart: (details) {
                    _startSize = widget.element.size;
                    setState(() => _resizing = true);
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.open_with,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildElementWidget() {
    switch (widget.element.type) {
      case ElementType.text:
        final text = widget.element.properties['text'] as String? ?? '';
        final fontSize =
            widget.element.properties['fontSize'] as double? ?? 12.0;
        final bold = widget.element.properties['bold'] as bool? ?? false;
        final italic = widget.element.properties['italic'] as bool? ?? false;

        return Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize * widget.zoomLevel,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        );

      case ElementType.barcode:
        final data = widget.element.properties['data'] as String? ?? '';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.barcode_reader, size: 24),
            const SizedBox(height: 4),
            Text(data, style: const TextStyle(fontSize: 10)),
          ],
        );

      case ElementType.qrCode:
        return const Center(child: Icon(Icons.qr_code, size: 24));

      case ElementType.image:
        return const Center(child: Icon(Icons.image, size: 24));

      case ElementType.line:
        return const Center(child: Divider(thickness: 2, color: Colors.black));

      case ElementType.rectangle:
        return Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        );

      default:
        return const Center(child: Text('Unknown Element'));
    }
  }
}

class PropertyPanel extends ConsumerWidget {
  final String? selectedElementId;

  const PropertyPanel({required this.selectedElementId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedElementId == null) {
      return const Card(
        margin: EdgeInsets.all(8.0),
        child: Center(child: Text('Select an element to edit properties')),
      );
    }

    // Find the selected element
    final elements = ref.watch(designElementsProvider);
    final selectedElement = elements.firstWhere(
      (element) => element.id == selectedElementId,
      orElse: () => throw Exception('Selected element not found'),
    );

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            '${selectedElement.type.toString().split('.').last} Properties',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          // Common properties
          _buildPropertySection('Position', [
            _buildNumberField(
              'X',
              selectedElement.position.dx.toStringAsFixed(1),
              (value) {
                final x = double.tryParse(value) ?? selectedElement.position.dx;
                ref
                    .read(designElementsProvider.notifier)
                    .updateElementPosition(
                      selectedElement.id,
                      Offset(x, selectedElement.position.dy),
                    );
              },
            ),
            _buildNumberField(
              'Y',
              selectedElement.position.dy.toStringAsFixed(1),
              (value) {
                final y = double.tryParse(value) ?? selectedElement.position.dy;
                ref
                    .read(designElementsProvider.notifier)
                    .updateElementPosition(
                      selectedElement.id,
                      Offset(selectedElement.position.dx, y),
                    );
              },
            ),
          ]),

          _buildPropertySection('Size', [
            _buildNumberField(
              'Width',
              selectedElement.size.width.toStringAsFixed(1),
              (value) {
                final width =
                    double.tryParse(value) ?? selectedElement.size.width;
                ref
                    .read(designElementsProvider.notifier)
                    .updateElementSize(
                      selectedElement.id,
                      Size(width, selectedElement.size.height),
                    );
              },
            ),
            _buildNumberField(
              'Height',
              selectedElement.size.height.toStringAsFixed(1),
              (value) {
                final height =
                    double.tryParse(value) ?? selectedElement.size.height;
                ref
                    .read(designElementsProvider.notifier)
                    .updateElementSize(
                      selectedElement.id,
                      Size(selectedElement.size.width, height),
                    );
              },
            ),
          ]),

          // Element-specific properties
          ..._buildElementSpecificProperties(selectedElement, ref),

          const SizedBox(height: 20),

          // Delete button
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Delete Element'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(designElementsProvider.notifier)
                  .removeElement(selectedElement.id);
              ref.read(selectedElementIdProvider.notifier).state = null;
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildElementSpecificProperties(
    DesignElement element,
    WidgetRef ref,
  ) {
    switch (element.type) {
      case ElementType.text:
        return [
          _buildPropertySection('Text', [
            TextField(
              decoration: const InputDecoration(labelText: 'Content'),
              controller: TextEditingController(
                text: element.properties['text'] ?? '',
              ),
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['text'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
            ),
          ]),
          _buildPropertySection('Formatting', [
            _buildNumberField(
              'Font Size',
              (element.properties['fontSize'] ?? 12.0).toString(),
              (value) {
                final fontSize = double.tryParse(value) ?? 12.0;
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['fontSize'] = fontSize;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: element.properties['bold'] ?? false,
                  onChanged: (value) {
                    final updatedProperties = Map<String, dynamic>.from(
                      element.properties,
                    );
                    updatedProperties['bold'] = value ?? false;
                    _updateElementProperties(
                      ref,
                      element.id,
                      updatedProperties,
                    );
                  },
                ),
                const Text('Bold'),
                const SizedBox(width: 16),
                Checkbox(
                  value: element.properties['italic'] ?? false,
                  onChanged: (value) {
                    final updatedProperties = Map<String, dynamic>.from(
                      element.properties,
                    );
                    updatedProperties['italic'] = value ?? false;
                    _updateElementProperties(
                      ref,
                      element.id,
                      updatedProperties,
                    );
                  },
                ),
                const Text('Italic'),
              ],
            ),
            DropdownButton<TextAlign>(
              value: element.properties['align'] ?? TextAlign.left,
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['align'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
              items: [
                const DropdownMenuItem(
                  value: TextAlign.left,
                  child: Text('Left'),
                ),
                const DropdownMenuItem(
                  value: TextAlign.center,
                  child: Text('Center'),
                ),
                const DropdownMenuItem(
                  value: TextAlign.right,
                  child: Text('Right'),
                ),
              ],
            ),
          ]),
        ];

      case ElementType.barcode:
        return [
          _buildPropertySection('Barcode', [
            TextField(
              decoration: const InputDecoration(labelText: 'Data'),
              controller: TextEditingController(
                text: element.properties['data'] ?? '',
              ),
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['data'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
            ),
            DropdownButton<String>(
              value: element.properties['barcodeType'] ?? 'CODE128',
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['barcodeType'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
              items: [
                const DropdownMenuItem(
                  value: 'CODE128',
                  child: Text('CODE128'),
                ),
                const DropdownMenuItem(value: 'CODE39', child: Text('CODE39')),
                const DropdownMenuItem(value: 'EAN13', child: Text('EAN-13')),
                const DropdownMenuItem(value: 'UPC', child: Text('UPC')),
              ],
            ),
          ]),
        ];

      case ElementType.qrCode:
        return [
          _buildPropertySection('QR Code', [
            TextField(
              decoration: const InputDecoration(labelText: 'Data'),
              controller: TextEditingController(
                text: element.properties['data'] ?? '',
              ),
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['data'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
            ),
            DropdownButton<String>(
              value: element.properties['errorCorrection'] ?? 'M',
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['errorCorrection'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
              items: [
                const DropdownMenuItem(value: 'L', child: Text('Low')),
                const DropdownMenuItem(value: 'M', child: Text('Medium')),
                const DropdownMenuItem(value: 'Q', child: Text('Quartile')),
                const DropdownMenuItem(value: 'H', child: Text('High')),
              ],
            ),
          ]),
        ];

      case ElementType.image:
        return [
          _buildPropertySection('Image', [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
              onPressed: () {
                // Image upload functionality
              },
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: element.properties['scaling'] ?? 'contain',
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['scaling'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
              items: [
                const DropdownMenuItem(
                  value: 'contain',
                  child: Text('Contain'),
                ),
                const DropdownMenuItem(value: 'fill', child: Text('Fill')),
                const DropdownMenuItem(value: 'cover', child: Text('Cover')),
              ],
            ),
          ]),
        ];

      case ElementType.line:
        return [
          _buildPropertySection('Line', [
            _buildNumberField(
              'Thickness',
              (element.properties['thickness'] ?? 1.0).toString(),
              (value) {
                final thickness = double.tryParse(value) ?? 1.0;
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['thickness'] = thickness;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
            ),
            DropdownButton<String>(
              value: element.properties['lineStyle'] ?? 'solid',
              onChanged: (value) {
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['lineStyle'] = value;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
              items: [
                const DropdownMenuItem(value: 'solid', child: Text('Solid')),
                const DropdownMenuItem(value: 'dashed', child: Text('Dashed')),
                const DropdownMenuItem(value: 'dotted', child: Text('Dotted')),
              ],
            ),
          ]),
        ];

      case ElementType.rectangle:
        return [
          _buildPropertySection('Rectangle', [
            _buildNumberField(
              'Border Thickness',
              (element.properties['borderThickness'] ?? 1.0).toString(),
              (value) {
                final thickness = double.tryParse(value) ?? 1.0;
                final updatedProperties = Map<String, dynamic>.from(
                  element.properties,
                );
                updatedProperties['borderThickness'] = thickness;
                _updateElementProperties(ref, element.id, updatedProperties);
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: element.properties['filled'] ?? false,
                  onChanged: (value) {
                    final updatedProperties = Map<String, dynamic>.from(
                      element.properties,
                    );
                    updatedProperties['filled'] = value ?? false;
                    _updateElementProperties(
                      ref,
                      element.id,
                      updatedProperties,
                    );
                  },
                ),
                const Text('Filled'),
              ],
            ),
          ]),
        ];

      default:
        return [];
    }
  }

  void _updateElementProperties(
    WidgetRef ref,
    String elementId,
    Map<String, dynamic> properties,
  ) {
    final elements = ref.read(designElementsProvider);
    final elementIndex = elements.indexWhere((e) => e.id == elementId);

    if (elementIndex != -1) {
      final updatedElement = elements[elementIndex].copyWith(
        properties: properties,
      );
      ref.read(designElementsProvider.notifier).updateElement(updatedElement);
    }
  }

  Widget _buildPropertySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildNumberField(
    String label,
    String initialValue,
    Function(String) onChanged,
  ) {
    return TextField(
      decoration: InputDecoration(labelText: label),
      controller: TextEditingController(text: initialValue),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}

class PrintPreview extends StatelessWidget {
  final PrinterConfig config;
  final List<DesignElement> elements;

  const PrintPreview({required this.config, required this.elements, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: config.widthPx,
        height: config.heightPx,
        color: Colors.white,
        child: Stack(
          children:
              elements.map((element) {
                return Positioned(
                  left: element.position.dx,
                  top: element.position.dy,
                  width: element.size.width,
                  height: element.size.height,
                  child: _buildElementWidget(element),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildElementWidget(DesignElement element) {
    switch (element.type) {
      case ElementType.text:
        final text = element.properties['text'] as String? ?? '';
        final fontSize = element.properties['fontSize'] as double? ?? 12.0;
        final bold = element.properties['bold'] as bool? ?? false;
        final italic = element.properties['italic'] as bool? ?? false;
        final align =
            element.properties['align'] as TextAlign? ?? TextAlign.left;

        return Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
          textAlign: align,
        );

      case ElementType.barcode:
        final data = element.properties['data'] as String? ?? '';

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.barcode_reader),
            Text(data, style: const TextStyle(fontSize: 10)),
          ],
        );

      case ElementType.qrCode:
        return const Center(child: Icon(Icons.qr_code));

      case ElementType.image:
        return const Center(child: Icon(Icons.image));

      case ElementType.line:
        final thickness = element.properties['thickness'] as double? ?? 1.0;

        return Center(child: Container(height: thickness, color: Colors.black));

      case ElementType.rectangle:
        final borderThickness =
            element.properties['borderThickness'] as double? ?? 1.0;
        final filled = element.properties['filled'] as bool? ?? false;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: borderThickness),
            color: filled ? Colors.black : null,
          ),
        );

      default:
        return const Center(child: Text('Unknown Element'));
    }
  }
}

// Main functions for printing and export
class PrinterService {
  static Future<void> printDesign(PrinterDesign design) async {
    // Implement printer-specific code here
    switch (design.printerConfig.firmware) {
      case PrinterFirmware.epson:
        await _printEpson(design);
        break;
      case PrinterFirmware.zebra:
        await _printZebra(design);
        break;
      case PrinterFirmware.star:
        await _printStar(design);
        break;
      case PrinterFirmware.bixolon:
        await _printBixolon(design);
        break;
      case PrinterFirmware.custom:
        // Custom firmware implementation
        break;
    }
  }

  static Future<void> _printEpson(PrinterDesign design) async {
    // Implement Epson ESC/POS printing
    // Example pseudocode:
    // final esc = ESCPOSCommand();
    // for (final element in design.elements) {
    //   switch (element.type) {
    //     case ElementType.text:
    //       esc.addText(element.properties['text'],
    //           position: element.position, font: element.properties);
    //       break;
    //     // ...handle other element types
    //   }
    // }
    // await esc.print();
  }

  static Future<void> _printZebra(PrinterDesign design) async {
    // Implement Zebra ZPL printing
    // Example pseudocode:
    // final zpl = ZPLCommand();
    // zpl.setLabelSize(design.printerConfig.widthMm, design.printerConfig.heightMm);
    // for (final element in design.elements) {
    //   // Generate ZPL for each element
    // }
    // await zpl.print();
  }

  static Future<void> _printStar(PrinterDesign design) async {
    // Implement Star printing
  }

  static Future<void> _printBixolon(PrinterDesign design) async {
    // Implement Bixolon printing
  }

  static String exportToESCPOS(PrinterDesign design) {
    // Implementation to convert design to ESC/POS commands
    final buffer = StringBuffer();

    // Initialization
    buffer.write('\x1B@'); // Initialize printer

    // Process each element
    for (final element in design.elements) {
      switch (element.type) {
        case ElementType.text:
          final text = element.properties['text'] as String? ?? '';
          final bold = element.properties['bold'] as bool? ?? false;

          // Position cursor (simplified)
          buffer.write(
            '\x1B\$${element.position.dx.toInt()}${element.position.dy.toInt()}',
          );

          // Set text properties
          if (bold) {
            buffer.write('\x1BE\x01'); // Bold on
          }

          // Write text
          buffer.write(text);

          // Reset text properties
          if (bold) {
            buffer.write('\x1BE\x00'); // Bold off
          }
          break;

        case ElementType.line:
          // Draw line with ESC/POS
          break;

        // Handle other element types
        default:
          break;
      }
    }

    // Finalization
    buffer.write('\x1BD\x01'); // Cut paper

    return buffer.toString();
  }

  static String exportToZPL(PrinterDesign design) {
    // Implementation to convert design to ZPL commands
    final buffer = StringBuffer();

    // Initialize ZPL
    buffer.write('^XA');

    // Set label size
    buffer.write('^PW${(design.printerConfig.widthPx).toInt()}');

    // Process each element
    for (final element in design.elements) {
      switch (element.type) {
        case ElementType.text:
          final text = element.properties['text'] as String? ?? '';
          final x = element.position.dx.toInt();
          final y = element.position.dy.toInt();

          // Position and print text
          buffer.write('^FO$x,$y^FD$text^FS');
          break;

        case ElementType.barcode:
          final data = element.properties['data'] as String? ?? '';
          final x = element.position.dx.toInt();
          final y = element.position.dy.toInt();

          // Code 128 barcode
          buffer.write('^FO$x,$y^BC^FD$data^FS');
          break;

        case ElementType.qrCode:
          final data = element.properties['data'] as String? ?? '';
          final x = element.position.dx.toInt();
          final y = element.position.dy.toInt();

          // QR code
          buffer.write('^FO$x,$y^BQN,2,8^FD$data^FS');
          break;

        // Handle other element types
        default:
          break;
      }
    }

    // End ZPL
    buffer.write('^XZ');

    return buffer.toString();
  }
}

// Storage service for saving and loading designs
class DesignStorageService {
  static Future<void> saveDesign(PrinterDesign design) async {
    // Convert design to JSON
    final designJson = _designToJson(design);

    // Save to storage (simplified example)
    // In a real app, this would use SharedPreferences, local database, or cloud storage
    print('Saving design: $designJson');
  }

  static Future<List<PrinterDesign>> loadDesigns() async {
    // In a real app, this would load from storage
    return [];
  }

  static Future<PrinterDesign?> loadDesign(String id) async {
    // Load specific design
    return null;
  }

  static Map<String, dynamic> _designToJson(PrinterDesign design) {
    return {
      'id': design.id,
      'name': design.name,
      'printerConfig': {
        'paperSize': design.printerConfig.paperSize.toString(),
        'firmware': design.printerConfig.firmware.toString(),
        'customWidth': design.printerConfig.customWidth,
        'customHeight': design.printerConfig.customHeight,
        'dpi': design.printerConfig.dpi,
      },
      'elements':
          design.elements
              .map(
                (element) => {
                  'id': element.id,
                  'type': element.type.toString(),
                  'properties': element.properties,
                  'position': {
                    'dx': element.position.dx,
                    'dy': element.position.dy,
                  },
                  'size': {
                    'width': element.size.width,
                    'height': element.size.height,
                  },
                },
              )
              .toList(),
    };
  }

  static PrinterDesign _designFromJson(Map<String, dynamic> json) {
    return PrinterDesign(
      id: json['id'],
      name: json['name'],
      printerConfig: PrinterConfig(
        paperSize: PaperSize.values.firstWhere(
          (e) => e.toString() == json['printerConfig']['paperSize'],
          orElse: () => PaperSize.receipt80mm,
        ),
        firmware: PrinterFirmware.values.firstWhere(
          (e) => e.toString() == json['printerConfig']['firmware'],
          orElse: () => PrinterFirmware.epson,
        ),
        customWidth: json['printerConfig']['customWidth'],
        customHeight: json['printerConfig']['customHeight'],
        dpi: json['printerConfig']['dpi'],
      ),
      elements:
          (json['elements'] as List).map((elementJson) {
            return DesignElement(
              id: elementJson['id'],
              type: ElementType.values.firstWhere(
                (e) => e.toString() == elementJson['type'],
                orElse: () => ElementType.text,
              ),
              properties: Map<String, dynamic>.from(elementJson['properties']),
              position: Offset(
                elementJson['position']['dx'],
                elementJson['position']['dy'],
              ),
              size: Size(
                elementJson['size']['width'],
                elementJson['size']['height'],
              ),
            );
          }).toList(),
    );
  }
}

void main() {
  runApp(const ProviderScope(child: ThermalPrinterApp()));
}

class ThermalPrinterApp extends StatelessWidget {
  const ThermalPrinterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thermal Printer Layout Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ThermalPrinterLayoutBuilder(),
    );
  }
}
