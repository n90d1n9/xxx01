import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfServices {
  late pw.Document pdf;

  PdfServices() {
    pdf = pw.Document();
  }
  void saveFile() {
   
  }

  pw.Document newPdf() => pw.Document();

  addPage() {
    pdf.addPage(pw.Page(
        pageTheme: pageTheme(),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text("Hello World"),
          ); // Center
        }));
  }

  pw.PageTheme pageTheme() => const pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
      );

  deleteFile() {}

  pickImageMobile() {
    final image = pw.MemoryImage(
      File('test.webp').readAsBytesSync(),
    );

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(
        child: pw.Image(image),
      ); // Center
    }));
  }

  saveImage() {}

  pickFile() {}
}


/* 
To load an image from asset file (web):

Create a Uint8List from the image

final img = await rootBundle.load('assets/images/logo.jpg');
final imageBytes = img.buffer.asUint8List();

------------------

Create an image from the ImageBytes

pw.Image image1 = pw.Image(pw.MemoryImage(imageBytes));

-------------

implement the image in a container

pw.Container(
   alignment: pw.Alignment.center,
   height: 200,
   child: image1,
);

---------
To load an image from the network using the printing package:

final netImage = await networkImage('https://www.nfet.net/nfet.jpg');

pdf.addPage(pw.Page(build: (pw.Context context) {
  return pw.Center(
    child: pw.Image(netImage),
  ); // Center
}));

-----------
To load an SVG:

String svgRaw = '''
<svg viewBox="0 0 50 50" xmlns="http://www.w3.org/2000/svg">
  <ellipse style="fill: grey; stroke: black;" cx="25" cy="25" rx="20" ry="20"></ellipse>
</svg>
''';

final svgImage = pw.SvgImage(svg: svgRaw);

pdf.addPage(pw.Page(build: (pw.Context context) {
  return pw.Center(
    child: svgImage,
  ); // Center
}));

----------------
To load the SVG from a Flutter asset, use await rootBundle.loadString('assets/file.svg')

To use a TrueType font:

final Uint8List fontData = File('open-sans.ttf').readAsBytesSync();
final ttf = pw.Font.ttf(fontData.buffer.asByteData());

pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (pw.Context context) {
      return pw.Center(
        child: pw.Text('Hello World', style: pw.TextStyle(font: ttf, fontSize: 40)),
      ); // Center
    })); // Page
Or using the printing package's PdfGoogleFonts:

final font = await PdfGoogleFonts.nunitoExtraLight();

pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (pw.Context context) {
      return pw.Center(
        child: pw.Text('Hello World', style: pw.TextStyle(font: font, fontSize: 40)),
      ); // Center
    })); // Page
To display emojis:

final emoji = await PdfGoogleFonts.notoColorEmoji();

pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    build: (pw.Context context) {
      return pw.Center(
        child: pw.Text(
          'Hello 🐒💁👌🎍😍🦊👨 world!',
          style: pw.TextStyle(
            fontFallback: [emoji],
            fontSize: 25,
          ),
        ),
      ); // Center
    })); // Page
To save the pdf file (Mobile):

// On Flutter, use the [path_provider](https://pub.dev/packages/path_provider) library:
//   final output = await getTemporaryDirectory();
//   final file = File("${output.path}/example.pdf");
final file = File("example.pdf");
await file.writeAsBytes(await pdf.save());
To save the pdf file (Web): (saved as a unique name based on milliseconds since epoch)

var savedFile = await pdf.save();
List<int> fileInts = List.from(savedFile);
html.AnchorElement(
    href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}")
  ..setAttribute("download", "${DateTime.now().millisecondsSinceEpoch}.pdf")
  ..click();





 */