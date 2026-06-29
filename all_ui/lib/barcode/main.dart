import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String description;
  final int? minLength;
  final int? maxLength;
  final String? validationRegex;
  final String? exampleInput;

  const BarcodeTypeOption({
    required this.barcode,
    required this.displayName,
    required this.description,
    this.minLength,
    this.maxLength,
    this.validationRegex,
    this.exampleInput,
  });

  String? validate(String input) {
    // Check length constraints
    if (minLength != null && input.length < minLength!) {
      return 'Minimum length is $minLength characters';
    }
    if (maxLength != null && input.length > maxLength!) {
      return 'Maximum length is $maxLength characters';
    }

    // Check regex validation if provided
    if (validationRegex != null) {
      final RegExp regex = RegExp(validationRegex!);
      if (!regex.hasMatch(input)) {
        return 'Invalid input format';
      }
    }

    return null;
  }

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
  final FocusNode _barcodeInputFocusNode = FocusNode();
  bool _isValidInput = false;
  late BarcodeTypeOption _selectedBarcodeType;
  Color _barcodeColor = Colors.black;
  double _barcodeWidth = 200;
  double _barcodeHeight = 100;

  // List of supported barcode types with detailed constraints
  late List<BarcodeTypeOption> _supportedTypes;

  @override
  void initState() {
    super.initState();
    // Initialize supported types with detailed constraints
    _supportedTypes = [
      BarcodeTypeOption(
        barcode: Barcode.code128(),
        displayName: 'CODE 128',
        description: 'Supports all 128 ASCII characters',
        minLength: 1,
        maxLength: 50,
        exampleInput: 'PRODUCT123',
      ),
      BarcodeTypeOption(
        barcode: Barcode.code39(),
        displayName: 'CODE 39',
        description: 'Alphanumeric, supports special characters',
        minLength: 1,
        maxLength: 30,
        validationRegex: r'^[A-Z0-9\-\.\$\/\+\%\s]+$',
        exampleInput: 'PROD-123',
      ),
      BarcodeTypeOption(
        barcode: Barcode.ean13(),
        displayName: 'EAN 13',
        description: 'European Article Number, 13 digits',
        minLength: 13,
        maxLength: 13,
        validationRegex: r'^\d{13}$',
        exampleInput: '1234567890123',
      ),
      BarcodeTypeOption(
        barcode: Barcode.ean8(),
        displayName: 'EAN 8',
        description: 'European Article Number, 8 digits',
        minLength: 8,
        maxLength: 8,
        validationRegex: r'^\d{8}$',
        exampleInput: '12345678',
      ),
      BarcodeTypeOption(
        barcode: Barcode.upcA(),
        displayName: 'UPC-A',
        description: 'Universal Product Code, 12 digits',
        minLength: 12,
        maxLength: 12,
        validationRegex: r'^\d{12}$',
        exampleInput: '123456789012',
      ),
      BarcodeTypeOption(
        barcode: Barcode.qrCode(),
        displayName: 'QR Code',
        description: 'Two-dimensional matrix barcode',
        minLength: 1,
        maxLength: 4296,
        exampleInput: 'https://example.com',
      ),
      BarcodeTypeOption(
        barcode: Barcode.codabar(),
        displayName: 'Codabar',
        description: 'Used in libraries, medicine, shipping',
        minLength: 1,
        maxLength: 30,
        validationRegex: r'^[0-9ABCD$:/.+\-]+$',
        exampleInput: 'A123456B',
      ),
    ];

    // Set initial selected type
    _selectedBarcodeType = _supportedTypes.first;

    // Add listener to validate input
    _barcodeController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _barcodeController.removeListener(_validateInput);
    _barcodeController.dispose();
    _barcodeInputFocusNode.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _isValidInput =
          _selectedBarcodeType.validate(_barcodeController.text) == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barcode Generator'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  // Clear the input when type changes
                  _barcodeController.clear();
                  _isValidInput = false;
                });
              },
            ),
            const SizedBox(height: 10),

            // Type Description
            Text(
              _selectedBarcodeType.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),

            // Barcode Input TextField
            TextField(
              controller: _barcodeController,
              focusNode: _barcodeInputFocusNode,
              decoration: InputDecoration(
                labelText: 'Enter Barcode Data',
                hintText: _selectedBarcodeType.exampleInput,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                errorText:
                    _barcodeController.text.isNotEmpty
                        ? _selectedBarcodeType.validate(_barcodeController.text)
                        : null,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _barcodeController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Generated Barcode
            Center(child: _buildBarcodePreview()),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodePreview() {
    // Only show barcode if input is valid
    if (_isValidInput) {
      try {
        return Column(
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
        );
      } catch (e) {
        return Text(
          'Error generating barcode: ${e.toString()}',
          style: const TextStyle(color: Colors.red),
        );
      }
    }

    return const Text(
      'Enter valid data to generate barcode',
      style: TextStyle(color: Colors.grey),
    );
  }
}
