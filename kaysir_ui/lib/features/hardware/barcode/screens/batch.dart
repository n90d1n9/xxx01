import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Model for scanned items
class ScannedItem {
  final String code;
  final String type; // 'barcode' or 'qrcode'
  final DateTime timestamp;
  String? productName;
  double? price;

  ScannedItem({
    required this.code,
    required this.type,
    required this.timestamp,
    this.productName,
    this.price,
  });
}

// Label template model
class LabelTemplate {
  final String name;
  final double width;
  final double height;
  final bool includePrice;
  final bool includeBarcode;
  final bool includeQRCode;
  final String? customHeader;

  LabelTemplate({
    required this.name,
    required this.width,
    required this.height,
    this.includePrice = true,
    this.includeBarcode = true,
    this.includeQRCode = false,
    this.customHeader,
  });
}

class EnhancedBarcodeScanner extends StatefulWidget {
  const EnhancedBarcodeScanner({super.key});

  @override
  EnhancedBarcodeScannerState createState() => EnhancedBarcodeScannerState();
}

class EnhancedBarcodeScannerState extends State<EnhancedBarcodeScanner> {
  final List<ScannedItem> _scannedItems = [];
  bool _isBatchMode = false;
  MobileScannerController controller = MobileScannerController();

  // Predefined label templates
  final List<LabelTemplate> templates = [
    LabelTemplate(
      name: 'Standard Label',
      width: 50,
      height: 30,
      includePrice: true,
      includeBarcode: true,
    ),
    LabelTemplate(
      name: 'Small Price Tag',
      width: 40,
      height: 20,
      includePrice: true,
      includeBarcode: false,
    ),
    LabelTemplate(
      name: 'Inventory Label',
      width: 60,
      height: 40,
      includePrice: false,
      includeBarcode: true,
      includeQRCode: true,
      customHeader: 'Inventory',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isBatchMode ? 'Batch Scanning Mode' : 'Scanner'),
        actions: [
          IconButton(
            icon: Icon(_isBatchMode ? Icons.clear_all : Icons.batch_prediction),
            onPressed: () {
              setState(() {
                _isBatchMode = !_isBatchMode;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _showPrintDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  _handleScannedCode(barcode);
                }
              },
            ),
          ),
          if (_isBatchMode) _buildBatchList(),
        ],
      ),
    );
  }

  Widget _buildBatchList() {
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.grey[200],
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Scanned Items: ${_scannedItems.length}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _scannedItems.length,
                itemBuilder: (context, index) {
                  final item = _scannedItems[index];
                  return ListTile(
                    title: Text(item.code),
                    subtitle: Text(
                      '${item.type} - ${item.timestamp.toString()}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _scannedItems.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScannedCode(Barcode barcode) {
    final scannedItem = ScannedItem(
      code: barcode.rawValue ?? '',
      type: barcode.type == BarcodeType.product ? 'qrcode' : 'barcode',
      timestamp: DateTime.now(),
    );

    setState(() {
      _scannedItems.add(scannedItem);
    });

    if (!_isBatchMode) {
      // Show immediate result for single scan mode
      _showScanResult(scannedItem);
    }
  }

  void _showScanResult(ScannedItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Scan Result'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code: ${item.code}'),
                Text('Type: ${item.type}'),
                TextField(
                  decoration: InputDecoration(labelText: 'Product Name'),
                  onChanged: (value) => item.productName = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => item.price = double.tryParse(value),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Print'),
                onPressed: () {
                  Navigator.pop(context);
                  _printLabel(item);
                },
              ),
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Label Template'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  templates.map((template) {
                    return ListTile(
                      title: Text(template.name),
                      onTap: () {
                        Navigator.pop(context);
                        _printBatchLabels(template);
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Future<void> _printLabel(ScannedItem item, [LabelTemplate? template]) async {
    template ??= templates[0]; // Use default template if none specified

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          template.width * PdfPageFormat.mm,
          template.height * PdfPageFormat.mm,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (template!.customHeader != null)
                pw.Text(
                  template.customHeader!,
                  style: pw.TextStyle(fontSize: 10),
                ),
              if (item.productName != null)
                pw.Text(item.productName!, style: pw.TextStyle(fontSize: 12)),
              if (template.includePrice && item.price != null)
                pw.Text(
                  '\$${item.price!.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              if (template.includeBarcode)
                pw.BarcodeWidget(
                  data: item.code,
                  width: 80,
                  height: 40,
                  barcode: pw.Barcode.code128(),
                ),
              if (template.includeQRCode)
                pw.BarcodeWidget(
                  data: item.code,
                  width: 50,
                  height: 50,
                  barcode: pw.Barcode.qrCode(),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _printBatchLabels(LabelTemplate template) async {
    final pdf = pw.Document();

    // Create a page for each scanned item
    for (var item in _scannedItems) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            template.width * PdfPageFormat.mm,
            template.height * PdfPageFormat.mm,
          ),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (template.customHeader != null)
                  pw.Text(
                    template.customHeader!,
                    style: pw.TextStyle(fontSize: 10),
                  ),
                if (item.productName != null)
                  pw.Text(item.productName!, style: pw.TextStyle(fontSize: 12)),
                if (template.includePrice && item.price != null)
                  pw.Text(
                    '\$${item.price!.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                if (template.includeBarcode)
                  pw.BarcodeWidget(
                    data: item.code,
                    width: 80,
                    height: 40,
                    barcode: pw.Barcode.code128(),
                  ),
                if (template.includeQRCode)
                  pw.BarcodeWidget(
                    data: item.code,
                    width: 50,
                    height: 50,
                    barcode: pw.Barcode.qrCode(),
                  ),
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
