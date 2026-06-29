import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class ProductBarcodeGenerator extends StatefulWidget {
  const ProductBarcodeGenerator({Key? key}) : super(key: key);

  @override
  _ProductBarcodeGeneratorState createState() =>
      _ProductBarcodeGeneratorState();
}

class _ProductBarcodeGeneratorState extends State<ProductBarcodeGenerator> {
  // Barcode data and configuration
  final TextEditingController _barcodeController = TextEditingController();
  Barcode _selectedBarcodeType = Barcode.code128();
  Color _barcodeColor = Colors.black;
  double _barcodeWidth = 200;
  double _barcodeHeight = 100;

  // List of supported barcode types
  final List<Barcode> _supportedTypes = [
    Barcode.code128(),
    Barcode.code39(),
    Barcode.ean13(),
    Barcode.ean8(),
    Barcode.upcA(),
    Barcode.qrCode(),
    Barcode.codabar(),
  ];

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
            DropdownButtonFormField<Barcode>(
              value: _selectedBarcodeType,
              decoration: InputDecoration(
                labelText: 'Barcode Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items:
                  _supportedTypes.map((barcode) {
                    return DropdownMenuItem(
                      value: barcode,
                      child: Text(barcode.name),
                    );
                  }).toList(),
              onChanged: (barcode) {
                setState(() {
                  _selectedBarcodeType = barcode!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Customization Sliders
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Barcode Width: ${_barcodeWidth.toStringAsFixed(0)}',
                  ),
                ),
                Slider(
                  value: _barcodeWidth,
                  min: 100,
                  max: 300,
                  divisions: 10,
                  label: _barcodeWidth.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      _barcodeWidth = value;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Barcode Height: ${_barcodeHeight.toStringAsFixed(0)}',
                  ),
                ),
                Slider(
                  value: _barcodeHeight,
                  min: 50,
                  max: 200,
                  divisions: 10,
                  label: _barcodeHeight.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      _barcodeHeight = value;
                    });
                  },
                ),
              ],
            ),

            // Color Picker
            const SizedBox(height: 20),
            Text(
              'Barcode Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildColorChoice(Colors.black),
                  _buildColorChoice(Colors.blue),
                  _buildColorChoice(Colors.red),
                  _buildColorChoice(Colors.green),
                  _buildColorChoice(Colors.purple),
                ],
              ),
            ),

            // Generated Barcode
            const SizedBox(height: 30),
            Center(
              child:
                  _barcodeController.text.isNotEmpty
                      ? BarcodeWidget(
                        barcode: _selectedBarcodeType,
                        data: _barcodeController.text,
                        width: _barcodeWidth,
                        height: _barcodeHeight,
                        color: _barcodeColor,
                      )
                      : const Text(
                        'Enter data to generate barcode',
                        style: TextStyle(color: Colors.grey),
                      ),
            ),

            // Generate and Save Buttons
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Generate'),
                  onPressed:
                      _barcodeController.text.isNotEmpty
                          ? () {
                            // Trigger barcode generation (already handled by setState)
                            setState(() {});
                          }
                          : null,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt),
                  label: const Text('Save'),
                  onPressed:
                      _barcodeController.text.isNotEmpty ? _saveBarcode : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Color selection widget
  Widget _buildColorChoice(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _barcodeColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border:
              _barcodeColor == color
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

  // Save barcode method (placeholder)
  void _saveBarcode() {
    // Implement barcode saving logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Barcode saved successfully!')),
    );
  }
}

// Dependencies to add in pubspec.yaml:
// dependencies:
//   barcode_widget: ^latest_version
