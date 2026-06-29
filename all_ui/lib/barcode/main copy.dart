import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

void main() {
  runApp(const BarcodeGeneratorApp());
}

class BarcodeGeneratorApp extends StatelessWidget {
  const BarcodeGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ProductBarcodeGenerator(),
    );
  }
}

class BarcodeTypeOption {
  final Barcode barcode;
  final String displayName;

  BarcodeTypeOption(this.barcode, this.displayName);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeTypeOption && displayName == other.displayName;

  @override
  int get hashCode => displayName.hashCode;
}

class ProductBarcodeGenerator extends StatefulWidget {
  const ProductBarcodeGenerator({Key? key}) : super(key: key);

  @override
  _ProductBarcodeGeneratorState createState() =>
      _ProductBarcodeGeneratorState();
}

class _ProductBarcodeGeneratorState extends State<ProductBarcodeGenerator> {
  // Barcode data and configuration
  final TextEditingController _barcodeController = TextEditingController();
  late BarcodeTypeOption _selectedBarcodeType;
  Color _barcodeColor = Colors.black;
  double _barcodeWidth = 200;
  double _barcodeHeight = 100;

  // List of supported barcode types
  late List<BarcodeTypeOption> _supportedTypes;

  @override
  void initState() {
    super.initState();
    // Initialize supported types with unique display names
    _supportedTypes = [
      BarcodeTypeOption(Barcode.code128(), 'CODE 128'),
      BarcodeTypeOption(Barcode.code39(), 'CODE 39'),
      BarcodeTypeOption(Barcode.ean13(), 'EAN 13'),
      BarcodeTypeOption(Barcode.ean8(), 'EAN 8'),
      BarcodeTypeOption(Barcode.upcA(), 'UPC-A'),
      BarcodeTypeOption(Barcode.qrCode(), 'QR Code'),
      BarcodeTypeOption(Barcode.codabar(), 'Codabar'),
    ];

    // Set initial selected type
    _selectedBarcodeType = _supportedTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Barcode Generator'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barcode Input TextField
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'Enter Barcode Data',
                hintText: 'Product ID or Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _barcodeController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Barcode Type Dropdown
            DropdownButtonFormField<BarcodeTypeOption>(
              value: _selectedBarcodeType,
              decoration: InputDecoration(
                labelText: 'Barcode Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items:
                  _supportedTypes.map((barcodeOption) {
                    return DropdownMenuItem(
                      value: barcodeOption,
                      child: Text(barcodeOption.displayName),
                    );
                  }).toList(),
              onChanged: (barcodeOption) {
                setState(() {
                  _selectedBarcodeType = barcodeOption!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Rest of the widget remains the same as in previous example...
            // (Dimensions, Color Picker, Barcode Display, Buttons)
            // ...

            // Generated Barcode
            const SizedBox(height: 30),
            Center(
              child:
                  _barcodeController.text.isNotEmpty
                      ? Column(
                        children: [
                          BarcodeWidget(
                            barcode: _selectedBarcodeType.barcode,
                            data: _barcodeController.text,
                            width: _barcodeWidth,
                            height: _barcodeHeight,
                            color: _barcodeColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Barcode Type: ${_selectedBarcodeType.displayName}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                      : const Text(
                        'Enter data to generate barcode',
                        style: TextStyle(color: Colors.grey),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // Other methods remain the same...
}
