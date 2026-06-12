import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../services/barcode_services.dart';
import '../models/product.dart';

class ProductLabelWidget extends StatelessWidget {
  final Product product;
  final double width;
  final double height;

  const ProductLabelWidget({
    super.key,
    required this.product,
    this.width = 300,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            product.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          FutureBuilder<ui.Image>(
            future: BarcodeService.generateBarcode(
              data: product.barcode!,
              format: BarcodeFormat.code128,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return RawImage(image: snapshot.data);
              }
              return const CircularProgressIndicator();
            },
          ),
          Text(product.barcode!),
        ],
      ),
    );
  }
}
