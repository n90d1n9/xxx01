import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QRCodeGenerator(),
    );
  }
}

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  _QRCodeGeneratorState createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  String qrData = "https://kayys.tech";
  bool isCircle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code Generator")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                border: Border.all(color: Colors.black, width: 2),
              ),
              padding: const EdgeInsets.all(10),
              child: QrImageView(
                data: qrData,
                size: 200,
                backgroundColor: Colors.white,
                embeddedImage: AssetImage("assets/icons/caliphart-logo.png"),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(50, 50),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              children: const [
                Padding(padding: EdgeInsets.all(8.0), child: Text("Rectangle")),
                Padding(padding: EdgeInsets.all(8.0), child: Text("Circle")),
              ],
              isSelected: [!isCircle, isCircle],
              onPressed: (int index) {
                setState(() {
                  isCircle = index == 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
